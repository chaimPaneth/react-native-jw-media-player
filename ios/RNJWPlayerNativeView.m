#import "RNJWPlayerNativeView.h"
#import "RNJWPlayerDelegateProxy.h"

@implementation RNJWPlayerNativeView

- (instancetype)init
{
    if (self = [super init]) {
        [self addSubview:self.player.view];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInterruptionPause:) name:@"onInterruption" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInterruptionPlay:) name:@"onInterruptionRelease" object:nil];

    return self;
}

-(void)onInterruptionPause:(NSNotification *)notification {
    if (self.onPause) {
        self.onPause(@{});
    }
    NSLog(@" Do something ");
}

-(void)onInterruptionPlay:(NSNotification *)notification {
    if (self.onPlay) {
        self.onPlay(@{});
    }
    NSLog(@" Do something ");
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
    if(file.length > 0){

//        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        NSString *searchFilename = [documentsPath stringByAppendingString:@"/OUTorah/01NetzachYisrael-0.mp4"];
//        NSString *searchFilename1 = [NSString stringWithFormat:@"file://%@",searchFilename];
        NSString* encodedUrl = [file stringByAddingPercentEscapesUsingEncoding:
                                NSUTF8StringEncoding];

        self.player.config.file = encodedUrl;

    [self.player play];
}
}

-(NSString *)file
{
    return self.player.config.file;
}

-(void)setMediaId:(NSString *)mediaId
{
    if(mediaId != nil){
    self.player.config.mediaId = mediaId;
}
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

-(void)setNextUpDisplay:(BOOL)nextUpDisplay
{
    self.player.config.nextUpDisplay = nextUpDisplay;
}

-(BOOL)nextUpDisplay
{
    return self.player.config.nextUpDisplay;
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
    self.player.config.title = [playListItem objectForKey:@"title"];
    self.player.config.desc = [playListItem objectForKey:@"desc"];
    self.player.config.autostart = [[playListItem objectForKey:@"autostart"] boolValue];
    self.player.config.controls = [[playListItem objectForKey:@"controls"] boolValue];
    self.player.config.repeat = [[playListItem objectForKey:@"repeat"] boolValue];
    self.player.config.displayDescription = [[playListItem objectForKey:@"displayDesc"] boolValue];
    self.player.config.displayTitle = [[playListItem objectForKey:@"displayTitle"] boolValue];
    [self.player play];
}

-(NSDictionary *)playListItem
{
    NSString *file = @"";
    NSString *mediaId = @"";
    NSString *title = @"";
    NSString *desc = @"";
    BOOL autostart = true;
    BOOL controls = true;
    BOOL repeat = false;
    BOOL displayDesc = false;
    BOOL displayTitle = false;



    if (self.player.config.file != nil) {
        file = self.player.config.file;
    }

    if (self.player.config.mediaId != nil) {
        mediaId = self.player.config.mediaId;
    }

    if (self.player.config.title != nil) {
        title = self.player.config.title;
    }

    if (self.player.config.desc != nil) {
        desc = self.player.config.desc;
    }

    if (self.player.config.autostart) {
        autostart = self.player.config.autostart;
    }

    if (self.player.config.controls) {
        controls = self.player.config.controls;
    }

    if (self.player.config.repeat) {
        repeat = self.player.config.repeat;
    }

    if (self.player.config.displayDescription) {
        displayDesc = self.player.config.displayDescription;
    }

    if (self.player.config.displayTitle) {
        displayTitle = self.player.config.displayTitle;
    }


    NSMutableDictionary *playListItemDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    [playListItemDict setObject:file forKey:@"file"];
    [playListItemDict setObject:mediaId forKey:@"mediaId"];
    [playListItemDict setObject:title forKey:@"title"];
    [playListItemDict setObject:desc forKey:@"desc"];
    [playListItemDict setObject:[NSNumber numberWithBool:autostart]  forKey:@"autostart"];
    [playListItemDict setObject:[NSNumber numberWithBool:controls]  forKey:@"controls"];
    [playListItemDict setObject:[NSNumber numberWithBool:repeat]  forKey:@"repeat"];
    [playListItemDict setObject:[NSNumber numberWithBool:displayDesc]  forKey:@"displayDesc"];
    [playListItemDict setObject:[NSNumber numberWithBool:displayTitle]  forKey:@"displayTitle"];

    return playListItemDict;
}

-(void)setPlayList:(NSArray *)playList
{
    NSMutableArray <JWPlaylistItem *> *playlistArray = [[NSMutableArray alloc] init];
    for (id item in playList) {
        JWPlaylistItem *playListItem = [JWPlaylistItem new];
        playListItem.file = [item objectForKey:@"file"];
        playListItem.image = [item objectForKey:@"image"];
        playListItem.title = [item objectForKey:@"title"];
        playListItem.desc = [item objectForKey:@"desc"];
        playListItem.mediaId = [item objectForKey:@"mediaId"];

        [playlistArray addObject:playListItem];
    }

    self.player.config.playlist = playlistArray;
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

-(void)onRNJWPlayerIdle
{
    if (self.onIdle) {
        self.onIdle(@{});
    }
}

-(void)onRNJWPlayerPlaylistItem:(JWEvent<JWPlaylistItemEvent> *)event
{
   if (self.onPlaylistItem) {

       NSError *error;
       NSString *file = @"";
       NSString *mediaId = @"";
       NSString *title = @"";
       NSString *desc = @"";

       if (event.item.file != nil) {
           file = event.item.file;
       }

       if (event.item.mediaId != nil) {
           mediaId = event.item.mediaId;
       }

       if (event.item.title != nil) {
           title = event.item.title;
       }

       if (event.item.desc != nil) {
           desc = event.item.desc;
       }

       NSMutableDictionary *playListItemDict = [[NSMutableDictionary alloc] init];
       [playListItemDict setObject:file forKey:@"file"];
       [playListItemDict setObject:mediaId forKey:@"mediaId"];
       [playListItemDict setObject:title forKey:@"title"];
       [playListItemDict setObject:desc forKey:@"desc"];

       NSData *data = [NSJSONSerialization dataWithJSONObject:playListItemDict options:NSJSONWritingPrettyPrinted error: &error];

        self.onPlaylistItem(@{@"playListItem": [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]});
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
