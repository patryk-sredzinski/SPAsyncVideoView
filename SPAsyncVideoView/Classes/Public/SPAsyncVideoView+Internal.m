//
//  SPAsyncVideoView+Internal.m
//  Pods
//
//  Created by Sergey Pimenov on 26/10/2016.
//
//

#import "SPAsyncVideoView+Internal.h"

#import "SPAsyncVideoAsset.h"
#import "SPAsyncVideoReader.h"

#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface SPAsyncVideoView () <SPAsyncVideoReaderDelegate>

@property (atomic, assign) BOOL canRenderAsset;
@property (atomic, strong) dispatch_queue_t workingQueue;
@property (nonatomic, strong) SPAsyncVideoReader *assetReader;
@property (atomic, strong) AVSampleBufferDisplayLayer *displayLayer;

@end

@implementation SPAsyncVideoView

#pragma mark - Public API

- (instancetype)init {
    self = [super init];

    if (self) {
        [self commonInit];
    }

    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [self commonInit];
}

- (void)setAsset:(nullable SPAsyncVideoAsset *)asset {
    NSAssert([NSThread isMainThread], @"Thread Checker");

    [self setVideoVisible:NO];

    if ([_asset isEqual:asset]) {
        return;
    }

    BOOL needToFlush = asset == nil || _asset != nil;

    _asset = asset;

    __weak typeof (self) weakSelf = self;
    dispatch_async(self.workingQueue, ^{
        if (needToFlush) {
            [weakSelf flushAndStopReading];
        }

        if (weakSelf.autoPlay) {
            [weakSelf setupWithAsset:asset];
        }
    });
}

- (void)setVideoGravity:(SPAsyncVideoViewVideoGravity)videoGravity {
    if (_videoGravity == videoGravity) {
        return;
    }

    _videoGravity = videoGravity;

    AVSampleBufferDisplayLayer *displayLayer = self.displayLayer;

    switch (videoGravity) {
        case SPAsyncVideoViewVideoGravityResize:
            displayLayer.videoGravity = AVLayerVideoGravityResize;
            break;
        case SPAsyncVideoViewVideoGravityResizeAspect:
            displayLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case SPAsyncVideoViewVideoGravityResizeAspectFill:
            displayLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        default:
            break;
    }
}

- (void)playVideo {
    NSAssert([NSThread mainThread] == [NSThread mainThread], @"Thread checker");
    NSParameterAssert(self.asset);

    __weak typeof (self) weakSelf = self;
    dispatch_async(self.workingQueue, ^{
        [weakSelf setupWithAsset:weakSelf.asset];
    });
}

- (void)stopVideo {
    NSAssert([NSThread isMainThread], @"Thread Checker");

    __weak typeof (self) weakSelf = self;
    dispatch_async(self.workingQueue, ^{
        [weakSelf flushAndStopReading];
    });
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.displayLayer.frame = self.bounds;
}

#pragma mark - Private API

- (void)setVideoVisible:(BOOL)isVisible {
    if ([NSThread mainThread] == [NSThread currentThread]) {
        self.hidden = !isVisible;
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.hidden = !isVisible;
        });
    }
}

- (void)internalFlush {
    if ([self.delegate respondsToSelector:@selector(asyncVideoViewWillFlush:)]) {
        [self.delegate asyncVideoViewWillFlush:self];
    }

    AVSampleBufferDisplayLayer *displayLayer = [self displayLayer];

    [displayLayer stopRequestingMediaData];
    [displayLayer flushAndRemoveImage];

    if ([self.delegate respondsToSelector:@selector(asyncVideoViewDidFlush:)]) {
        [self.delegate asyncVideoViewDidFlush:self];
    }
}

- (void)flushAndStopReading {
    [self internalFlush];
    self.assetReader.delegate = nil;
    self.assetReader = nil;
    [self setVideoVisible:NO];
}

- (void)forceRestart {
    SPAsyncVideoAsset *asset = self.asset;
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.asset = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.asset = asset;
        });
    });
}

- (void)commonInit {
    _displayLayer = [AVSampleBufferDisplayLayer layer];
    [self.layer addSublayer:self.displayLayer];

    self.workingQueue = dispatch_queue_create("com.com.SPAsyncVideoViewQueue", DISPATCH_QUEUE_SERIAL);
    self.backgroundColor = [UIColor clearColor];

    self.actionAtItemEnd = SPAsyncVideoViewActionAtItemEndRepeat;
    self.videoGravity = SPAsyncVideoViewVideoGravityResizeAspectFill;
    self.autoPlay = YES;
    self.canRenderAsset = [UIApplication sharedApplication].applicationState != UIApplicationStateBackground;
    self.restartPlaybackOnEnteringForeground = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)setupWithAsset:(SPAsyncVideoAsset *)asset {
    if (asset == nil) {
        return;
    }

    if (asset.finalURL == nil) {
        return;
    }

    __weak typeof (self) weakSelf = self;
    dispatch_async(self.workingQueue, ^{
        weakSelf.assetReader = [[SPAsyncVideoReader alloc] initWithAsset:weakSelf.asset
                                                            readingQueue:weakSelf.workingQueue];
        weakSelf.assetReader.delegate = weakSelf;
        [weakSelf.assetReader startReading];
    });
}

- (void)setCurrentControlTimebaseWithTime:(CMTime)time {
    AVSampleBufferDisplayLayer *displayLayer = self.displayLayer;

    CMTimebaseRef controlTimebase;
    CMTimebaseCreateWithMasterClock(CFAllocatorGetDefault(),
                                    CMClockGetHostTimeClock(),
                                    &controlTimebase);

    displayLayer.controlTimebase = controlTimebase;

    CMTimebaseSetTime(displayLayer.controlTimebase, time);
    CMTimebaseSetRate(displayLayer.controlTimebase, 1.);
}

- (void)startReading {
    __weak typeof (self) weakSelf = self;
    __block BOOL isFirstFrame = YES;
    dispatch_queue_t readingQueue = self.workingQueue;

    dispatch_async(readingQueue, ^{
        [weakSelf setCurrentControlTimebaseWithTime:CMTimeMake(0., 1.)];
        [weakSelf.displayLayer requestMediaDataWhenReadyOnQueue:readingQueue usingBlock:^{
            AVSampleBufferDisplayLayer *displayLayer = weakSelf.displayLayer;
            SPAsyncVideoReader *assetReader = weakSelf.assetReader;

            if (![assetReader isReadyForMoreMediaData]) {
                return;
            }

            if (!displayLayer.isReadyForMoreMediaData
                || displayLayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
                return;
            }

            if (!weakSelf.canRenderAsset) {
                return;
            }

            CMSampleBufferRef sampleBuffer = [assetReader copyNextSampleBuffer];

            if (sampleBuffer != NULL) {
                [displayLayer enqueueSampleBuffer:sampleBuffer];
                
                if ([weakSelf.delegate respondsToSelector:@selector(asyncVideoViewDidRenderFrame:timestamp:)]) {
                    [weakSelf.delegate asyncVideoViewDidRenderFrame:weakSelf timestamp:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                }
                
                CFRelease(sampleBuffer);

                if (isFirstFrame) {
                    [weakSelf setVideoVisible:YES];
                }

                isFirstFrame = NO;

                return;
            }

            if ([weakSelf.delegate respondsToSelector:@selector(asyncVideoViewDidPlayToEnd:)]) {
                [weakSelf.delegate asyncVideoViewDidPlayToEnd:weakSelf];
            }

            switch (weakSelf.actionAtItemEnd) {
                case SPAsyncVideoViewActionAtItemEndNone: {
                    [weakSelf flushAndStopReading];
                    break;
                }
                case SPAsyncVideoViewActionAtItemEndRepeat: {
                    [displayLayer flush];
                    [weakSelf setCurrentControlTimebaseWithTime:CMTimeMake(0., 1.)];
                    [assetReader resetToBegining];
                    break;
                }
                default:
                    break;
            }
        }];
    });
}

- (void)updateLayerTransformation:(SPAsyncVideoReader *)asyncVideoReader {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setAnimationDuration:0];
    [self.displayLayer setAffineTransform:asyncVideoReader.assetPrefferedTransform];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [CATransaction commit];
}

- (void)notifyDelegateAboutError:(nonnull NSError *)error {
    if ([self.delegate respondsToSelector:@selector(asyncVideoView:didOccurError:)]) {
        [self.delegate asyncVideoView:self didOccurError:error];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notificaiton {
    self.canRenderAsset = NO;

    [self stopVideo];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    self.canRenderAsset = YES;

    if (self.restartPlaybackOnEnteringForeground) {
        [self forceRestart];
    }
}

#pragma mark - SPAsyncVideoReaderDelegate

- (void)asyncVideoReaderReady:(SPAsyncVideoReader *)asyncVideoReader {
    [self updateLayerTransformation:asyncVideoReader];
    if ([self.delegate respondsToSelector:@selector(asyncVideoView:didReceiveAssetNaturalSize:)]) {
        [self.delegate asyncVideoView:self didReceiveAssetNaturalSize:asyncVideoReader.assetNaturalSize];
    }
    if ([self.delegate respondsToSelector:@selector(asyncVideoView:didReceiveAssetDuration:)]) {
        [self.delegate asyncVideoView:self didReceiveAssetDuration:asyncVideoReader.assetDuration];
    }
    [self startReading];
}

- (void)asyncVideoReaderDidFailWithError:(NSError *)error {
    self.assetReader.delegate = nil;
    self.assetReader = nil;

    if ([self.delegate respondsToSelector:@selector(asyncVideoView:didOccurError:)]) {
        [self.delegate asyncVideoView:self didOccurError:error];
    }
}

- (void)dealloc {
    self.delegate = nil;

    dispatch_sync(self.workingQueue, ^{
        [self internalFlush];
        self.assetReader = nil;
    });

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

@end
