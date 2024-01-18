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

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _URL = url;
        _outputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
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
