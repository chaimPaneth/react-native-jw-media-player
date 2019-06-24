#import "RNJWPlayerNativeView.h"
#import "RNJWPlayerDelegateProxy.h"
#import "CustomJWPlaylistItem.h"
#import <AVFoundation/AVFoundation.h>

NSString* const AudioInterruptionsStarted = @"AudioInterruptionsStarted";
NSString* const AudioInterruptionsEnded = @"AudioInterruptionsEnded";

NSInteger seekTime;
BOOL isFirst;
NSInteger currentPlayingIndex;

@implementation RNJWPlayerNativeView

//- (instancetype)init
//{
//    _player = [[JWPlayerController alloc] init];
//
//    if (self = [super init]) {
//        [self addSubview:self.player.view];
//    }
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterruptionsStarted:) name:AudioInterruptionsStarted object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterruptionsEnded:) name:AudioInterruptionsEnded object:nil];
//
//    return self;
//}

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

//- (JWPlayerController *)player {
//    if (!_player) {
//        JWConfig *config = [self setupConfig];
//
//        _proxy = [RNJWPlayerDelegateProxy new];
//        _proxy.delegate = self;
//
//        _player = [[JWPlayerController alloc] initWithConfig:config delegate:_proxy];
//
//        _player.forceFullScreenOnLandscape = YES;
//        _player.forceLandscapeOnFullScreen = YES;
//    }
//
//    return _player;
//}

-(JWConfig*)setupConfig
{
    JWConfig *config = [JWConfig new];
    
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
    
    //    config.autostart = YES; // _autostart
    //    config.controls = YES; // _controls
    //    config.repeat = NO; // _repeat
    //    config.displayDescription = YES;
    //    config.displayTitle = YES;
    return config;
}

-(void)setFile:(NSString *)file
{
    if (file != nil && file.length > 0 && ![file isEqualToString:_player.config.file]) {
        NSString* encodedUrl = [file stringByAddingPercentEscapesUsingEncoding:
                                NSUTF8StringEncoding];
        // self.player.config.sources = @[[JWSource sourceWithFile:file
        //label:@"Default Streaming" isDefault:YES]];
        self.player.config.file = encodedUrl;
        //[self.player play];
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

//-(void)setTime:(NSNumber *)time
//{
//    if (time != nil && time > 0) { //[time integerValue] != seekTime
//        seekTime = [time integerValue];
//        [self.player seek: seekTime];
//    }
//}

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
        //[self.player play];
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
        //[self.player play];
    }
}

-(BOOL)controls
{
    return self.player.controls;//self.player.config.controls;
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

//-(void)setPlaylistId:(NSString *)playlistId
//{
//    if(playlistId != nil && playlistId.length > 0 && ![playlistId isEqualToString:_comparePlaylistId]) {
//        _comparePlaylistId = playlistId;
//    }
//}
//
//-(NSString *)playlistId
//{
//    return _comparePlaylistId;
//}

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
    //    [self addObserevers];
    
    NSString *newFile = [playlistItem objectForKey:@"file"];
    if (newFile != nil && newFile.length > 0 && ![newFile isEqualToString: _player.config.file]) {
        
        [self reset];
        [self resetPlaylist];
        
        JWConfig *config = [self setupConfig];
        NSString* encodedUrl = [newFile stringByAddingPercentEscapesUsingEncoding:
                                NSUTF8StringEncoding];
        config.file = encodedUrl;
        config.mediaId = [playlistItem objectForKey:@"mediaId"];
        config.title = [playlistItem objectForKey:@"title"];
        config.desc = [playlistItem objectForKey:@"desc"];
        config.image = [playlistItem objectForKey:@"image"];
        
        config.autostart = [[playlistItem objectForKey:@"autostart"] boolValue];
        config.controls = [[playlistItem objectForKey:@"controls"] boolValue];
        config.repeat = [[playlistItem objectForKey:@"repeat"] boolValue];
        config.displayDescription = [[playlistItem objectForKey:@"displayDesc"] boolValue];
        config.displayTitle = [[playlistItem objectForKey:@"displayTitle"] boolValue];
        
        _proxy = [RNJWPlayerDelegateProxy new];
        _proxy.delegate = self;
        
        _player = [[JWPlayerController alloc] initWithConfig:config delegate:_proxy];
        
        _player.controls = [[playlistItem objectForKey:@"controls"] boolValue];
        
        _player.forceFullScreenOnLandscape = YES;
        _player.forceLandscapeOnFullScreen = YES;
        
        [self addSubview:self.player.view];
    }
    
    if([playlistItem objectForKey:@"time"] != nil){
        if([[playlistItem objectForKey:@"time"] isKindOfClass:[NSNull class]]){
            NSLog(@"Time nil");
        }
        else{
            NSLog(@"time: %d",[[playlistItem objectForKey:@"time"] intValue]);
            isFirst = true;
            seekTime = [[playlistItem objectForKey:@"time"] integerValue];
        }
    }
    else{
        NSLog(@"Time nil");
    }
}

-(NSDictionary *)playlistItem
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
    //JWPreload preload = JWPreloadNone;
    
    
    
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
    
    //    if (self.player.config.controls) {
    //        controls = self.player.config.controls;
    //    }
    
    if (self.player.controls) {
        controls = self.player.controls;
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
    
    //    if (self.player.config.preload) {
    //        preload = self.player.config.preload;
    //    }
    
    
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
    //[playListItemDict setObject:[NSNumber numberWithInt:preload]  forKey:@"preload"];
    
    return playListItemDict;
}

-(void)resetPlaylist
{
    _playlistId = nil;
    _comparePlaylistId = nil;
    _playlist = nil;
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
    _playlist = playlist;
    if (playlist != nil && playlist.count > 0 && _playlistId != nil && _playlistId.length > 0 && _playlistId != _comparePlaylistId) {
        _comparePlaylistId = _playlistId;
        
        [self reset];
        NSMutableArray <JWPlaylistItem *> *playlistArray = [[NSMutableArray alloc] init];
        for (id item in playlist) {
            JWPlaylistItem *playListItem = [JWPlaylistItem new]; //CustomJWPlaylistItem
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
        
        config.autostart = YES;
        config.controls = YES;
        config.repeat = NO;
        config.displayDescription = YES;
        config.displayTitle = YES;
        
        config.playlist = playlistArray;
        
        //        [config.playlist arrayByAddingObjectsFromArray:playlistArray];
        
        _proxy = [RNJWPlayerDelegateProxy new];
        _proxy.delegate = self;
        
        _player = [[JWPlayerController alloc] initWithConfig:config delegate:_proxy];
        
        _player.controls = YES;
        
        _player.forceFullScreenOnLandscape = YES;
        _player.forceLandscapeOnFullScreen = YES;
        
        [self addSubview:self.player.view];
        //        [self.player play];
    }
    
//    if (_playlist.count > currentPlayingIndex) {
//        id item = _playlist[currentPlayingIndex];
//
//        if([item objectForKey:@"time"] != nil) {
//            if([[item objectForKey:@"time"] isKindOfClass:[NSNull class]]){
//                NSLog(@"Time nil");
//            }
//            else{
//                NSLog(@"time: %d",[[item objectForKey:@"time"] intValue]);
//                isFirst = true;
//                seekTime = [[item objectForKey:@"time"] integerValue];
//            }
//        }
//        else{
//            NSLog(@"Time nil");
//        }
//    }
}

-(NSArray *)playList
{
    return self.player.config.playlist;
}

#pragma mark - RNJWPlayer Delegate

-(void)onRNJWPlayerBeforePlay
{
    if (self.onBeforePlay) {
        if(isFirst && seekTime > 0){
            isFirst = false;
            [self.player seek: seekTime];
        }
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
        currentPlayingIndex = event.index;
        
        if (_comparePlaylistId != nil && _playlist != nil && _playlist.count > currentPlayingIndex) {
            id item = _playlist[currentPlayingIndex];

            if([item objectForKey:@"time"] != nil) {
                if([[item objectForKey:@"time"] isKindOfClass:[NSNull class]]){
                    NSLog(@"Time nil");
                }
                else{
                    NSLog(@"time: %d",[[item objectForKey:@"time"] intValue]);
                    isFirst = true;
                    seekTime = [[item objectForKey:@"time"] integerValue];
                }
            }
            else{
                NSLog(@"Time nil");
            }
        }
        
//        if (_time != nil && _time > 0) {
//            isFirst = YES;
//            seekTime = [_time integerValue];
//        }
        
//        if (_comparePlaylistId != nil && _playlist != nil && _playlist.count > 0) {
//            NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.mediaId MATCHES[cd] %@", event.item.mediaId];
//            NSArray *filteredPlaylist = [_playlist filteredArrayUsingPredicate: bPredicate];
//
//            if (filteredPlaylist.count > 0) {
//                id item = filteredPlaylist.firstObject;
//
//                if([item objectForKey:@"time"] != nil){
//                    if([[item objectForKey:@"time"] isKindOfClass:[NSNull class]]){
//                        NSLog(@"Time nil");
//                    }
//                    else{
//                        NSLog(@"time: %d",[[item objectForKey:@"time"] intValue]);
//                        isFirst = YES;
//                        seekTime = [[item objectForKey:@"time"] integerValue];
//                    }
//                }
//            }
//        }
        
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
    if(self.onSeek){
        self.onSeek(@{});
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
