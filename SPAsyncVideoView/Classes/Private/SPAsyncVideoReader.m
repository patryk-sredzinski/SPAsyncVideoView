//
//  SPAsyncVideoReader.m
//  Pods
//
//  Created by Sergey Pimenov on 20/10/2016.
//
//

#import "SPAsyncVideoReader.h"

#import <AVFoundation/AVFoundation.h>
#import "SPAsyncVideoAsset.h"


@interface SPAsyncVideoReader ()

@property (atomic, strong) AVURLAsset *nativeAsset;
@property (atomic, strong) AVAssetReader *nativeAssetReader;
@property (atomic, strong) AVAssetReaderTrackOutput *nativeOutVideo;
@property (atomic, strong) AVAssetReaderTrackOutput *nativeOutAudio;

@end

@implementation SPAsyncVideoReader

- (instancetype)initWithAsset:(SPAsyncVideoAsset *)asset readingQueue:(dispatch_queue_t)readingQueue {
    self = [super init];
    
    if (self) {
        _asset = asset;
        _readingQueue = readingQueue;
    }
    
    return self;
}

- (void)startReadingNativeAsset {
    NSError *error = nil;
    
    AVAssetReader *assetReader = [[AVAssetReader alloc] initWithAsset:(AVAsset *)self.nativeAsset
                                                                error:&error];
    
    if (error != nil) {
        [self notifyAboutError:error];
        return;
    }
    
    NSArray<AVAssetTrack *> *videoTracks = [self.nativeAsset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *videoTrack = videoTracks.firstObject;
    AVAssetReaderTrackOutput *outVideo;
    if (videoTrack != nil) {
        outVideo = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack
                                                                                        outputSettings:self.asset.videoSettings];
        outVideo.supportsRandomAccess = YES;
        [assetReader addOutput:outVideo];
    } else {
        NSError *error = [NSError errorWithDomain:AVFoundationErrorDomain
                                             code:AVErrorOperationNotSupportedForAsset
                                         userInfo:nil];
        [self notifyAboutError:error];
        return;
    }

    AVAssetReaderTrackOutput *outAudio;
    if (_asset.loadAudio) {
        NSArray<AVAssetTrack *> *audioTracks = [self.nativeAsset tracksWithMediaType:AVMediaTypeAudio];
        AVAssetTrack *audioTrack = audioTracks.firstObject;
        if (audioTrack != nil) {
            outAudio = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack
                                                                  outputSettings:self.asset.audioSettings];
            outAudio.supportsRandomAccess = YES;
            [assetReader addOutput:outAudio];
        }
    }
    
    if (![assetReader startReading]) {
        NSError *error = [NSError errorWithDomain:AVFoundationErrorDomain
                                             code:AVErrorOperationNotSupportedForAsset
                                         userInfo:nil];
        [self notifyAboutError:error];
        return;
    }
    
    _nativeAssetReader = assetReader;
    _nativeOutVideo = outVideo;
    _nativeOutAudio = outAudio;

    CGSize assetVideoSize = videoTrack.naturalSize;
    CGAffineTransform assetPreferredTransform = videoTrack.preferredTransform;
    CMTime assetDuration = self.nativeAsset.duration;
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.assetNaturalSize = assetVideoSize;
        weakSelf.assetPrefferedTransform = assetPreferredTransform;
        weakSelf.assetDuration = assetDuration;
        [weakSelf.delegate asyncVideoReaderReady:weakSelf];
    });
}

- (void)notifyAboutError:(NSError *)error {
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.delegate asyncVideoReaderDidFailWithError:error];
    });
}

#pragma mark - Public API

- (void)startReading {
    __weak typeof (self) weakSelf = self;
    dispatch_async(self.readingQueue, ^{
        weakSelf.nativeAsset = [AVURLAsset assetWithURL:weakSelf.asset.URL];
        
        NSArray<NSString *> *keys = @[ @"tracks", @"playable", @"duration" ];
        
        [weakSelf.nativeAsset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
            if (weakSelf == nil) {
                return;
            }
            dispatch_async(weakSelf.readingQueue, ^{
                if (weakSelf == nil) {
                    return;
                }
                
                NSError *error = nil;
                
                AVKeyValueStatus status = [weakSelf.nativeAsset statusOfValueForKey:@"tracks" error:&error];
                if (error != nil || status != AVKeyValueStatusLoaded) {
                    [weakSelf notifyAboutError:error];
                    return;
                }
                
                status = [weakSelf.nativeAsset statusOfValueForKey:@"playable" error:&error];
                
                if (error != nil || status != AVKeyValueStatusLoaded) {
                    [weakSelf notifyAboutError:error];
                    return;
                }
                
                status = [weakSelf.nativeAsset statusOfValueForKey:@"duration" error:&error];
                
                if (error != nil || status != AVKeyValueStatusLoaded) {
                    [weakSelf notifyAboutError:error];
                    return;
                }
                
                [weakSelf startReadingNativeAsset];
            });
        }];
    });
}

- (void)resetToBegining {
    NSValue *beginingVideoTimeRangeValue = [NSValue valueWithCMTimeRange:self.nativeOutVideo.track.timeRange];
    [self.nativeOutVideo resetForReadingTimeRanges:@[ beginingVideoTimeRangeValue ]];
    NSValue *beginingAudioTimeRangeValue = [NSValue valueWithCMTimeRange:self.nativeOutAudio.track.timeRange];
    [self.nativeOutAudio resetForReadingTimeRanges:@[ beginingAudioTimeRangeValue ]];
}

- (CMSampleBufferRef)copyNextVideoSampleBuffer {
    return [self.nativeOutVideo copyNextSampleBuffer];
}

- (CMSampleBufferRef)copyNextAudioSampleBuffer {
    return [self.nativeOutAudio copyNextSampleBuffer];
}

- (BOOL)isReadyForMoreMediaData {
    return self.nativeAssetReader.status == AVAssetReaderStatusReading;
}

- (BOOL)shouldReadAudio {
    return self.nativeOutAudio != nil;
}

- (void)dealloc {
    [self.nativeAsset cancelLoading];
    [self.nativeAssetReader cancelReading];
}

@end
