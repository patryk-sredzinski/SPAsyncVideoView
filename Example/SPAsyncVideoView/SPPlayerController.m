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
}

- (IBAction)pauseAction:(id)sender {
}

- (IBAction)muteAction:(id)sender {
}

- (IBAction)unmuteAction:(id)sender {
}

- (IBAction)seekAction:(id)sender {
}

- (IBAction)reloadAction:(id)sender {
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"big" withExtension:@"mp4"];
    _videoView.asset = nil;
    _videoView.asset = [[SPAsyncVideoAsset alloc] initWithURL:url];
}

@end
