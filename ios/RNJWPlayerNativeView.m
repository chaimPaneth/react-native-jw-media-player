#import "RNJWPlayerNativeView.h"
#import "RNJWPlayerDelegateProxy.h"
#import "CustomJWPlaylistItem.h"
#import <AVFoundation/AVFoundation.h>

NSString* const AudioInterruptionsStarted = @"AudioInterruptionsStarted";
NSString* const AudioInterruptionsEnded = @"AudioInterruptionsEnded";

@implementation RNJWPlayerNativeView

- (id)init {
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterruptionsStarted:) name:AudioInterruptionsStarted object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterruptionsEnded:) name:AudioInterruptionsEnded object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:AudioInterruptionsStarted];
    [[NSNotificationCenter defaultCenter] removeObserver:AudioInterruptionsEnded];
}

-(void)customStyle: (JWConfig*)config :(NSString*)name
{
    config.stretching = JWStretchingUniform;
    
    JWSkinStyling *skinStyling = [JWSkinStyling new];
    config.skin = skinStyling;
    
    skinStyling.url = [NSString stringWithFormat:@"file://%@", [[NSBundle mainBundle] pathForResource:name ofType:@"css"]];
    skinStyling.name = name;
}

-(void)defaultStyle: (JWConfig*)config
{
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green: g/255.0 blue:b/255.0 alpha:a]
    
    //config.skin = JWPremiumSkinSeven;
    //config.preload = JWPreloadNone;
    config.stretching = JWStretchingUniform;
    
    JWSkinStyling *skinStyling = [JWSkinStyling new];
    config.skin = skinStyling;
    
    JWControlbarStyling *controlbarStyling = [JWControlbarStyling new];
    controlbarStyling.icons = RGBA(231,236,239,0.7);
    skinStyling.controlbar = controlbarStyling;
    
    JWTimesliderStyling *timesliderStyling = [JWTimesliderStyling new];
    timesliderStyling.progress = RGBA(58,94,166,1);
    timesliderStyling.rail = RGBA(255,255,255,1);
    skinStyling.timeslider = timesliderStyling;
}

-(JWConfig*)setupConfig
{
    JWConfig *config = [JWConfig new];
    
    config.controls = YES;
    config.repeat = NO;
    config.displayDescription = YES;
    config.displayTitle = YES;
    
    return config;
}

-(void)setPlayerStyle:(NSString *)playerStyle
{
    if (playerStyle != nil) {
        [self customStyle:self.player.config :playerStyle];
    }
}

-(void)setFile:(NSString *)file
{
    NSString* encodedUrl = [file stringByAddingPercentEscapesUsingEncoding:
                            NSUTF8StringEncoding];
    if (file != nil && file.length > 0 && ![encodedUrl isEqualToString:_player.config.file]) {
        self.player.config.file = encodedUrl;
    }
}

-(NSString *)file
{
    return self.player.config.file;
}

-(void)setMediaId:(NSString *)mediaId
{
    if(mediaId != nil && mediaId.length > 0 && ![mediaId isEqualToString:_player.config.mediaId]) {
        self.player.config.mediaId = mediaId;
    }
}

-(NSString *)mediaId
{
    return self.player.config.mediaId;
}

-(void)setTitle:(NSString *)title
{
    if(title != nil && title.length > 0 && ![title isEqualToString:_player.config.title]) {
        self.player.config.title = title;
    }
}

-(NSString *)title
{
    return self.player.config.title;
}

-(void)setImage:(NSString *)image
{
    if(image != nil && image.length > 0 && ![image isEqualToString:_player.config.image]) {
        self.player.config.image = image;
    }
}

-(NSString *)image
{
    return self.player.config.image;
}

-(void)setDesc:(NSString *)desc
{
    if(desc != nil && desc.length > 0 && ![desc isEqualToString:_player.config.desc]) {
        self.player.config.desc = desc;
    }
}

-(NSString *)desc
{
    return self.player.config.desc;
}

-(void)setAutostart:(BOOL)autostart
{
    if(autostart != self.player.config.autostart) {
        self.player.config.autostart = autostart;
    }
}

-(BOOL)autostart
{
    return self.player.config.autostart;
}

-(void)setControls:(BOOL)controls
{
    if(controls != self.player.controls) {
        self.player.config.controls = controls;
        self.player.controls = controls;
    }
}

-(BOOL)controls
{
    return self.player.controls;
}

-(void)setRepeat:(BOOL)repeat
{
    if(repeat != self.player.config.repeat) {
        self.player.config.repeat = repeat;
    }
}

-(BOOL)repeat
{
    return self.player.config.repeat;
}

-(void)setDisplayDesc:(BOOL)displayDesc
{
    if(displayDesc != self.player.config.displayDescription) {
        self.player.config.displayDescription = displayDesc;
    }
}

-(BOOL)displayDesc
{
    return self.player.config.displayDescription;
}

-(void)setDisplayTitle:(BOOL)displayTitle
{
    if(displayTitle != self.player.config.displayTitle) {
        self.player.config.displayTitle = displayTitle;
    }
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
    
    if (self.player != nil) {
        self.player.view.frame = self.frame;
    }
}

-(BOOL)shouldAutorotate {
    return NO;
}

-(void)addObserevers
{
    [[NSNotificationCenter defaultCenter] removeObserver:AudioInterruptionsStarted];
    [[NSNotificationCenter defaultCenter] removeObserver:AudioInterruptionsEnded];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterruptionsStarted:) name:AudioInterruptionsStarted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterruptionsEnded:) name:AudioInterruptionsEnded object:nil];
}

-(void)setPlaylistItem:(NSDictionary *)playlistItem
{
    NSString *newFile = [playlistItem objectForKey:@"file"];
    NSString* encodedUrl = [newFile stringByAddingPercentEscapesUsingEncoding:
                            NSUTF8StringEncoding];
    
    if (newFile != nil && newFile.length > 0) {
        [self reset];
        
        JWConfig *config = [self setupConfig];
        
        id playerStyle = [playlistItem objectForKey:@"playerStyle"];
        if (playerStyle != nil) {
            [self customStyle:config :playerStyle];
        } else {
            [self defaultStyle:config];
        }
            
        config.file = encodedUrl;
        config.mediaId = [playlistItem objectForKey:@"mediaId"];
        config.title = [playlistItem objectForKey:@"title"];
        config.desc = [playlistItem objectForKey:@"desc"];
        config.image = [playlistItem objectForKey:@"image"];
        
        config.autostart = [[playlistItem objectForKey:@"autostart"] boolValue];
        
        _proxy = [RNJWPlayerDelegateProxy new];
        _proxy.delegate = self;
        
        _player = [[JWPlayerController alloc] initWithConfig:config delegate:_proxy];
        
        _player.controls = [[playlistItem objectForKey:@"controls"] boolValue];
        
        _player.forceFullScreenOnLandscape = YES;
        _player.forceLandscapeOnFullScreen = YES;
        
        [self addSubview:self.player.view];
    }
}

-(void)resetPlaylistItem
{
    self.playlistItem = nil;
}

-(void)reset
{
    _player = nil;
    _proxy = nil;
}

-(void)setPlaylist:(NSArray *)playlist
{
    if (playlist != nil && playlist.count > 0) {
        [self reset];
        
        NSMutableArray <JWPlaylistItem *> *playlistArray = [[NSMutableArray alloc] init];
        for (id item in playlist) {
            JWPlaylistItem *playListItem = [JWPlaylistItem new];
            
            NSString *newFile = [item objectForKey:@"file"];
            NSString* encodedUrl = [newFile stringByAddingPercentEscapesUsingEncoding:
                                    NSUTF8StringEncoding];
            playListItem.file = encodedUrl;
            playListItem.image = [item objectForKey:@"image"];
            playListItem.title = [item objectForKey:@"title"];
            playListItem.desc = [item objectForKey:@"desc"];
            playListItem.mediaId = [item objectForKey:@"mediaId"];
            [playlistArray addObject:playListItem];
        }
        
        JWConfig *config = [self setupConfig];
        
        id playerStyle = [[playlist[0] objectForKey:@"playerStyle"] stringValue];
        if (playerStyle != nil) {
            [self customStyle:config :playerStyle];
        } else {
            [self defaultStyle:config];
        }
        
        config.autostart = [[playlist[0] objectForKey:@"autostart"] boolValue];
        
        config.playlist = playlistArray;
        
        _proxy = [RNJWPlayerDelegateProxy new];
        _proxy.delegate = self;
        
        _player = [[JWPlayerController alloc] initWithConfig:config delegate:_proxy];
        
        _player.controls = YES;
        
        _player.forceFullScreenOnLandscape = YES;
        _player.forceLandscapeOnFullScreen = YES;
        
        [self addSubview:self.player.view];
    }
}

#pragma mark - RNJWPlayer Delegate

-(void)onRNJWReady
{
    if (self.onPlayerReady) {
        self.onPlayerReady(@{});
    }
}

-(void)onRNJWPlaylist
{
    if (self.onPlaylist) {
        self.onPlaylist(@{});
    }
}

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
        NSNumber *index;
        
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
        
        index = [NSNumber numberWithInteger: event.index];
        
        NSMutableDictionary *playListItemDict = [[NSMutableDictionary alloc] init];
        [playListItemDict setObject:file forKey:@"file"];
        [playListItemDict setObject:mediaId forKey:@"mediaId"];
        [playListItemDict setObject:title forKey:@"title"];
        [playListItemDict setObject:desc forKey:@"desc"];
        [playListItemDict setObject:index forKey:@"index"];
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:playListItemDict options:NSJSONWritingPrettyPrinted error: &error];
        
        self.onPlaylistItem(@{@"playlistItem": [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]});
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
        NSLog(@"position: %@",@(event.position));
        self.onTime(@{@"position": @(event.position), @"duration": @(event.duration)});
        //        [[NSUserDefaults standardUserDefaults] setObject:@(event.position) forKey:@"PlayerTime"];
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

-(void)onRNJWPlayerSeek:(JWEvent<JWSeekEvent> *)event
{
    if (self.onSeek) {
        self.onSeek(@{});
    }
}

-(void)onRNJWControlBarVisible:(JWEvent<JWControlsEvent> *)event
{
    if (self.onControlBarVisible) {
        self.onControlBarVisible(@{@"controls": @(event.controls)});
    }
}

//-(void)onRN

#pragma mark - RNJWPlayer Interruption handling

-(void)audioInterruptionsStarted:(NSNotification *)note {
    if (self.onPause) {
        self.onPause(@{});
    }
    
    [self.player pause];
}

-(void)audioInterruptionsEnded:(NSNotification *)note {
    if (self.onPlay) {
        self.onPlay(@{});
    }
    
    [self.player play];
}

@end
