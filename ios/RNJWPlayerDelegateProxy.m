#import "RNJWPlayerDelegateProxy.h"

@implementation RNJWPlayerDelegateProxy
#pragma mark - RNJWPlayer Delegate

- (void)onReady:(JWEvent<JWReadyEvent> *)event
{
    [self.delegate onRNJWReady];
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

- (void)onIdle:(JWEvent<JWStateChangeEvent> *)event
{
    [self.delegate onRNJWPlayerIdle];
}

- (void)onPlaylistItem:(JWEvent<JWPlaylistItemEvent> *)event;
{
    [self.delegate onRNJWPlayerPlaylistItem:event];
}

- (void)onSetupError:(JWEvent<JWErrorEvent> *)event
{
    [self.delegate onRNJWSetupPlayerError:event];
}

- (void)onError:(JWEvent<JWErrorEvent> *)event
{
    [self.delegate onRNJWSetupPlayerError:event];
}

- (void)onSeek:(JWEvent<JWSeekEvent> *)event
{
    [self.delegate onRNJWPlayerSeek:event];
}

- (void)onSeeked
{
    [self.delegate onRNJWPlayerSeeked];
}

- (void)onFullscreen:(JWEvent<JWFullscreenEvent> *)event
{
    [self.delegate onRNJWFullScreen:event];
}

- (void)onFullscreenRequested:(JWEvent<JWFullscreenEvent> *)event
{
    [self.delegate onRNJWFullScreenRequested:event];
}

- (void)onFullscreenExit:(JWEvent<JWFullscreenEvent> *)event
{
    [self.delegate onRNJWFullScreenExit:event];
}

- (void)onRNJWFullScreenExitRequested:(JWEvent<JWFullscreenEvent> *)event
{
    [self.delegate onRNJWFullScreenExitRequested:event];
}

- (void)onControlBarVisible:(JWEvent<JWControlsEvent> *)event
{
    [self.delegate onRNJWControlBarVisible:event];
}

- (void)onComplete
{
    [self.delegate onRNJWPlayerComplete];
}

// Ad events

- (void)onBeforePlay
{
    [self.delegate onRNJWPlayerBeforePlay];
}

- (void)onBeforeComplete
{
    [self.delegate onRNJWPlayerBeforeComplete];
}

- (void)onAdPlay:(JWAdEvent<JWAdStateChangeEvent> *)event
{
    [self.delegate onRNJWPlayerAdPlay:event];
}

- (void)onAdPause:(JWAdEvent<JWAdStateChangeEvent> *)event
{
    [self.delegate onRNJWPlayerAdPause:event];
}

// TODO: - add other ad events

@end
