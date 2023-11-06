//
//  SPViewController.m
//  SPAsyncVideoView
//
//  Created by Pimenov Sergey on 07/14/2016.
//  Copyright (c) 2016 Pimenov Sergey. All rights reserved.
//

#import "SPViewController.h"

@import SPAsyncVideoView;

#import "SPViewCell.h"

@interface SPViewController ()

@property (nonatomic, strong) NSURL *mp4Url;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation SPViewController
- (IBAction)reloadAction:(id)sender {
    
    for (UIView* view in self.containerView.subviews) {
        [view removeFromSuperview];
    }
    UIImage* image = [UIImage imageNamed:@"placeholder"];
    UIImageView* behindPlaceholderView = [[UIImageView alloc] initWithImage:image];
    [self.containerView addSubview:behindPlaceholderView];
    [behindPlaceholderView setFrame:self.containerView.bounds];
    
    SPAsyncVideoView* videoView = [[SPAsyncVideoView alloc] init];
    videoView.asset = [[SPAsyncVideoAsset alloc] initWithURL:self.mp4Url type:SPAsyncVideoAssetTypeVideo];
    [self.containerView addSubview:videoView];
    [videoView setFrame:self.containerView.bounds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mp4Url = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"mp4"];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self reloadAction: nil];
    }];
}

@end
