//
//  SPAsyncVideoView+Internal.h
//  Pods
//
//  Created by Sergey Pimenov on 26/10/2016.
//
//
#import <CoreMedia/CoreMedia.h>

@class SPAsyncVideoView;
@class SPAsyncVideoAsset;

typedef NS_ENUM(NSInteger, SPAsyncVideoViewActionAtItemEnd) {
    SPAsyncVideoViewActionAtItemEndNone,
    SPAsyncVideoViewActionAtItemEndRepeat
};

typedef NS_ENUM(NSInteger, SPAsyncVideoViewVideoGravity) {
    SPAsyncVideoViewVideoGravityResizeAspect,
    SPAsyncVideoViewVideoGravityResizeAspectFill,
    SPAsyncVideoViewVideoGravityResize
};

NS_ASSUME_NONNULL_BEGIN

@protocol SPAsyncVideoViewDelegate <NSObject>

@optional
- (void)asyncVideoView:(SPAsyncVideoView *)asyncVideoView didOccurError:(NSError *)error;
- (void)asyncVideoViewDidPlayToEnd:(SPAsyncVideoView *)asyncVideoView;

- (void)asyncVideoViewDidRenderFrame:(SPAsyncVideoView *)asyncVideoView timestamp:(CMTime)timestamp;

- (void)asyncVideoViewWillFlush:(SPAsyncVideoView *)asyncVideoView;
- (void)asyncVideoViewDidFlush:(SPAsyncVideoView *)asyncVideoView;

- (void)asyncVideoView:(SPAsyncVideoView *)asyncVideoView didReceiveAssetNaturalSize:(CGSize)assetNaturalSize;
- (void)asyncVideoView:(SPAsyncVideoView *)asyncVideoView didReceiveAssetDuration:(CMTime)assetDuration;

@end

@interface SPAsyncVideoView : UIView

@property (nonatomic, weak) id<SPAsyncVideoViewDelegate> delegate;
@property (nullable, nonatomic, strong) SPAsyncVideoAsset *asset;
@property (nonatomic, assign) SPAsyncVideoViewVideoGravity videoGravity;
@property (nonatomic, assign) SPAsyncVideoViewActionAtItemEnd actionAtItemEnd;
@property (nonatomic, assign) BOOL restartPlaybackOnEnteringForeground;

- (void)configureVideo;
- (void)playVideo;
- (void)pauseVideo;
- (void)stopVideo;
- (void)seek:(CMTime)time;
@end

NS_ASSUME_NONNULL_END
