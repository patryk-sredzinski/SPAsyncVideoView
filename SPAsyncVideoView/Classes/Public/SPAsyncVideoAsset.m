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
        _originalURL = url;
        _outputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
        _finalURL = url;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[SPAsyncVideoAsset class]]) {
        return NO;
    }
    
    return [self.originalURL isEqual:[object originalURL]];
}

- (NSUInteger)hash {
    return self.originalURL.hash;
}

@end
