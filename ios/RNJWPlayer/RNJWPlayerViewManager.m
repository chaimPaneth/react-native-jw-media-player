#import <React/RCTBridge.h>
#import "React/RCTViewManager.h"
#import "RCTUIManager.h"

#import <JWPlayerKit/JWPlayerKit-swift.h>

@interface RCT_EXTERN_MODULE(RNJWPlayerViewManager, RCTViewManager)

/* player state events */
RCT_EXPORT_VIEW_PROPERTY(onTime, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onLoaded, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onSeek, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onSeeked, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlaylist, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlaylistComplete, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBeforeComplete, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onComplete, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVisible, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBeforePlay, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onAttemptPlay, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlay, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPause, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBuffer, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onUpdateBuffer, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onIdle, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlaylistItem, RCTDirectEventBlock);

/* av events */
RCT_EXPORT_VIEW_PROPERTY(onAudioTracks, RCTDirectEventBlock);

/* player events */
RCT_EXPORT_VIEW_PROPERTY(onPlayerReady, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onSetupPlayerError, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerError, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerWarning, RCTDirectEventBlock);

/* ad events */
RCT_EXPORT_VIEW_PROPERTY(onPlayerAdWarning, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerAdError, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onAdEvent, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onAdTime, RCTDirectEventBlock);

/* jwplayer view controller events */
RCT_EXPORT_VIEW_PROPERTY(onControlBarVisible, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onScreenTapped, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFullScreen, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFullScreenRequested, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFullScreenExit, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFullScreenExitRequested, RCTDirectEventBlock);

/* jwplayer view events */
RCT_EXPORT_VIEW_PROPERTY(onPlayerSizeChange, RCTDirectEventBlock);

/* casting events */
RCT_EXPORT_VIEW_PROPERTY(onCastingDevicesAvailable, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onConnectedToCastingDevice, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onDisconnectedFromCastingDevice, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onConnectionTemporarilySuspended, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onConnectionRecovered, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onConnectionFailed, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onCasting, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onCastingEnded, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onCastingFailed, RCTDirectEventBlock);

/* props */
RCT_EXPORT_VIEW_PROPERTY(config, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(controls, BOOL);

RCT_EXTERN_METHOD(state:(nonnull NSNumber*)reactTag
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(pause:(nonnull NSNumber*)reactTag)

RCT_EXTERN_METHOD(play:(nonnull NSNumber *)reactTag)

RCT_EXTERN_METHOD(stop:(nonnull NSNumber *)reactTag)

RCT_EXTERN_METHOD(position:(nonnull NSNumber *)reactTag
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(toggleSpeed:(nonnull NSNumber*)reactTag)

RCT_EXTERN_METHOD(setSpeed:(nonnull NSNumber*)reactTag speed:(double)speed)

RCT_EXTERN_METHOD(setPlaylistIndex:(nonnull NSNumber *)reactTag index:(nonnull NSNumber *)index)

RCT_EXTERN_METHOD(seekTo:(nonnull NSNumber *)reactTag time:(nonnull NSNumber *)time)

RCT_EXTERN_METHOD(setVolume:(nonnull NSNumber *)reactTag volume:(nonnull NSNumber *)volume)

RCT_EXTERN_METHOD(togglePIP:(nonnull NSNumber *)reactTag)

RCT_EXTERN_METHOD(setUpCastController:(nonnull NSNumber *)reactTag)

RCT_EXTERN_METHOD(presentCastDialog:(nonnull NSNumber *)reactTag)

RCT_EXTERN_METHOD(connectedDevice:(nonnull NSNumber *)reactTag
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(availableDevices:(nonnull NSNumber *)reactTag
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(castState:(nonnull NSNumber *)reactTag
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getAudioTracks:(nonnull NSNumber *)reactTag
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getCurrentAudioTrack:(nonnull NSNumber *)reactTag
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(setCurrentAudioTrack:(nonnull NSNumber *)reactTag index:(nonnull NSNumber *)index)

RCT_EXTERN_METHOD(setControls:(nonnull NSNumber *)reactTag show:(BOOL)show)

RCT_EXTERN_METHOD(setVisibility:(nonnull NSNumber *)reactTag visibilty:(BOOL)visibilty controls:(nonnull NSArray *)controls)

RCT_EXTERN_METHOD(setLockScreenControls:(nonnull NSNumber *)reactTag show:(BOOL)show)

RCT_EXTERN_METHOD(setCurrentCaptions:(nonnull NSNumber *)reactTag index:(nonnull NSNumber *)index)

RCT_EXTERN_METHOD(setCurrentCaptions:(nonnull NSNumber *)reactTag index:(nonnull NSNumber *)index)

RCT_EXTERN_METHOD(setLicenseKey:(nonnull NSNumber *)reactTag license:(nonnull NSString *)license)

RCT_EXTERN_METHOD(quite)

RCT_EXTERN_METHOD(reset)

RCT_EXTERN_METHOD(loadPlaylist:(nonnull NSNumber *)reactTag playlist:(nonnull NSArray *)playlist)

RCT_EXTERN_METHOD(setFullscreen:(nonnull NSNumber *)reactTag fullscreen:(BOOL)fullscreen)

@end
