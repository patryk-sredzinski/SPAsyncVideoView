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
@property (nonatomic, strong) NSDictionary *videoSettings;
@property (nonatomic, strong) NSDictionary *audioSettings;
@property (nonatomic, assign) BOOL loadAudio;

- (instancetype)initWithURL:(NSURL *)url loadAudio:(BOOL)loadAudio;

@end

NS_ASSUME_NONNULL_END
