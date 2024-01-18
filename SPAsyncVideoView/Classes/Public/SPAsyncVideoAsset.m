//
//  SPAsyncVideoAsset.m
//  Pods
//
//  Created by Sergey Pimenov on 14/07/16.
//
//

#import "SPAsyncVideoAsset.h"

#import <AVFoundation/AVFoundation.h>

@implementation SPAsyncVideoAsset

- (instancetype)initWithURL:(NSURL *)url loadAudio:(BOOL)loadAudio {
    self = [super init];
    if (self) {
        _URL = url;
        _videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
        _audioSettings =  @{ AVFormatIDKey : [NSNumber numberWithInt:kAudioFormatLinearPCM] };
        _loadAudio = loadAudio;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[SPAsyncVideoAsset class]]) {
        return NO;
    }
    
    return [self.URL isEqual:[object URL]];
}

- (NSUInteger)hash {
    return self.URL.hash;
}

@end
