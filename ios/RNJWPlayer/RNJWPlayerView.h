#if __has_include("React/RCTViewManager.h")
#import "React/RCTViewManager.h"
#else
#import "RCTViewManager.h"
#endif

#import <JWPlayerKit/JWPlayerKit-swift.h>
#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

@interface RNJWPlayerView: UIView  <JWPlayerDelegate, JWPlayerStateDelegate, JWAdDelegate, JWCastDelegate, JWAVDelegate, JWPlayerViewDelegate, JWPlayerViewControllerDelegate, AVPictureInPictureControllerDelegate>

@property(nonatomic, strong)JWPlayerView *playerView;

@property(nonatomic)BOOL pipEnabled;
@property(nonatomic)BOOL backgroundAudioEnabled;

@property(nonatomic)CGRect initFrame;
@property(nonatomic)BOOL userPaused;
@property(nonatomic)BOOL wasInterrupted;

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

/* player events */
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerReady;
@property(nonatomic, copy)RCTBubblingEventBlock onSetupPlayerError;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerError;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerWarning;

/* ad events */
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerAdWarning;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerAdError;
@property(nonatomic, copy)RCTBubblingEventBlock onAdEvent;

/* player view events */
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerSizeChange;

@end
