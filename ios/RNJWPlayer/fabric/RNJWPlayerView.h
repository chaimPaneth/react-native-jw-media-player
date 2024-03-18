//
//  RNJWPlayerView.h
//  RNJWPlayer
//
//  Created by Chaim Paneth on 18/03/2024.
//

@class NSDictionary;
@class NSString;
@class NSCoder;

#import <React/RCTView.h>

@interface RNJWPlayerView : RCTView
- (void)setSpeed:(CGFloat)newSpeed;
- (void)play;
- (void)pause;
- (void)reset;
- (void)quite;
- (nonnull instancetype)initWithFrame:(CGRect)frame;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder;
@end
