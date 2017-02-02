#import <Foundation/Foundation.h>

#import "RNJWPlayerNativeView.h"

@interface RNJWPlayerDelegateProxy : NSObject<JWPlayerDelegate>
@property(nonatomic, strong)RNJWPlayerNativeView *delegate;
-(void)onBeforePlay;
-(void)onPlay;
-(void)onBuffer;
-(void)onError:(NSError *)error;
-(void)onTime:(double)position ofDuration:(double)duration;
@end
