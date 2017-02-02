#import "RNJWPlayerNativeView.h"
#import "RNJWPlayerDelegateProxy.h"

@implementation RNJWPlayerNativeView

- (instancetype)init
{
    if (self = [super init]) {
        [self addSubview:self.player.view];
    }
    return self;
}

- (JWPlayerController *)player {
    if (!_player) {
        JWConfig *config = [self setupConfig];
        
        RNJWPlayerDelegateProxy *proxy = [RNJWPlayerDelegateProxy new];
        proxy.delegate = self;
        _player = [[JWPlayerController alloc] initWithConfig:config delegate:proxy];
        
        _player.forceFullScreenOnLandscape = YES;
        _player.forceLandscapeOnFullScreen = YES;
    }
    
    return _player;
}

-(JWConfig*)setupConfig
{
    JWConfig *config = [JWConfig new];
    config.controls = YES;
    config.repeat = NO;
    config.premiumSkin = JWPremiumSkinSeven;
    config.autostart = YES;
    config.stretch = JWStretchUniform;
    return config;
}

-(void)setFile:(NSString *)file
{
    self.player.config.file = file;
    [self.player play];
}

-(NSString *)file
{
    return self.player.config.file;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.player.view.frame = self.frame;
}

#pragma mark - RNJWPlayer Delegate

-(void)onRNJWPlayerBeforePlay {
    if (self.onBeforePlay) {
        self.onBeforePlay(@{});
    }
}

-(void)onRNJWPlayerPlay {
    if (self.onPlay) {
        self.onPlay(@{});
    }
}

-(void)onRNJWPlayerBuffer {
    if (self.onBuffer) {
        self.onBuffer(@{});
    }
}

-(void)onRNJWPlayerError:(NSError *)error {
    if (self.onPlayerError) {
        self.onPlayerError(@{@"message": error.localizedDescription, @"info": error.userInfo});
    }
}

-(void)onRNJWPlayerTime:(double)position ofDuration:(double)duration {
    if (self.onTime) {
        self.onTime(@{@"position": @(position), @"duration": @(duration)});
    }
}

@end
