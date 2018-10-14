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
    //config.controls = _controls;
    //config.repeat = _repeat;
    //config.skin = JWPremiumSkinSeven;
    //config.autostart = _autostart;
    //config.mediaId = @"vSsMLwzp";
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

-(void)setMediaId:(NSString *)mediaId
{
    self.player.config.mediaId = mediaId;
}

-(NSString *)mediaId
{
    return self.player.config.mediaId;
}

-(void)setTitle:(NSString *)title
{
    self.player.config.title = title;
}

-(NSString *)title
{
    return self.player.config.title;
}

-(void)setDesc:(NSString *)desc
{
    self.player.config.desc = desc;
}

-(NSString *)desc
{
    return self.player.config.desc;
}

-(void)setAutostart:(BOOL)autostart
{
    self.player.config.autostart = autostart;
    //[self.player play];
}

-(BOOL)autostart
{
    return self.player.config.autostart;
}

-(void)setControls:(BOOL)controls
{
    self.player.config.controls = controls;
    //[self.player play];
}

-(BOOL)controls
{
    return self.player.config.controls;
}

-(void)setRepeat:(BOOL)repeat
{
    self.player.config.repeat = repeat;
    //[self.player play];
}

-(BOOL)repeat
{
    return self.player.config.repeat;
}

-(void)setDisplayDesc:(BOOL)displayDesc
{
    self.player.config.displayDescription = displayDesc;
}

-(BOOL)displayDesc
{
    return self.player.config.displayDescription;
}

-(void)setDisplayTitle:(BOOL)displayTitle
{
    self.player.config.displayTitle = displayTitle;
}

-(BOOL)displayTitle
{
    return self.player.config.displayTitle;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.player.view.frame = self.frame;
}

-(BOOL)shouldAutorotate {
    return NO;
}

-(void)setPlayListItem:(NSDictionary *)playListItem
{
    self.player.config.file = [playListItem objectForKey:@"file"];
    self.player.config.mediaId = [playListItem objectForKey:@"mediaId"];
    [self.player play];
}

-(NSDictionary *)playListItem
{
    NSString *file = @"";
    NSString *mediaId = @"";
    
    if (self.player.config.file != nil) {
        file = self.player.config.file;
    }
    
    if (self.player.config.mediaId != nil) {
        mediaId = self.player.config.mediaId;
    }
    
    NSMutableDictionary *playListItemDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [playListItemDict setObject:file forKey:@"file"];
    [playListItemDict setObject:mediaId forKey:@"mediaId"];
    
    return playListItemDict;
}

-(void)setPlayList:(NSArray *)playList
{
    NSMutableArray <JWPlaylistItem *> *playlistArray = [[NSMutableArray alloc] init];
    for (id item in playList) {
        JWPlaylistItem *playListItem = [JWPlaylistItem new];
        playListItem.file = [item objectForKey:@"file"];
        playListItem.mediaId = [item objectForKey:@"mediaId"];
        [playlistArray addObject:playListItem];
    }
    
    [self.player load:playlistArray];
    [self.player play];
}

-(NSArray *)playList
{
    return self.player.config.playlist;
}

#pragma mark - RNJWPlayer Delegate

-(void)onRNJWPlayerBeforePlay
{
    if (self.onBeforePlay) {
        self.onBeforePlay(@{});
    }
}

-(void)onRNJWPlayerPlay
{
    if (self.onPlay) {
        self.onPlay(@{});
    }
}

-(void)onRNJWPlayerPause
{
    if (self.onPause) {
        self.onPause(@{});
    }
}

-(void)onRNJWPlayerBuffer
{
    if (self.onBuffer) {
        self.onBuffer(@{});
    }
}

-(void)onRNJWSetupPlayerError:(JWEvent<JWErrorEvent> *)event
{
    if (self.onSetupPlayerError) {
        self.onSetupPlayerError(@{@"error": event.error});
    }
}

-(void)onRNJWPlayerError:(JWEvent<JWErrorEvent> *)event
{
    if (self.onPlayerError) {
        self.onPlayerError(@{@"error": event.error});
    }
}

-(void)onRNJWPlayerTime:(JWEvent<JWTimeEvent> *)event
{
    if (self.onTime) {
        self.onTime(@{@"position": @(event.position), @"duration": @(event.duration)});
    }
}

-(void)onRNJWFullScreen:(JWEvent<JWFullscreenEvent> *)event
{
    if(event && [[event valueForKey:@"_fullscreen"] boolValue]){
    if (self.onFullScreen) {
        self.onFullScreen(@{});
    }
    }else{
        if (self.onFullScreenExit){
            [[UIDevice currentDevice] setValue:
             [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                        forKey:@"orientation"];
            self.onFullScreenExit(@{});
        }
    }

}

-(void)onRNJWFullScreenRequested:(JWEvent<JWFullscreenEvent> *)event
{
    if([[event valueForKey:@"_fullscreen"] boolValue]){
    if (self.onFullScreenRequested) {
        self.onFullScreenRequested(@{});
    }
    }else{
        if (self.onFullScreenExitRequested) {
            self.onFullScreenExitRequested(@{});
        }
    }
}

-(void)onRNJWFullScreenExitRequested:(JWEvent<JWFullscreenEvent> *)event
{
    if (self.onFullScreenExitRequested) {
        self.onFullScreenExitRequested(@{});
    }
}

-(void)onRNJWFullScreenExit:(JWEvent<JWFullscreenEvent> *)event
{
    if (self.onFullScreenExit){
        self.onFullScreenExit(@{});
    }
}

@end
