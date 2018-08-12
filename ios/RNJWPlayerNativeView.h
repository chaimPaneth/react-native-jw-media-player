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
@property(nonatomic, copy)RCTBubblingEventBlock onBeforePlay;
@property(nonatomic, copy)RCTBubblingEventBlock onPlay;
@property(nonatomic, copy)RCTBubblingEventBlock onPause;
@property(nonatomic, copy)RCTBubblingEventBlock onBuffer;
@property(nonatomic, copy)RCTBubblingEventBlock onSetupPlayerError;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerError;
@property(nonatomic, copy)RCTBubblingEventBlock onTime;
-(void)onRNJWPlayerBeforePlay;
-(void)onRNJWPlayerPlay;
-(void)onRNJWPlayerPause;
-(void)onRNJWPlayerBuffer;
-(void)onRNJWSetupPlayerError:(JWEvent<JWErrorEvent> *)event;
-(void)onRNJWPlayerError:(JWEvent<JWErrorEvent> *)event;
-(void)onRNJWPlayerTime:(JWEvent<JWTimeEvent> *)event;
@end
