#import "React/RCTViewManager.h"
#import <JWPlayer_iOS_SDK/JWPlayerController.h>
#import <UIKit/UIKit.h>
#import "RNJWPlayerDelegateProxy.h"

@class RNJWPlayerDelegateProxy;

@interface RNJWPlayerNativeView : UIView

@property(nonatomic, strong)JWPlayerController *player;
@property(nonatomic, strong)RNJWPlayerDelegateProxy *proxy;

@property(nonatomic, strong)NSString *file;
@property(nonatomic)BOOL autostart;
@property(nonatomic)BOOL controls;
@property(nonatomic)BOOL repeat;
@property(nonatomic)BOOL displayTitle;
@property(nonatomic)BOOL displayDesc;
@property(nonatomic)BOOL nextUpDisplay;
@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSString *image;
@property(nonatomic, strong)NSString *desc;
@property(nonatomic, strong)NSString *mediaId;

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
@property(nonatomic, copy)RCTBubblingEventBlock onPlaylist;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerReady;
@property(nonatomic, copy)RCTBubblingEventBlock onControlBarVisible;

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
-(void)onRNJWFullScreenExit:(JWEvent<JWFullscreenEvent> *)event;
-(void)onRNJWFullScreenExitRequested:(JWEvent<JWFullscreenEvent> *)event;
-(void)onRNJWPlayerSeek:(JWEvent<JWSeekEvent> *)event;
-(void)onRNJWControlBarVisible:(JWEvent<JWControlsEvent> *)event;

-(JWConfig*)setupConfig;
-(void)defaultStyle: (JWConfig*)config;
-(void)customStyle: (JWConfig*)config :(NSString*)name;
-(void)reset;

@end
