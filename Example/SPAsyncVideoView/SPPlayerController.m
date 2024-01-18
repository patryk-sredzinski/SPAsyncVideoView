//
//  SPPlayerController.m
//  SPAsyncVideoView
//
//  Created by Pimenov Sergey on 07/14/2016.
//  Copyright (c) 2016 Pimenov Sergey. All rights reserved.
//

#import "SPPlayerController.h"

@import SPAsyncVideoView;

@interface SPPlayerController()
@property (weak, nonatomic) IBOutlet SPAsyncVideoView *videoView;
@end

@implementation SPPlayerController

- (IBAction)playAction:(id)sender {
    [_videoView playVideo];
}

- (IBAction)pauseAction:(id)sender {
    [_videoView pauseVideo];
}

- (IBAction)muteAction:(id)sender {
}

- (IBAction)unmuteAction:(id)sender {
}

- (IBAction)seekAction:(id)sender {
    CMTime time = CMTimeMake(5, kCMTimeMaxTimescale);
    [_videoView seek:time];
}

- (IBAction)reloadAction:(id)sender {
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"medium" withExtension:@"mp4"];
    _videoView.asset = nil;
    _videoView.asset = [[SPAsyncVideoAsset alloc] initWithURL:url loadAudio:YES];
    [_videoView playVideo];
}

@end
