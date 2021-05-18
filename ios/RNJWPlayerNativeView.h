#if __has_include("React/RCTViewManager.h")
#import "React/RCTViewManager.h"
#else
#import "RCTViewManager.h"
#endif

#import <JWPlayer_iOS_SDK/JWPlayerController.h>
#import <UIKit/UIKit.h>
#import <GoogleCast/GoogleCast.h>
#import "RNJWPlayerControls.h"
#import "RNJWPlayerDelegateProxy.h"

@class RNJWPlayerDelegateProxy;

@interface RNJWPlayerNativeView : UIView

@property(nonatomic, strong)JWPlayerController *player;
@property(nonatomic, strong)RNJWPlayerDelegateProxy *proxy;

@property(nonatomic, strong)JWCastController *castController;
@property(nonatomic)BOOL isCasting;
@property(nonatomic, strong)NSArray<JWCastingDevice *> *availableDevices;
@property (nonatomic) GCKUICastButton *castingButton;
@property (nonatomic) UIButton *customCastingButton;
@property(nonatomic)BOOL autoHideAirPlay;
@property(nonatomic)BOOL autoHideChromeCast;
@property(nonatomic, strong) NSArray<JWTrack *> *tracks;

@property(nonatomic, strong)NSString *file;
@property(nonatomic)BOOL autostart;
@property(nonatomic)BOOL controls;
@property(nonatomic)BOOL repeat;
@property(nonatomic)BOOL mute;
@property(nonatomic)BOOL displayTitle;
@property(nonatomic)BOOL displayDesc;
@property(nonatomic)BOOL nextUpDisplay;
@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSString *image;
@property(nonatomic, strong)NSString *desc;
@property(nonatomic, strong)NSString *mediaId;
@property(nonatomic, strong)NSString *playerStyle;
@property(nonatomic, strong)NSString *stretching;
@property(nonatomic, strong)NSDictionary *playerColors;
@property(nonatomic)BOOL nativeFullScreen;
@property(nonatomic)BOOL fullScreenOnLandscape;
@property(nonatomic)BOOL landscapeOnFullScreen;
@property(nonatomic)BOOL portraitOnExitFullScreen;
@property(nonatomic)BOOL exitFullScreenOnPortrait;
@property(nonatomic)CGRect initFrame;
@property(nonatomic)BOOL userPaused;
@property(nonatomic)BOOL wasInterrupted;
@property(nonatomic, strong)NSString *adVmap;
@property(nonatomic, strong)RNJWPlayerControls *nativeControlsView;
@property(nonatomic)BOOL nativeControls;

@property(nonatomic, copy)RCTBubblingEventBlock onBeforePlay;
@property(nonatomic, copy)RCTBubblingEventBlock onPlay;
@property(nonatomic, copy)RCTBubblingEventBlock onPause;
@property(nonatomic, copy)RCTBubblingEventBlock onBuffer;
@property(nonatomic, copy)RCTBubblingEventBlock onIdle;
@property(nonatomic, copy)RCTBubblingEventBlock onPlaylistItem;
@property(nonatomic, copy)RCTBubblingEventBlock onSetupPlayerError;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerError;
@property(nonatomic, copy)RCTBubblingEventBlock onTime;
@property(nonatomic, copy)RCTBubblingEventBlock onFullScreen;
@property(nonatomic, copy)RCTBubblingEventBlock onFullScreenRequested;
@property(nonatomic, copy)RCTBubblingEventBlock onFullScreenExit;
@property(nonatomic, copy)RCTBubblingEventBlock onFullScreenExitRequested;
@property(nonatomic, copy)RCTBubblingEventBlock onSeek;
@property(nonatomic, copy)RCTBubblingEventBlock onSeeked;
@property(nonatomic, copy)RCTBubblingEventBlock onPlaylist;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerReady;
@property(nonatomic, copy)RCTBubblingEventBlock onControlBarVisible;
@property(nonatomic, copy)RCTBubblingEventBlock onBeforeComplete;
@property(nonatomic, copy)RCTBubblingEventBlock onComplete;
@property(nonatomic, copy)RCTBubblingEventBlock onAdPlay;
@property(nonatomic, copy)RCTBubblingEventBlock onAdPause;

@property(nonatomic, copy)RCTBubblingEventBlock onCastingDevicesAvailable;
@property(nonatomic, copy)RCTBubblingEventBlock onConnectedToCastingDevice;
@property(nonatomic, copy)RCTBubblingEventBlock onDisconnectedFromCastingDevice;
@property(nonatomic, copy)RCTBubblingEventBlock onConnectionTemporarilySuspended;
@property(nonatomic, copy)RCTBubblingEventBlock onConnectionRecovered;
@property(nonatomic, copy)RCTBubblingEventBlock onConnectionFailed;
@property(nonatomic, copy)RCTBubblingEventBlock onCasting;
@property(nonatomic, copy)RCTBubblingEventBlock onCastingEnded;
@property(nonatomic, copy)RCTBubblingEventBlock onCastingFailed;

-(void)onRNJWReady;
-(void)onRNJWPlaylist;
-(void)onRNJWPlayerBeforePlay;
-(void)onRNJWPlayerPlay;
-(void)onRNJWPlayerPause;
-(void)onRNJWPlayerBuffer;
-(void)onRNJWPlayerIdle;
-(void)onRNJWPlayerPlaylistItem:(JWEvent<JWPlaylistItemEvent> *)event;
-(void)onRNJWSetupPlayerError:(JWEvent<JWErrorEvent> *)event;
-(void)onRNJWPlayerError:(JWEvent<JWErrorEvent> *)event;
-(void)onRNJWPlayerTime:(JWEvent<JWTimeEvent> *)event;
-(void)onRNJWFullScreen:(JWEvent<JWFullscreenEvent> *)event;
-(void)onRNJWFullScreenRequested:(JWEvent<JWFullscreenEvent> *)event;
-(void)onRNJWPlayerSeek:(JWEvent<JWSeekEvent> *)event;
-(void)onRNJWPlayerSeeked;
-(void)onRNJWControlBarVisible:(JWEvent<JWControlsEvent> *)event;
-(void)onRNJWPlayerBeforeComplete;
-(void)onRNJWPlayerComplete;
-(void)onRNJWPlayerAdPlay:(JWAdEvent<JWAdStateChangeEvent> *)event;
-(void)onRNJWPlayerAdPause:(JWAdEvent<JWAdStateChangeEvent> *)event;

-(JWConfig*)setupConfig;
-(void)customStyle: (JWConfig*)config :(NSString*)name;
-(void)setupColors: (JWConfig*)config;
-(void)reset;
-(void)setPlaylistItem:(NSDictionary *)playlistItem;
-(void)setPlaylist:(NSArray *)playlist;
- (void)showCastButton:(CGFloat)x :(CGFloat)y :(CGFloat)width :(CGFloat)height :(BOOL)autoHide :(BOOL)customButton;
-(void)hideCastButton;
- (void)setUpCastController;
- (void)presentCastDialog;
- (GCKCastState)castState;
- (JWCastingDevice*)connectedDevice;
- (NSArray <JWCastingDevice *>*)availableDevices;
- (void)showAirPlayButton:(CGFloat)x :(CGFloat)y :(CGFloat)width :(CGFloat)height :(BOOL)autoHide;
-(void)hideAirPlayButton;

- (void)onRNJWCastingDevicesAvailable:(NSArray <JWCastingDevice *> *)devices;
- (void)onRNJWConnectedToCastingDevice:(JWCastingDevice *)device;
- (void)onRNJWDisconnectedFromCastingDevice:(NSError *)error;
- (void)onRNJWConnectionTemporarilySuspended;
- (void)onRNJWConnectionRecovered;
- (void)onRNJWConnectionFailed:(NSError *)error;
- (void)onRNJWCasting;
- (void)onRNJWCastingEnded:(NSError *)error;
- (void)onRNJWCastingFailed:(NSError *)error;

@end
