#import "RNJWPlayerDelegateProxy.h"

@implementation RNJWPlayerDelegateProxy
#pragma mark - RNJWPlayer Delegate

- (void)onBeforePlay
{
    [self.delegate onRNJWPlayerBeforePlay];
}

- (void)onBuffer:(JWEvent<JWBufferEvent> *)event
{
    [self.delegate onRNJWPlayerBuffer];
}

- (void)onPlay:(JWEvent<JWStateChangeEvent> *)event
{
    [self.delegate onRNJWPlayerPlay];
}

- (void)onTime:(JWEvent<JWTimeEvent> *)event
{
    [self.delegate onRNJWPlayerTime:event];
}

- (void)onPause:(JWEvent<JWStateChangeEvent> *)event
{
    [self.delegate onRNJWPlayerPause];
}

- (void)onSetupError:(JWEvent<JWErrorEvent> *)event
{
    [self.delegate onRNJWSetupPlayerError:event];
}

- (void)onError:(JWEvent<JWErrorEvent> *)event
{
    [self.delegate onRNJWSetupPlayerError:event];
}

- (void)onFullscreen:(JWEvent<JWFullscreenEvent> *)event
{
    [self.delegate onRNJWFullScreen:event];
}

- (void)onFullscreenRequested:(JWEvent<JWFullscreenEvent> *)event
{
    [self.delegate onRNJWFullScreenRequested:event];
}

@end
