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
        
        _proxy = [RNJWPlayerDelegateProxy new];
        _proxy.delegate = self;
        
        _player = [[JWPlayerController alloc] initWithConfig:config delegate:_proxy];
        
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
    //config.skin = JWPremiumSkinSeven;
    config.autostart = YES;
    config.stretching = JWStretchingUniform;
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

-(void)onRNJWPlayerPause {
    if (self.onPause) {
        self.onPause(@{});
    }
}

-(void)onRNJWPlayerBuffer {
    if (self.onBuffer) {
        self.onBuffer(@{});
    }
}

-(void)onRNJWSetupPlayerError:(JWEvent<JWErrorEvent> *)event {
    if (self.onSetupPlayerError) {
        self.onSetupPlayerError(@{@"error": event.error});
    }
}

-(void)onRNJWPlayerError:(JWEvent<JWErrorEvent> *)event {
    if (self.onPlayerError) {
        self.onPlayerError(@{@"error": event.error});
    }
}

-(void)onRNJWPlayerTime:(JWEvent<JWTimeEvent> *)event {
    if (self.onTime) {
        self.onTime(@{@"position": @(event.position), @"duration": @(event.duration)});
    }
}

@end
