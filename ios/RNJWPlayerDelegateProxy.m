#import "RNJWPlayerDelegateProxy.h"

@implementation RNJWPlayerDelegateProxy
#pragma mark - RNJWPlayer Delegate

- (void)onBeforePlay {
    [self.delegate onRNJWPlayerBeforePlay];
}

- (void)onBuffer:(JWEvent<JWBufferEvent> *)event {
    [self.delegate onRNJWPlayerBuffer];
}

- (void)onPlay:(JWEvent<JWStateChangeEvent> *)event {
    [self.delegate onRNJWPlayerPlay];
}

- (void)onTime:(JWEvent<JWTimeEvent> *)event {
    [self.delegate onRNJWPlayerTime:event.position ofDuration:event.duration];
}

- (void)onPause:(JWEvent<JWStateChangeEvent> *)event {
    [self.delegate onRNJWPlayerPause];
}

- (void)onError:(NSError *)error {
    [self.delegate onRNJWPlayerError:error];
}


@end
