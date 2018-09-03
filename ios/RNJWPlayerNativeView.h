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
@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSString *image;
@property(nonatomic, strong)NSString *desc;
@property(nonatomic, strong)NSString *mediaId;

@property(nonatomic, copy)RCTBubblingEventBlock onBeforePlay;
@property(nonatomic, copy)RCTBubblingEventBlock onPlay;
@property(nonatomic, copy)RCTBubblingEventBlock onPause;
@property(nonatomic, copy)RCTBubblingEventBlock onBuffer;
@property(nonatomic, copy)RCTBubblingEventBlock onSetupPlayerError;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerError;
@property(nonatomic, copy)RCTBubblingEventBlock onTime;
@property(nonatomic, copy)RCTBubblingEventBlock onFullScreen;
@property(nonatomic, copy)RCTBubblingEventBlock onFullScreenRequested;
@property(nonatomic, copy)RCTBubblingEventBlock onFullScreenExit;
@property(nonatomic, copy)RCTBubblingEventBlock onFullScreenExitRequested;

-(void)onRNJWPlayerBeforePlay;
-(void)onRNJWPlayerPlay;
-(void)onRNJWPlayerPause;
-(void)onRNJWPlayerBuffer;
-(void)onRNJWSetupPlayerError:(JWEvent<JWErrorEvent> *)event;
-(void)onRNJWPlayerError:(JWEvent<JWErrorEvent> *)event;
-(void)onRNJWPlayerTime:(JWEvent<JWTimeEvent> *)event;
-(void)onRNJWFullScreen:(JWEvent<JWFullscreenEvent> *)event;
-(void)onRNJWFullScreenRequested:(JWEvent<JWFullscreenEvent> *)event;
-(void)onRNJWFullScreenExit:(JWEvent<JWFullscreenEvent> *)event;
-(void)onRNJWFullScreenExitRequested:(JWEvent<JWFullscreenEvent> *)event;

@end
