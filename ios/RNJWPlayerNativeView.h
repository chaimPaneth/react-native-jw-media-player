#import "React/RCTViewManager.h"
#import <JWPlayer-SDK/JWPlayerController.h>
#import <UIKit/UIKit.h>

@interface RNJWPlayerNativeView : UIView
@property(nonatomic, strong)JWPlayerController *player;
@property(nonatomic, strong)NSString *file;
@property(nonatomic)BOOL autostart;
@property(nonatomic, copy)RCTBubblingEventBlock onBeforePlay;
@property(nonatomic, copy)RCTBubblingEventBlock onPlay;
@property(nonatomic, copy)RCTBubblingEventBlock onBuffer;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerError;
@property(nonatomic, copy)RCTBubblingEventBlock onTime;
-(void)onRNJWPlayerBeforePlay;
-(void)onRNJWPlayerPlay;
-(void)onRNJWPlayerBuffer;
-(void)onRNJWPlayerError:(NSError *)error;
-(void)onRNJWPlayerTime:(double)position ofDuration:(double)duration;
@end
