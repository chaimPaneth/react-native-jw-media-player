//
//  RNJWPlayerControls.h
//  A0Auth0
//
//  Created by Chaim Paneth on 8/23/20.
//

#import <UIKit/UIKit.h>
#import <JWPlayer_iOS_SDK/JWPlayerController.h>

@interface RNJWPlayerControls : UIView

@property (nonatomic) JWPlayerController *player;
@property (nonatomic) UIButton *rewindButton;
@property (nonatomic) UIButton *playbackButton;
@property (nonatomic) UIButton *forwardButton;
@property (nonatomic) UIButton *audioButton;
@property (nonatomic) UIButton *fullscreenButton;
@property (nonatomic) UILabel *timeElapsedLabel;
@property (nonatomic) UILabel *timeRemainingLabel;
@property (nonatomic) UISlider *timeSlider;
@property (nonatomic) UIActivityIndicatorView *indicatorView;

- (void)initialize:(JWPlayerController*)player;
- (void)toggleControlsViewVisible:(BOOL)visible;
- (void)onFullScreen:(JWEvent<JWFullscreenEvent> *)event;
- (void)onTime:(JWEvent<JWTimeEvent> *)event;

@end
