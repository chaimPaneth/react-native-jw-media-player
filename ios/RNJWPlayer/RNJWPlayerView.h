#if __has_include("React/RCTViewManager.h")
#import "React/RCTViewManager.h"
#else
#import "RCTViewManager.h"
#endif

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <JWPlayerKit/JWPlayerKit-swift.h>
#import <GoogleCast/GoogleCast.h>

@interface RNJWPlayerView : UIView  <JWPlayerDelegate, JWPlayerStateDelegate, JWAdDelegate, JWCastDelegate, JWAVDelegate, JWPlayerViewDelegate, JWPlayerViewControllerDelegate, AVPictureInPictureControllerDelegate>

@property(nonatomic, strong)JWPlayerViewController* playerViewController;
@property(nonatomic, strong)JWPlayerView *playerView;

@property(nonatomic)BOOL pipEnabled;
@property(nonatomic)BOOL backgroundAudioEnabled;

@property(nonatomic)BOOL userPaused;
@property(nonatomic)BOOL wasInterrupted;

/* casting objects */
@property(nonatomic, strong)JWCastController *castController;
@property(nonatomic)BOOL isCasting;
@property(nonatomic, strong)NSArray<JWCastingDevice *> *availableDevices;

/* player state events */
@property(nonatomic, copy)RCTBubblingEventBlock onBuffer;
@property(nonatomic, copy)RCTBubblingEventBlock onUpdateBuffer;
@property(nonatomic, copy)RCTBubblingEventBlock onPlay;
@property(nonatomic, copy)RCTBubblingEventBlock onBeforePlay;
@property(nonatomic, copy)RCTBubblingEventBlock onAttemptPlay;
@property(nonatomic, copy)RCTBubblingEventBlock onPause;
@property(nonatomic, copy)RCTBubblingEventBlock onIdle;
@property(nonatomic, copy)RCTBubblingEventBlock onPlaylistItem;
@property(nonatomic, copy)RCTBubblingEventBlock onLoaded;
@property(nonatomic, copy)RCTBubblingEventBlock onVisible;
@property(nonatomic, copy)RCTBubblingEventBlock onTime;
@property(nonatomic, copy)RCTBubblingEventBlock onSeek;
@property(nonatomic, copy)RCTBubblingEventBlock onSeeked;
@property(nonatomic, copy)RCTBubblingEventBlock onPlaylist;
@property(nonatomic, copy)RCTBubblingEventBlock onPlaylistComplete;
@property(nonatomic, copy)RCTBubblingEventBlock onBeforeComplete;
@property(nonatomic, copy)RCTBubblingEventBlock onComplete;

/* av events */
@property(nonatomic, copy)RCTBubblingEventBlock onAudioTracks;

/* player events */
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerReady;
@property(nonatomic, copy)RCTBubblingEventBlock onSetupPlayerError;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerError;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerWarning;

/* ad events */
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerAdWarning;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerAdError;
@property(nonatomic, copy)RCTBubblingEventBlock onAdEvent;

/* player view controller events */
@property(nonatomic, copy)RCTBubblingEventBlock onScreenTapped;
@property(nonatomic, copy)RCTBubblingEventBlock onControlBarVisible;
@property(nonatomic, copy)RCTBubblingEventBlock onFullScreen;
@property(nonatomic, copy)RCTBubblingEventBlock onFullScreenRequested;
@property(nonatomic, copy)RCTBubblingEventBlock onFullScreenExit;
@property(nonatomic, copy)RCTBubblingEventBlock onFullScreenExitRequested;

/* player view events */
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerSizeChange;

/* casting events */
@property(nonatomic, copy)RCTBubblingEventBlock onCastingDevicesAvailable;
@property(nonatomic, copy)RCTBubblingEventBlock onConnectedToCastingDevice;
@property(nonatomic, copy)RCTBubblingEventBlock onDisconnectedFromCastingDevice;
@property(nonatomic, copy)RCTBubblingEventBlock onConnectionTemporarilySuspended;
@property(nonatomic, copy)RCTBubblingEventBlock onConnectionRecovered;
@property(nonatomic, copy)RCTBubblingEventBlock onConnectionFailed;
@property(nonatomic, copy)RCTBubblingEventBlock onCasting;
@property(nonatomic, copy)RCTBubblingEventBlock onCastingEnded;
@property(nonatomic, copy)RCTBubblingEventBlock onCastingFailed;

/* casting methods */
- (void)setUpCastController;
- (void)presentCastDialog;
- (GCKCastState)castState;
- (JWCastingDevice*)connectedDevice;
- (NSArray <JWCastingDevice *>*)availableDevices;

@end
