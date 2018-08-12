#import <Foundation/Foundation.h>

#import "RNJWPlayerNativeView.h"

@class RNJWPlayerNativeView;

@interface RNJWPlayerDelegateProxy : NSObject<JWPlayerDelegate>
@property(nonatomic, strong)RNJWPlayerNativeView *delegate;
- (void)onBeforePlay;
- (void)onBuffer:(JWEvent<JWBufferEvent> *)event;
- (void)onPlay:(JWEvent<JWStateChangeEvent> *)event;
- (void)onTime:(JWEvent<JWTimeEvent> *)event;
- (void)onPause:(JWEvent<JWStateChangeEvent> *)event;
- (void)onError:(NSError *)error;
@end
