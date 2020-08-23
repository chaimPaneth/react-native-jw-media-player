//
//  RNJWPlayerControls.m
//  A0Auth0
//
//  Created by Chaim Paneth on 8/23/20.
//

#import "RNJWPlayerControls.h"

NSString * const LIVEString = @"LIVE";
NSString * const DefaultTimeString = @"00:00";

@implementation RNJWPlayerControls

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)initialize:(JWPlayerController*)player
{
    _player = player;
    _player.config.controls = false;
    [_player.view addSubview:self];
    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _indicatorView.color = [UIColor colorWithRed:234/255 green:52/255 blue:76/255 alpha:1];
    [_player.view addSubview: _indicatorView];
    [_player.view bringSubviewToFront: _indicatorView];
    [self constraintToCenter:_indicatorView toView:_player.view];
    
    _playbackButton = [[UIButton alloc] init];
    [_playbackButton setTintColor:UIColor.whiteColor];
    [_playbackButton setImage:[[UIImage imageNamed:@"icons8-play-100"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_playbackButton setImage:[[UIImage imageNamed:@"icons8-pause-100"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [self addSubview:_playbackButton];
    
    _rewindButton = [[UIButton alloc] init];
    [_rewindButton setTintColor:UIColor.whiteColor];
    [_rewindButton setImage:[[UIImage imageNamed:@"icons8-rewind-10-100"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self addSubview:_rewindButton];
    
    _forwardButton = [[UIButton alloc] init];
    [_forwardButton setTintColor:UIColor.whiteColor];
    [_forwardButton setImage:[[UIImage imageNamed:@"icons8-forward-10-100"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self addSubview:_forwardButton];
    
    _audioButton = [[UIButton alloc] init];
    [_audioButton setTintColor:UIColor.whiteColor];
    [_audioButton setImage:[[UIImage imageNamed:@"icons8-audio-100"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_audioButton setImage:[[UIImage imageNamed:@"icons8-mute-100"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [self addSubview:_audioButton];
    
    _fullscreenButton = [[UIButton alloc] init];
    [_fullscreenButton setTintColor:UIColor.whiteColor];
    [_fullscreenButton setImage:[[UIImage imageNamed:@"icons8-full-screen-100"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_fullscreenButton setImage:[[UIImage imageNamed:@"icons8-normal-screen-100"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [self addSubview:_fullscreenButton];
    
    [_playbackButton addTarget:self action:@selector(playbackButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_rewindButton addTarget:self action:@selector(rewindButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_forwardButton addTarget:self action:@selector(forwardButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    _timeLabel = [[UILabel alloc] init];
    [_timeLabel setTextColor:UIColor.whiteColor];
    [self addSubview:_timeLabel];
    
    _timeSlider = [[UISlider alloc] init];
    [_timeSlider setMinimumTrackTintColor:UIColor.grayColor];
    [_timeSlider setMaximumTrackTintColor:UIColor.grayColor];
    [self addSubview:_timeSlider];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChangedNotification:) name:JWPlayerStateChangedNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JWPlayerStateChangedNotification object:nil];
}

- (void)resetPlayerUI {
    [self.playbackButton setSelected:NO];
    self.timeLabel.text = DefaultTimeString;
    self.timeSlider.value = 0;
}

- (void)toggleControlsView:(BOOL)enabled
{
    [_rewindButton setEnabled:enabled];
    [_playbackButton setEnabled:enabled];
    [_forwardButton setEnabled:enabled];
    [_fullscreenButton setEnabled:enabled];
}

- (NSString*)timeFormatted: (int)input
{
    int absInput = abs(input);
    int seconds = absInput % 60;
    int minutes = (absInput / 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    /* ** Remove this comment if you want to calculate hours **
    let hours: Int = absInput / 3600
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)*/
}

// MARK: - Actions

- (void)playbackButtonTapped
{
    if (_player != nil) {
        switch (_player.state) {
            case JWPlayerStatePlaying:
                [_player pause];
                break;
            case JWPlayerStatePaused:
            case JWPlayerStateComplete:
            case JWPlayerStateIdle:
                [_player play];
                break;
                
            default:
                break;
        }
    }
}

- (void)rewindButtonTapped {
    if (_player != nil) {
        int newPosition = MAX(0, _player.position - 10);
        [_player seek:newPosition];
    }
}

- (void)forwardButtonTapped {
    if (_player != nil) {
        int newPosition = MAX(0, _player.position + 10);
        [_player seek:newPosition];
    }
}

- (void)toggleMuteButtonTapped {
    if (_player != nil) {
        if (_player.volume > 0) {
            _player.volume = 0;
            [_audioButton setSelected:YES];
        } else {
            _player.volume = 1;
            [_audioButton setSelected:NO];
        }
    }
}

- (void)timeSliderValueChanged:(UISlider*)sender {
    if (_player != nil) {
        CGFloat videoDuration = _player.duration;
        
        int newPosition = round(sender.value * videoDuration);
        if (videoDuration < 0) {
            // Seek video to input position
            [_player seek:MAX(0, abs(newPosition))];
            _timeLabel.text = [NSString stringWithFormat:@"%@-%@", LIVEString, [self timeFormatted: newPosition]];
        } else {
            [_player seek:newPosition];
            _timeLabel.text = [self timeFormatted: newPosition];
        }
    }
}

- (void)fullscreenButtonTapped {
    if (_player != nil) {
        BOOL fullscreenEnabled = !_player.fullscreen;
        _player.fullscreen = fullscreenEnabled;
        [_fullscreenButton setSelected:fullscreenEnabled];
    }
}

// MARK: - Notifications

- (void)stateChangedNotification:(NSNotification*)notification {
    id stateInfo = notification.userInfo;
    if (stateInfo) {
        id oldStateRaw = stateInfo[@"oldstate"];
        id newStateRaw = stateInfo[@"newstate"];
        
        if ([newStateRaw intValue] == JWPlayerStateComplete) {
            
        } else if ([newStateRaw intValue] == JWPlayerStatePlaying) {
            [_playbackButton setSelected:YES];
        } else if ([newStateRaw intValue] == JWPlayerStatePaused) {
            [_playbackButton setSelected:NO];
        } else if ([newStateRaw intValue] == JWPlayerStateBuffering) {
            [self.indicatorView startAnimating];
        }
        
        if ([oldStateRaw intValue] == JWPlayerStateBuffering ||
            [newStateRaw intValue] == JWPlayerStateComplete) {
            [self.indicatorView stopAnimating];
        }
    }
 }

// MARK: - JWPlayerDelegate implementation
    
-(void)onTime:(JWEvent<JWTimeEvent> *)event
{
    if (_player != nil) {
        if (_player.duration > 0) {
            // Enable controls used for normal streaming
            [_timeSlider setEnabled: YES];
            [_rewindButton setHidden:NO];
            [_forwardButton setHidden:NO];
            
            float progress = event.position / event.duration;
            _timeSlider.value = progress;
            _timeLabel.text = [self timeFormatted: event.position];
        } else {
            [_rewindButton setHidden:YES];
            [_forwardButton setHidden:YES];
            
            if (_player.duration == 0) {
                [_timeSlider setHidden:YES];
                _timeLabel.text = LIVEString;
            } else {
                [_timeSlider setHidden:NO];
                
                float absPosition = fabs(event.position);
                float absDuration = fabs(_player.duration);
                float progress = absPosition / absDuration;
                self.timeSlider.value = progress;
                _timeLabel.text = [NSString stringWithFormat:@"%@-%@", LIVEString, [self timeFormatted: absPosition]];
            }
        }
    }
}
    
- (void)onFullScreen:(JWEvent<JWFullscreenEvent> *)event
{
    if (_player != nil) {
        if (event.fullscreen) {
            UIView *fullscreenView = _player.view;//UIApplication.sharedApplication.keyWindow;
            [self removeFromSuperview];
            [fullscreenView addSubview: self];
            [self constraintToFlexibleBottom:self toView:fullscreenView];
            [_indicatorView removeFromSuperview];
            [fullscreenView addSubview:_indicatorView];
            [self constraintToCenter:_indicatorView toView:fullscreenView];
        } else {
            [self removeFromSuperview];
            [_player.view addSubview:self];
            [self constraintToFlexibleBottom:self toView:_player.view];
            [_indicatorView removeFromSuperview];
            [_player.view addSubview:_indicatorView];
            [self constraintToCenter:_indicatorView toView:_player.view];
        }
    }
}

- (void)toggleControlsViewVisible:(BOOL)visible
{
    self.alpha = visible ? 1 : 0;
    [self toggleControlsView:visible];
}

// Layout helpers

- (void)constraintToFlexibleBottom:(UIView*)view toView:(UIView*)toView
{
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [rootViewController view].translatesAutoresizingMaskIntoConstraints = false;
    
    NSArray<NSLayoutConstraint *> *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[thisView]|" options:0 metrics:nil views:@{@"thisView": view}];
    
    NSArray<NSLayoutConstraint *> *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[thisView]|" options:NSLayoutFormatAlignAllBottom metrics:nil views:@{@"thisView": view}];
    
    [toView addConstraints:horizontalConstraints];
    [toView addConstraints:verticalConstraints];
}

- (void)constraintToCenter:(UIView*)view toView:(UIView*)toView
{
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [rootViewController view].translatesAutoresizingMaskIntoConstraints = false;
    
    NSArray<NSLayoutConstraint *> *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[thisView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"thisView": view}];
    
    NSArray<NSLayoutConstraint *> *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[thisView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:@{@"thisView": view}];
    
    [toView addConstraints:horizontalConstraints];
    [toView addConstraints:verticalConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect playbackButtonFrame = CGRectMake(self.frame.size.width / 2 - 15, self.frame.size.height / 2 - 15, 30, 30);
    _playbackButton.frame = playbackButtonFrame;
    
    CGRect rewindButtonFrame = CGRectMake(self.frame.size.width / 2 - 55, self.frame.size.height / 2 - 15, 30, 30);
    _rewindButton.frame = rewindButtonFrame;
    
    CGRect forwardButtonFrame = CGRectMake(self.frame.size.width / 2 + 25, self.frame.size.height / 2 - 15, 30, 30);
    _forwardButton.frame = forwardButtonFrame;
    
    CGRect audioButtonFrame = CGRectMake(self.frame.size.width - 86, self.frame.size.height / 2 - 15, 30, 30);
    _audioButton.frame = audioButtonFrame;
    
    CGRect fullscreenButtonFrame = CGRectMake(self.frame.size.width - 46, self.frame.size.height / 2 - 15, 30, 30);
    _fullscreenButton.frame = fullscreenButtonFrame;
    
    CGRect timeLabelFrame = CGRectMake(16, self.frame.size.height / 2 - 15, 60, 30);
    _timeLabel.frame = timeLabelFrame;
    
    CGRect timeSliderLabelFrame = CGRectMake(16, 16, _player.view.frame.size.width - 32, 5);
    _timeSlider.frame = timeSliderLabelFrame;
    [_timeSlider setThumbImage:[self makeRoundedImage:[self imageFromColor:UIColor.whiteColor] radius:4] forState:UIControlStateNormal];
}

- (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 8, 8);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)makeRoundedImage:(UIImage *) image
                      radius: (float) radius;
{
  CALayer *imageLayer = [CALayer layer];
  imageLayer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
  imageLayer.contents = (id) image.CGImage;

  imageLayer.masksToBounds = YES;
  imageLayer.cornerRadius = radius;

  UIGraphicsBeginImageContext(image.size);
  [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return roundedImage;
}

@end
