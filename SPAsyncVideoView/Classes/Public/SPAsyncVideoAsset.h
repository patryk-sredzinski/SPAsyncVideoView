//
//  SPAsyncVideoAsset.h
//  Pods
//
//  Created by Sergey Pimenov on 14/07/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SPAsyncVideoAsset : NSObject

@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, strong) NSDictionary *outputSettings;

- (instancetype)initWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
