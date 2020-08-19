#import "RNJWPlayerNativeView.h"
#import "RNJWPlayerDelegateProxy.h"
#import <AVFoundation/AVFoundation.h>
#import <GoogleCast/GoogleCast.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>

@implementation RNJWPlayerNativeView

#pragma mark - RNJWPlayer allocation

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotated:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:AVAudioSessionInterruptionNotification];
    } @catch(id anException) {
       
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.player != nil) {
        self.player.view.frame = self.frame;
    }
    
    if (_initFrame.size.height == 0) {
        _initFrame = self.frame;
    }
}

- (void)removeFromSuperview {
    [self reset];
    [super removeFromSuperview];
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

- (void)initializeAudioSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(audioSessionInterrupted:)
                                                 name: AVAudioSessionInterruptionNotification
                                               object: audioSession];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
}

#pragma mark - RNJWPlayer styling

-(void)customStyle: (JWConfig*)config :(NSString*)name
{
    config.stretching = JWStretchingUniform;
    
    JWSkinStyling *skinStyling = [JWSkinStyling new];
    config.skin = skinStyling;
    
    skinStyling.url = [NSString stringWithFormat:@"file://%@", [[NSBundle mainBundle] pathForResource:name ofType:@"css"]];
    skinStyling.name = name;
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

-(void)setColors: (NSDictionary *)colors
{
    if (colors != nil) {
        _playerColors = colors;
        
        if (_player != nil) {
            [self setupColors:_player.config];
        }
    }
}

-(void)setupColors: (JWConfig *)config
{
    if (_playerColors != nil) {
        config.stretching = JWStretchingUniform;
        
        JWSkinStyling *skinStyling = [JWSkinStyling new];
        config.skin = skinStyling;
        
        if ([_playerColors objectForKey:@"icons"] != nil) {
            id icons = [_playerColors objectForKey:@"icons"];
            
            JWControlbarStyling *controlbarStyling = [JWControlbarStyling new];
            controlbarStyling.icons = [self colorWithHexString:icons];
            skinStyling.controlbar = controlbarStyling;
        }
        
        if ([_playerColors objectForKey:@"timeslider"] != nil) {
            JWTimesliderStyling *timesliderStyling = [JWTimesliderStyling new];
            
            id timeslider = [_playerColors objectForKey:@"timeslider"];
            
            if ([timeslider objectForKey:@"progress"] != nil) {
                id progress = [timeslider objectForKey:@"progress"];
                timesliderStyling.progress = [self colorWithHexString:progress];
            }
            
            if ([timeslider objectForKey:@"rail"] != nil) {
                id rail = [timeslider objectForKey:@"rail"];
                timesliderStyling.rail = [self colorWithHexString:rail];
            }
            
            skinStyling.timeslider = timesliderStyling;
        }
    }
}

-(void)setPlayerStyle:(NSString *)playerStyle
{
    if (playerStyle != nil) {
        _playerStyle = playerStyle;
    }
}

#pragma mark - RNJWPlayer props

-(void)setEnableCasting:(BOOL)enableCasting
{
    _enableCasting = enableCasting;
    if (enableCasting) {
        [self setUpCastController];
    }
}

-(void)setNativeFullScreen:(BOOL)nativeFullScreen
{
    _nativeFullScreen = nativeFullScreen;
}

-(void)setFullScreenOnLandscape:(BOOL)fullScreenOnLandscape
{
    _fullScreenOnLandscape = fullScreenOnLandscape;
    
    if (_player) {
        _player.forceFullScreenOnLandscape = fullScreenOnLandscape;
    }
}

-(void)setLandscapeOnFullScreen:(BOOL)landscapeOnFullScreen
{
    _landscapeOnFullScreen = landscapeOnFullScreen;
    
    if (_player) {
        _player.forceLandscapeOnFullScreen = landscapeOnFullScreen;
    }
}

-(void)setPortraitOnExitFullScreen:(BOOL)portraitOnExitFullScreen
{
    _portraitOnExitFullScreen = portraitOnExitFullScreen;
}

-(void)setExitFullScreenOnPortrait:(BOOL)exitFullScreenOnPortrait
{
    _exitFullScreenOnPortrait = exitFullScreenOnPortrait;
}

-(void)setFile:(NSString *)file
{
    NSString* encodedUrl = [file stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    if (file != nil && file.length > 0 && ![encodedUrl isEqualToString:_player.config.file]) {
        self.player.config.file = encodedUrl;
    }
}

-(NSString *)file
{
    return self.player.config.file;
}

-(void)setAdVmap:(NSString *)adVmap
{
    if(adVmap != nil && adVmap.length > 0 && ![adVmap isEqualToString:_player.config.advertising.adVmap]) {
        self.player.config.advertising = [JWAdConfig new];
        self.player.config.advertising.client = JWAdClientGoogima;
        self.player.config.advertising.adVmap = adVmap;
    }
}

-(NSString *)adVmap
{
    return self.player.config.advertising.adVmap;
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

-(BOOL)shouldAutorotate {
    return NO;
}

-(void)setPlaylistItem:(NSDictionary *)playlistItem
{
    NSString *newFile = [playlistItem objectForKey:@"file"];
    
    if (newFile != nil && newFile.length > 0) {
        [self setPlaylist:@[playlistItem]];
    }
}

-(void)reset
{
    _player = nil;
    _proxy = nil;
}

-(JWPlaylistItem*)getPlaylistItem:item
{
    JWPlaylistItem *playListItem = [JWPlaylistItem new];
    
    NSString *newFile = [item objectForKey:@"file"];
    
    NSURL* url = [NSURL URLWithString:newFile];
    if (url && url.scheme && url.host) {
        playListItem.file = newFile;
    } else {
        NSString* encodedUrl = [newFile stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        playListItem.file = encodedUrl;
    }
    
    id mediaId = item[@"mediaId"];
    if ((mediaId != nil) && (mediaId != (id)[NSNull null])) {
        playListItem.mediaId = mediaId;
    }
    
    id title = item[@"title"];
    if ((title != nil) && (title != (id)[NSNull null])) {
        playListItem.title = title;
    }
    
    id desc = item[@"desc"];
    if ((desc != nil) && (desc != (id)[NSNull null])) {
        playListItem.desc = desc;
    }
    
    id image = item[@"image"];
    if ((image != nil) && (image != (id)[NSNull null])) {
        playListItem.image = image;
    }
    
    id startTime = item[@"startTime"];
    if ((startTime != nil) && (startTime != (id)[NSNull null])) {
        playListItem.startTime = [startTime floatValue];
    }
    
    NSMutableArray <JWAdBreak *> *adsArray = [[NSMutableArray alloc] init];
    id ads = item[@"adSchedule"];
    if(ads != nil) {
        NSArray* adsAr = (NSArray*)ads;
        if(adsAr.count > 0) {
            for (id item in adsAr) {
                NSString *offset = [item objectForKey:@"offset"];
                NSString *tag = [item objectForKey:@"tag"];
                JWAdBreak *adBreak = [JWAdBreak adBreakWithTag:tag offset:offset];
                [adsArray addObject:adBreak];
            }
        }
    }

    if(adsArray.count > 0) {
        playListItem.adSchedule = adsArray;
    }
    
    return playListItem;
}

-(void)setPlaylist:(NSArray *)playlist
{
    if (playlist != nil && playlist.count > 0) {
        if ([playlist[0] objectForKey:@"backgroundAudioEnabled"] != nil) {
            bool backgroundAudioEnabled = [playlist[0] objectForKey:@"backgroundAudioEnabled"];
            if (backgroundAudioEnabled == true) {
                [self initializeAudioSession];
            }
        }
        
        NSMutableArray <JWPlaylistItem *> *playlistArray = [[NSMutableArray alloc] init];
        for (id item in playlist) {
            JWPlaylistItem *playListItem = [self getPlaylistItem:item];
            [playlistArray addObject:playListItem];
        }
        
        JWConfig *config = [self setupConfig];
        
        if ([playlist[0] objectForKey:@"playerStyle"] != nil) {
            _playerStyle = [playlist[0] objectForKey:@"playerStyle"];
        }
        
        if (_playerStyle != nil) {
            [self customStyle:config :_playerStyle];
        } else if (_playerColors != nil) {
            [self setupColors:config];
        }
        
        if ([playlist[0] objectForKey:@"nextUpOffset"] != nil) {
            config.nextupOffset = [[playlist[0] objectForKey:@"nextUpOffset"] intValue];
        }
        
        if ([playlist[0] objectForKey:@"autostart"] != nil) {
            config.autostart = [[playlist[0] objectForKey:@"autostart"] boolValue];
        }
        
        JWAdConfig* advertising = [JWAdConfig new];
        
        id adClient = [playlist[0] objectForKey:@"adClient"];
        if ((adClient != nil) && (adClient != (id)[NSNull null])) {
            switch ([adClient intValue]) {
                case 1:
                    advertising.client = JWAdClientGoogima;
                    break;
                case 2:
                    advertising.client = JWAdClientGoogimaDAI;
                    break;
                case 3:
                    advertising.client = JWAdClientFreewheel;
                    break;
                    
                default:
                    advertising.client = JWAdClientVast;
                    break;
            }
        } else {
            advertising.client = JWAdClientVast;
        }

        config.advertising = advertising;
        
        if ([playlist[0] objectForKey:@"adVmap"] != nil) {
            id adVmap = [playlist[0] objectForKey:@"adVmap"];
            if ((adVmap != nil) && (adVmap != (id)[NSNull null])) {
                config.advertising.adVmap = adVmap;
            }
        }
        
        if (_player == nil || ![_player.config.playlist isEqualToArray:playlistArray]) {
            [self reset];
            
            config.playlist = playlistArray;
            
            _proxy = [RNJWPlayerDelegateProxy new];
            _proxy.delegate = self;
            
            _player = [[JWPlayerController alloc] initWithConfig:config delegate:_proxy];
            
            _player.controls = YES;
            
            [self setFullScreenOnLandscape:_fullScreenOnLandscape];
            [self setLandscapeOnFullScreen:_landscapeOnFullScreen];
                    
            [self addSubview:self.player.view];
        } else {
             [self continuePlaying];
        }
    } else {
        [self continuePlaying];
    }
}

-(void)continuePlaying
{
    if (_player != nil && [_player config].file != nil) {
        if ([_player config].autostart) {
            [_player play];
        }
    }
}

#pragma mark - RNJWPlayer utils

-(void)explode
{
    CGRect rect = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    self.frame = rect;
    
    [self setBackgroundColor:[UIColor blackColor]];
}

-(void)shrink
{
    self.frame = _initFrame;
    
    [self setBackgroundColor:[UIColor whiteColor]];
}

- (void)rotated:(NSNotification *)notification {
    if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice.orientation)) {
        NSLog(@"Landscape");
    }

    if (UIDeviceOrientationIsPortrait(UIDevice.currentDevice.orientation)) {
        NSLog(@"Portrait");
    }
    
    [self layoutSubviews];
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

-(void)onRNJWPlayerPlay
{
    if (self.onPlay) {
        self.onPlay(@{});
    }
    
    _userPaused = NO;
    _wasInterrupted = NO;
}

-(void)onRNJWPlayerPause
{
    if (self.onPause) {
        self.onPause(@{});
    }
    
    if (!_wasInterrupted) {
        _userPaused = YES;
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
        self.onTime(@{@"position": @(event.position), @"duration": @(event.duration)});
    }
}

-(void)onRNJWFullScreen:(JWEvent<JWFullscreenEvent> *)event
{
    if(event && [[event valueForKey:@"_fullscreen"] boolValue]){
        if (self.onFullScreen) {
            if (_nativeFullScreen && _landscapeOnFullScreen) {
                [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
            }
            self.onFullScreen(@{});
        }
    } else {
        if (self.onFullScreenExit) {
            if (_nativeFullScreen && _portraitOnExitFullScreen) {
                [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
            }
            self.onFullScreenExit(@{});
        }
    }
    
}

-(void)onRNJWFullScreenRequested:(JWEvent<JWFullscreenEvent> *)event
{
    if ([[event valueForKey:@"_fullscreen"] boolValue]) {
        if (self.onFullScreenRequested) {
            self.onFullScreenRequested(@{});
        }
        
        if (_nativeFullScreen) {
            [self explode];
        }
    } else {
        if (self.onFullScreenExitRequested) {
            self.onFullScreenExitRequested(@{});
        }
        
        if (_nativeFullScreen) {
            [self shrink];
        }
    }
}

-(void)onRNJWPlayerSeek:(JWEvent<JWSeekEvent> *)event
{
    if (self.onSeek) {
        self.onSeek(@{@"position": @(event.position), @"offset": @(event.offset)});
    }
}

-(void)onRNJWPlayerSeeked
{
    if (self.onSeeked) {
        self.onSeeked(@{});
    }
}

-(void)onRNJWControlBarVisible:(JWEvent<JWControlsEvent> *)event
{
    if (self.onControlBarVisible) {
        self.onControlBarVisible(@{@"controls": @(event.controls)});
    }
}

-(void)onRNJWPlayerComplete
{
    if (self.onComplete) {
        self.onComplete(@{});
    }
}

#pragma mark - RNJWPlayer Ad events

-(void)onRNJWPlayerBeforePlay
{
    if (self.onBeforePlay) {
        self.onBeforePlay(@{});
    }
}

-(void)onRNJWPlayerBeforeComplete
{
    if (self.onBeforeComplete) {
        self.onBeforeComplete(@{});
    }
}

-(void)onRNJWPlayerAdPlay:(JWAdEvent<JWAdStateChangeEvent>*)event
{
    if (self.onAdPlay) {
        self.onAdPlay(@{});
    }
}

-(void)onRNJWPlayerAdPause:(JWAdEvent<JWAdStateChangeEvent>*)event
{
    if (self.onAdPause) {
        self.onAdPause(@{});
    }
}

#pragma mark - RNJWPlayer Interruption handling

-(void)audioSessionInterrupted:(NSNotification*)note
{
  if ([note.name isEqualToString:AVAudioSessionInterruptionNotification]) {
    NSLog(@"Interruption notification");
    
    if ([[note.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]]) {
        [self audioInterruptionsStarted:note];
    } else {
      [self audioInterruptionsEnded:note];
    }
  }
}

-(void)audioInterruptionsStarted:(NSNotification *)note {
    _wasInterrupted = YES;
    [self.player pause];
}

-(void)audioInterruptionsEnded:(NSNotification *)note {
    if (!_userPaused) {
        [self.player play];
    }
}

#pragma mark - RNJWPlayer Casting

- (void)setUpCastController
{
    _castController = [[JWCastController alloc] initWithPlayer:_player];
    _castController.chromeCastReceiverAppID = kGCKDefaultMediaReceiverApplicationID;
    _castController.delegate = self;
    [_castController scanForDevices];
}

- (void)onCastingDevicesAvailable:(NSArray<JWCastingDevice *> *)devices
{
    _availableDevices = devices;
    [self presentCastingOptions];
}

-(void)onUserSelectedDevice:(NSInteger)index
{
    JWCastingDevice *chosenDevice = _availableDevices[index];
    [_castController connectToDevice:chosenDevice];
}

-(void)onConnectedToCastingDevice:(JWCastingDevice *)device
{
    [_castController cast];
}

- (void)onCasting
{
    _isCasting = YES;
}

- (void)onCastingEnded:(NSError *)error
{
    _isCasting = NO;
}

- (void)onCastingFailed:(NSError *)error
{
    _isCasting = NO;
}

- (void)presentCastingOptions
{
    __weak RNJWPlayerNativeView *weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (self.castController.connectedDevice == nil) {
        alertController.title = @"Connect to";
        
        [self.castController.availableDevices enumerateObjectsUsingBlock:^(JWCastingDevice  *_Nonnull device, NSUInteger idx, BOOL * _Nonnull stop) {
            UIAlertAction *deviceSelected = [UIAlertAction actionWithTitle:device.name
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                                       [weakSelf.castController connectToDevice:device];
                                                                   }];
            [alertController addAction:deviceSelected];
        }];
    } else {
        alertController.title = self.castController.connectedDevice.name;
        alertController.message = @"Select an action";
        
        UIAlertAction *disconnect = [UIAlertAction actionWithTitle:@"Disconnect"
                                                             style:UIAlertActionStyleDestructive
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               [weakSelf.castController disconnect];
                                                           }];
        [alertController addAction:disconnect];
        
        UIAlertAction *castControl;
        if (_isCasting) {
            castControl = [UIAlertAction actionWithTitle:@"Stop Casting"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                     [weakSelf.castController stopCasting];
                                                 }];
        } else {
            castControl = [UIAlertAction actionWithTitle:@"Cast"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                     [weakSelf.castController cast];
                                                 }];
        }
        [alertController addAction:castControl];
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                            style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alertController addAction:cancel];
    
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [rootViewController presentViewController:alertController animated:YES completion:^{}];
}

- (void)showAirPlayButton:(CGFloat)x :(CGFloat)y
{
	UIView *buttonView = nil;
	CGRect buttonFrame = CGRectMake(x, y, 44, 44);
	
	// It's highly recommended to use the AVRoutePickerView in order to avoid AirPlay issues after iOS 11.
	if (@available(iOS 11.0, *)) {
		AVRoutePickerView *airplayButton = [[AVRoutePickerView alloc] initWithFrame:buttonFrame];
		airplayButton.activeTintColor = [UIColor blueColor];
		airplayButton.tintColor = [UIColor grayColor];
		buttonView = airplayButton;
	} else {
		// If you still support previous iOS versions, you can use MPVolumeView
		MPVolumeView *airplayButton = [[MPVolumeView alloc] initWithFrame:buttonFrame];
		airplayButton.showsVolumeSlider = NO;
		buttonView = airplayButton;
	}

    [buttonView setTag:101];

	[self addSubview:buttonView];
}

- (void)hideAirPlayButton
{
    if ([self viewWithTag:101] != nil)
        [[self viewWithTag:101] removeFromSuperview];
}


@end
