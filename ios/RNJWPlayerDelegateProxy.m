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

- (void)onControlBarVisible:(JWEvent<JWControlsEvent> *)event
{
    [self.delegate onRNJWControlBarVisible:event];
}

- (void)onComplete
{
    [self.delegate onRNJWPlayerComplete];
}

- (void)onAudioTracks:(JWEvent<JWLevelsEvent> *)event
{
    [self.delegate onRNJWPlayerAudioTracks];
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

#pragma Mark - Casting delegate methods

- (void)onCastingDevicesAvailable:(NSArray <JWCastingDevice *> *)devices;
{
    [self.delegate onRNJWCastingDevicesAvailable:devices];
}

- (void)onConnectedToCastingDevice:(JWCastingDevice *)device
{
    [self.delegate onRNJWConnectedToCastingDevice:device];
}

- (void)onDisconnectedFromCastingDevice:(NSError *)error
{
    [self.delegate onRNJWDisconnectedFromCastingDevice:error];
}

- (void)onConnectionTemporarilySuspended
{
    [self.delegate onRNJWConnectionTemporarilySuspended];
}

- (void)onConnectionRecovered
{
    [self.delegate onRNJWConnectionRecovered];
}

- (void)onConnectionFailed:(NSError *)error
{
    [self.delegate onRNJWConnectionFailed:error];
}

- (void)onCasting
{
    [self.delegate onRNJWCasting];
}

- (void)onCastingEnded:(NSError *)error
{
    [self.delegate onRNJWCastingEnded:error];
}

- (void)onCastingFailed:(NSError *)error
{
    [self.delegate onRNJWCastingFailed:error];
}

@end
