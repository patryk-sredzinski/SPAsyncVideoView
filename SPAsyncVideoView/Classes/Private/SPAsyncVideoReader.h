//
//  SPAsyncVideoReader.h
//  Pods
//
//  Created by Sergey Pimenov on 20/10/2016.
//
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@class SPAsyncVideoAsset;
@class SPAsyncVideoReader;

NS_ASSUME_NONNULL_BEGIN

@protocol SPAsyncVideoReaderDelegate <NSObject>

- (void)asyncVideoReaderReady:(SPAsyncVideoReader *)asyncVideoReader;
- (void)asyncVideoReaderDidFailWithError:(NSError *)error;

@end

@interface SPAsyncVideoReader : NSObject

@property (nonatomic, assign) CGSize assetNaturalSize;
@property (nonatomic, assign) CGAffineTransform assetPrefferedTransform;
@property (nonatomic, assign) CMTime assetDuration;
@property (atomic, strong, readonly) SPAsyncVideoAsset *asset;
@property (atomic, strong, readonly) dispatch_queue_t readingQueue;
@property (nonatomic, weak) id<SPAsyncVideoReaderDelegate> delegate;
@property (readonly, getter=isReadyForMoreMediaData) BOOL readyForMoreMediaData;

- (instancetype)initWithAsset:(SPAsyncVideoAsset *)asset readingQueue:(dispatch_queue_t)readingQueue;
- (BOOL)shouldReadAudio;
- (void)startReading;
- (void)resetToBegining;
- (CMSampleBufferRef)copyNextVideoSampleBuffer;
- (CMSampleBufferRef)copyNextAudioSampleBuffer;

@end

NS_ASSUME_NONNULL_END
