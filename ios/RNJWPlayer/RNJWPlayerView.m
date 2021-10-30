#import "RNJWPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "RCTConvert+RNJWPlayer.h"

@implementation RNJWPlayerView

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

- (void)removeFromSuperview {
    [self reset];
    [super removeFromSuperview];
}

-(void)reset
{
    [self removePlayerView];
    [self dismissPlayerViewController];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.playerView != nil) {
        self.playerView.frame = self.frame;
    }
    
    if (self.playerViewController != nil) {
        self.playerViewController.view.frame = self.frame;
//        [_playerViewController.view.subviews[0].subviews[2] setHidden:YES]; // this is overlay with controls
    }
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

-(BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - RNJWPlayer props

-(void)setConfig:(NSDictionary*)config
{
    id license = config[@"license"];
    if ((license != nil) && (license != (id)[NSNull null])) {
        [JWPlayerKitLicense setLicenseKey:license];
    } else {
        NSLog(@"JW SDK License key not set.");
    }
    
    _backgroundAudioEnabled = config[@"backgroundAudioEnabled"];
    _pipEnabled = config[@"pipEnabled"];
    if (_backgroundAudioEnabled || _pipEnabled) {
        [self initializeAudioSession];
    }
    
    id viewOnly = config[@"viewOnly"];
    if ((viewOnly != nil) && (viewOnly != (id)[NSNull null])) {
        [self setupPlayerView:config :[self getPlayerConfiguration:config]];
    } else {
        [self setupPlayerViewController:config :[self getPlayerConfiguration:config]];
    }
}

#pragma mark - RNJWPlayer styling

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

-(void)setStyling:styling
{
    JWError* error = nil;
    
    if (styling != nil && (styling != (id)[NSNull null])) {
        JWPlayerSkinBuilder* skinStylingBuilder = [[JWPlayerSkinBuilder alloc] init];
        
        id colors = styling[@"colors"];
        if (colors != nil && (colors != (id)[NSNull null])) {
            id timeSlider = colors[@"timeslider"];
            if (timeSlider != nil && (timeSlider != (id)[NSNull null])) {
                JWTimeSliderStyleBuilder* timeSliderStyleBuilder = [[JWTimeSliderStyleBuilder alloc] init];
                
                id progress = timeSlider[@"progress"];
                if (progress != nil && (progress != (id)[NSNull null])) {
                    [timeSliderStyleBuilder minimumTrackColor:[self colorWithHexString:progress]];
                }
                
                id rail = timeSlider[@"rail"];
                if (rail != nil && (rail != (id)[NSNull null])) {
                    [timeSliderStyleBuilder maximumTrackColor:[self colorWithHexString:rail]];
                }
                
                id thumb = timeSlider[@"thumb"];
                if (thumb != nil && (thumb != (id)[NSNull null])) {
                    [timeSliderStyleBuilder thumbColor:[self colorWithHexString:thumb]];
                }
                
                JWTimeSliderStyle* timeSliderStyle = [timeSliderStyleBuilder buildAndReturnError:&error];
                
                [skinStylingBuilder timeSliderStyle:timeSliderStyle];
            }
            
            id buttons = colors[@"buttons"];
            if (buttons != nil && (buttons != (id)[NSNull null])) {
                [skinStylingBuilder buttonsColor:[self colorWithHexString:buttons]];
            }
            
            id backgroundColor = colors[@"backgroundColor"];
            if (backgroundColor != nil && (backgroundColor != (id)[NSNull null])) {
                [skinStylingBuilder backgroundColor:[self colorWithHexString:backgroundColor]];
            }
            
            id fontColor = colors[@"fontColor"];
            if (fontColor != nil && (fontColor != (id)[NSNull null])) {
                [skinStylingBuilder fontColor:[self colorWithHexString:fontColor]];
            }
        }
        
        id font = styling[@"font"];
        if (font != nil && (font != (id)[NSNull null])) {
            id name = font[@"name"];
            id size = font[@"size"];
            
            if (name != nil && (name != (id)[NSNull null]) && size != nil && (size != (id)[NSNull null])) {
                [skinStylingBuilder font:[UIFont fontWithName:name size:[size floatValue]]];
            }
        }
        
        id showTitle = styling[@"displayTitle"];
        if (showTitle != nil && (showTitle != (id)[NSNull null])) {
            [skinStylingBuilder titleIsVisible:showTitle];
        }
        
        id showDesc = styling[@"displayDescription"];
        if (showDesc != nil && (showDesc != (id)[NSNull null])) {
            [skinStylingBuilder descriptionIsVisible:showDesc];
        }
        
        id capStyle = styling[@"captionsStyle"];
        if (capStyle != nil && (capStyle != (id)[NSNull null])) {
            JWCaptionStyleBuilder* capStyleBuilder = [[JWCaptionStyleBuilder alloc] init];
            
            id font = capStyle[@"font"];
            if (font != nil && (font != (id)[NSNull null])) {
                id name = font[@"name"];
                id size = font[@"size"];
                if (name != nil && (name != (id)[NSNull null]) && size != nil && (size != (id)[NSNull null])) {
                    [capStyleBuilder font:[UIFont fontWithName:name size:[size floatValue]]];
                }
            }
            
            id fontColor = capStyle[@"fontColor"];
            if (fontColor != nil && (fontColor != (id)[NSNull null])) {
                [capStyleBuilder fontColor:[self colorWithHexString:fontColor]];
            }
            
            id backgroundColor = capStyle[@"backgroundColor"];
            if (backgroundColor != nil && (backgroundColor != (id)[NSNull null])) {
                [capStyleBuilder backgroundColor:[self colorWithHexString:backgroundColor]];
            }
            
            id highlightColor = capStyle[@"highlightColor"];
            if (highlightColor != nil && (highlightColor != (id)[NSNull null])) {
                [capStyleBuilder highlightColor:[self colorWithHexString:highlightColor]];
            }
            
            id edgeStyle = capStyle[@"edgeStyle"];
            if (edgeStyle != nil && (edgeStyle != (id)[NSNull null])) {
                [capStyleBuilder edgeStyle:[RCTConvert JWCaptionEdgeStyle:edgeStyle]];
            }
            
            JWCaptionStyle* captionStyle = [capStyleBuilder buildAndReturnError:&error];
            
            [skinStylingBuilder captionStyle:captionStyle];
        }
        
        
        id menuStyle = styling[@"menuStyle"];
        if (menuStyle != nil && (menuStyle != (id)[NSNull null])) {
            JWMenuStyleBuilder* menuStyleBuilder = [[JWMenuStyleBuilder alloc] init];
            
            id font = capStyle[@"font"];
            if (font != nil && (font != (id)[NSNull null])) {
                id name = font[@"name"];
                id size = font[@"size"];
                if (name != nil && (name != (id)[NSNull null]) && size != nil && (size != (id)[NSNull null])) {
                    [menuStyle font:[UIFont fontWithName:name size:[size floatValue]]];
                }
            }
            
            id fontColor = capStyle[@"fontColor"];
            if (fontColor != nil && (fontColor != (id)[NSNull null])) {
                [menuStyle fontColor:[self colorWithHexString:fontColor]];
            }
            
            id backgroundColor = capStyle[@"backgroundColor"];
            if (backgroundColor != nil && (backgroundColor != (id)[NSNull null])) {
                [menuStyle backgroundColor:[self colorWithHexString:backgroundColor]];
            }
            
            JWMenuStyle* jwMenuStyle = [menuStyleBuilder buildAndReturnError:&error];
            
            [skinStylingBuilder menuStyle:jwMenuStyle];
        }
        
        JWPlayerSkin *skinStyling = [skinStylingBuilder buildAndReturnError:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_playerViewController.styling = skinStyling;
        });
    }
}

#pragma mark - RNJWPlayer config helpers

-(JWPlayerItem*)getPlayerItem:item
{
    JWPlayerItemBuilder* itemBuilder = [[JWPlayerItemBuilder alloc] init];
    JWError* error = nil;
    
    NSString* newFile = [item objectForKey:@"file"];
    NSURL* url = [NSURL URLWithString:newFile];
    
    if (url && url.scheme && url.host) {
        [itemBuilder file:url];
    } else {
        NSString* encodedString = [newFile stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSURL* encodedUrl = [NSURL URLWithString:encodedString];
        [itemBuilder file:encodedUrl];
    }
    
    id itemSources = item[@"sources"];
    if(itemSources != nil && (itemSources != (id)[NSNull null])) {
        NSArray* itemSourcesArray = (NSArray*)itemSources;
        if (itemSourcesArray.count > 0) {
            NSMutableArray <JWVideoSource*> *sourcesArray = [[NSMutableArray alloc] init];
            
            for (id source in itemSourcesArray) {
                NSString* file = [source objectForKey:@"file"];
                NSURL* fileUrl = [NSURL URLWithString:file];
                NSString* label = [source objectForKey:@"label"];
                bool isDefault = [source objectForKey:@"default"];
                
                JWVideoSource* sourceItem = [JWVideoSource init];
                JWVideoSourceBuilder* sourceBuilder = [[JWVideoSourceBuilder alloc] init];
                
                [sourceBuilder file:fileUrl];
                [sourceBuilder label:label];
                [sourceBuilder defaultVideo:isDefault];
                
                sourceItem = [sourceBuilder buildAndReturnError:&error];
                
                [sourcesArray addObject:sourceItem];
            }
            
            [itemBuilder videoSources:itemSourcesArray];
        }
    }
    
    id mediaId = item[@"mediaId"];
    if ((mediaId != nil) && (mediaId != (id)[NSNull null])) {
        [itemBuilder mediaId:mediaId];
    }
    
    id title = item[@"title"];
    if ((title != nil) && (title != (id)[NSNull null])) {
        [itemBuilder title:title];
    }
    
    id desc = item[@"description"];
    if ((desc != nil) && (desc != (id)[NSNull null])) {
        [itemBuilder description:desc];
    }
    
    id image = item[@"image"];
    if ((image != nil) && (image != (id)[NSNull null])) {
        NSURL* imageUrl = [NSURL URLWithString:image];
        [itemBuilder posterImage:imageUrl];
    }
    
    id startTime = item[@"startTime"];
    if ((startTime != nil) && (startTime != (id)[NSNull null])) {
        [itemBuilder startTime:[startTime floatValue]];
    }
    
    id recommendations = item[@"recommendations"];
    if ((recommendations != nil) && (recommendations != (id)[NSNull null])) {
        NSURL* recUrl = [NSURL URLWithString:recommendations];
        [itemBuilder recommendations:recUrl];
    }

    id tracksItem = item[@"tracks"];
    if(tracksItem != nil && (tracksItem != (id)[NSNull null])) {
        NSArray* tracksItemArray = (NSArray*)tracksItem;
        if (tracksItemArray.count > 0) {
            NSMutableArray <JWMediaTrack*> *tracksArray = [[NSMutableArray alloc] init];
            
            for (id item in tracksItemArray) {
                NSString *file = [item objectForKey:@"file"];
                NSURL *fileUrl = [NSURL URLWithString:file];
                NSString *label = [item objectForKey:@"label"];
                
                JWMediaTrack *trackItem = [JWMediaTrack init];
                JWCaptionTrackBuilder* trackBuilder = [[JWCaptionTrackBuilder alloc] init];
                
                [trackBuilder file:fileUrl];
                [trackBuilder label:label];
                
                trackItem = [trackBuilder buildAndReturnError:&error];
                
                [tracksArray addObject:trackItem];
            }
            
            [itemBuilder mediaTracks:tracksArray];
        }
    }
    
    id ads = item[@"adSchedule"];
    if(ads != nil && (ads != (id)[NSNull null])) {
        NSArray* adsAr = (NSArray*)ads;
        if (adsAr.count > 0) {
            NSMutableArray <JWAdBreak*>* adsArray = [[NSMutableArray alloc] init];
            
            for (id item in adsAr) {
                NSString *offsetString = [item objectForKey:@"offset"];
                NSString *tag = [item objectForKey:@"tag"];
                NSURL* tagUrl = [NSURL URLWithString:tag];
                
                JWAdBreak *adBreak = [JWAdBreak init];
                JWAdBreakBuilder* adBreakBuilder = [[JWAdBreakBuilder alloc] init];
                JWAdOffset* offset = [JWAdOffset fromString:offsetString];
                
                [adBreakBuilder offset:offset];
                [adBreakBuilder tags:@[tagUrl]];
                
                adBreak = [adBreakBuilder buildAndReturnError:&error];
                
                [adsArray addObject:adBreak];
            }
            
            if (adsArray.count > 0) {
                [itemBuilder adScheduleWithBreaks:adsArray];
            }
        }
    }

    id adVmap = item[@"adVmap"];
    if (adVmap != nil && (adVmap != (id)[NSNull null])) {
        NSURL* adVmapUrl = [NSURL URLWithString:adVmap];
        [itemBuilder adScheduleWithVmapURL:adVmapUrl];
    }
    
    return [itemBuilder buildAndReturnError:&error];
}

-(JWPlayerConfiguration*)getPlayerConfiguration:config
{
    JWPlayerConfigurationBuilder *configBuilder = [[JWPlayerConfigurationBuilder alloc] init];
    
    NSMutableArray <JWPlayerItem *> *playlistArray = [[NSMutableArray alloc] init];
    if (config[@"playlist"] != nil && (config[@"playlist"] != (id)[NSNull null])) {
        NSArray* playlist = config[@"playlist"];
        for (id item in playlist) {
            JWPlayerItem *playerItem = [self getPlayerItem:item];
            [playlistArray addObject:playerItem];
        }
        
        [configBuilder playlist:playlistArray];
    }
    
    id autostart = config[@"autostart"];
    if (autostart != nil && (autostart != (id)[NSNull null])) {
        [configBuilder autostart:autostart];
    }
    
    id repeatContent = config[@"repeat"];
    if (repeatContent != nil && (repeatContent != (id)[NSNull null])) {
        [configBuilder repeatContent:repeatContent];
    }
    
    id preload = config[@"preload"];
    if (preload != nil && (preload != (id)[NSNull null])) {
        [configBuilder preload:[RCTConvert JWPreload:preload]];
    }
    
    id related = config[@"related"];
    if ((related != nil) && (related != (id)[NSNull null])) {
        JWRelatedContentConfigurationBuilder* relatedBuilder = [[JWRelatedContentConfigurationBuilder alloc] init];
        
        id onClick = related[@"onClick"];
        if ((onClick != nil) && (onClick != (id)[NSNull null])) {
            [relatedBuilder onClick:[RCTConvert JWRelatedOnClick:onClick]];
        }
        
        id onComplete = related[@"onComplete"];
        if ((onComplete != nil) && (onComplete != (id)[NSNull null])) {

            [relatedBuilder onComplete:[RCTConvert JWRelatedOnComplete:onComplete]];
        }
        
        id heading = related[@"heading"];
        if ((heading != nil) && (heading != (id)[NSNull null])) {
            [relatedBuilder heading:heading];
        }
        
        id urlStr = related[@"url"];
        if ((urlStr != nil) && (urlStr != (id)[NSNull null])) {
            NSURL* url = [NSURL URLWithString:urlStr];
            [relatedBuilder url:url];
        }
        
        id autoplayMessage = related[@"autoplayMessage"];
        if ((autoplayMessage != nil) && (autoplayMessage != (id)[NSNull null])) {
            [relatedBuilder autoplayMessage:autoplayMessage];
        }
        
        id autoplayTimer = related[@"autoplayTimer"];
        if ((autoplayTimer != nil) && (autoplayTimer != (id)[NSNull null])) {
            [relatedBuilder autoplayTimer:[autoplayTimer intValue]];
        }
        
        JWRelatedContentConfiguration* related = [relatedBuilder build];
        
        [configBuilder related:related];
    }
    
//    JWJSONParser
//    JWLockScreenManager
    
    JWError* error = nil;
    
    id ads = config[@"advertising"];
    if (ads != nil && (ads != (id)[NSNull null])) {
        JWAdvertisingConfig* advertising;
        JWAdsAdvertisingConfigBuilder* adConfigBuilder = [[JWAdsAdvertisingConfigBuilder alloc] init];
                 
         id adClient = ads[@"adClient"];
         if ((adClient != nil) && (adClient != (id)[NSNull null])) {
             int clientType = (int)[RCTConvert JWAdClient:adClient];
             JWAdClient jwAdClient;
             switch (clientType) {
                 case 0:
                     jwAdClient = JWAdClientJWPlayer;
                     break;
                 case 1:
    //                 JWImaAdvertisingConfigBuilder
                     jwAdClient = JWAdClientGoogleIMA;
                     break;
                 case 2:
    //                 JWImaDaiAdvertisingConfigBuilder
                     jwAdClient = JWAdClientGoogleIMADAI;
                     break;
                 case 3:
                     jwAdClient = JWAdClientUnknown;
                     break;

                 default:
                     jwAdClient = JWAdClientUnknown;
                     break;
             }
         } else {

         }
        
        // [adConfigBuilder adRules:(JWAdRules * _Nonnull)];
        
        id schedule = ads[@"adSchedule"];
        if(schedule != nil && (schedule != (id)[NSNull null])) {
            NSArray* scheduleAr = (NSArray*)schedule;
            if (scheduleAr.count > 0) {
                NSMutableArray <JWAdBreak*>* scheduleArray = [[NSMutableArray alloc] init];
                
                for (id item in scheduleAr) {
                    NSString *offsetString = [item objectForKey:@"offset"];
                    NSString *tag = [item objectForKey:@"tag"];
                    NSURL* tagUrl = [NSURL URLWithString:tag];
                    
                    JWAdBreak *adBreak = [JWAdBreak init];
                    JWAdBreakBuilder* adBreakBuilder = [[JWAdBreakBuilder alloc] init];
                    JWAdOffset* offset = [JWAdOffset fromString:offsetString];
                    
                    [adBreakBuilder offset:offset];
                    [adBreakBuilder tags:@[tagUrl]];
                    
                    adBreak = [adBreakBuilder buildAndReturnError:&error];
                    
                    [scheduleArray addObject:adBreak];
                }
            
                if (scheduleArray.count > 0) {
                    [adConfigBuilder schedule:scheduleArray];
                }
            }
        }
        
        id tag = ads[@"tag"];
        if (tag != nil && (tag != (id)[NSNull null])) {
            NSURL* tagUrl = [NSURL URLWithString:tag];
            [adConfigBuilder tag:tagUrl];
        }
                
        id adVmap = ads[@"adVmap"];
        if (adVmap != nil && (adVmap != (id)[NSNull null])) {
            NSURL* adVmapUrl = [NSURL URLWithString:adVmap];
            [adConfigBuilder vmapURL:adVmapUrl];
        }
        
        id openBrowserOnAdClick = ads[@"openBrowserOnAdClick"];
        if (openBrowserOnAdClick != nil && (openBrowserOnAdClick != (id)[NSNull null])) {
            [adConfigBuilder openBrowserOnAdClick:openBrowserOnAdClick];
        }
        
        advertising = [adConfigBuilder buildAndReturnError:&error];
        [configBuilder advertising:advertising];
    }
    
    JWPlayerConfiguration* playerConfig = [configBuilder buildAndReturnError:&error];
    
    return playerConfig;
}

#pragma mark - JWPlayer View Controller helpers

-(void)setupPlayerViewController:config :(JWPlayerConfiguration*)playerConfig
{
    [self dismissPlayerViewController];
    
    _playerViewController = [JWPlayerViewController new];
    _playerViewController.delegate = self;
    
//    id interfaceBehavior = config[@"interfaceBehavior"];
//    if ((interfaceBehavior != nil) && (interfaceBehavior != (id)[NSNull null])) {
//        _playerViewController.interfaceBehavior = [RCTConvert JWInterfaceBehavior:interfaceBehavior];
//    }
    
    id forceFullScreenOnLandscape = config[@"fullScreenOnLandscape"];
    if (forceFullScreenOnLandscape != nil && forceFullScreenOnLandscape != (id)[NSNull null]) {
        _playerViewController.forceFullScreenOnLandscape = forceFullScreenOnLandscape;
    }
    
    id forceLandscapeOnFullScreen = config[@"landscapeOnFullScreen"];
    if (forceLandscapeOnFullScreen != nil && forceLandscapeOnFullScreen != (id)[NSNull null]) {
        _playerViewController.forceLandscapeOnFullScreen = forceLandscapeOnFullScreen;
    }
    
    id enableLockScreenControls = config[@"enableLockScreenControls"];
    if (enableLockScreenControls != nil && enableLockScreenControls != (id)[NSNull null]) {
        _playerViewController.enableLockScreenControls = enableLockScreenControls;
    }
    
    id styling = config[@"styling"];
    [self setStyling:styling];
    
    JWError* error = nil;
    
    id nextUpStyle = config[@"nextUpStyle"];
    if (nextUpStyle != nil && nextUpStyle != (id)[NSNull null]) {
        JWNextUpStyleBuilder* nextUpBuilder = [[JWNextUpStyleBuilder alloc] init];
        
        id offsetSeconds = nextUpStyle[@"offsetSeconds"];
        id offsetPercentage = nextUpStyle[@"offsetPercentage"];
        
        [nextUpBuilder timeOffsetWithSeconds:[offsetSeconds doubleValue]];
        [nextUpBuilder timeOffsetWithPercentage:[offsetPercentage doubleValue]];
        _playerViewController.nextUpStyle = [nextUpBuilder buildAndReturnError:&error];
    }
    
//    _playerViewController.adInterfaceStyle
//    _playerViewController.logo
//    _playerView.videoGravity = 0;
//    _playerView.captionStyle
    
    id offlineMsg = config[@"offlineMessage"];
    if (offlineMsg != nil && offlineMsg != (id)[NSNull null]) {
        _playerViewController.offlineMessage = offlineMsg;
    }
    
    id offlineImg = config[@"offlineImage"];
    if (offlineImg != nil && offlineImg != (id)[NSNull null]) {
        NSURL* imageUrl = [NSURL URLWithString:offlineImg];
        if ([imageUrl isFileURL]) {
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
            _playerViewController.offlinePosterImage = image;
        }
    }
    
    [self presentPlayerViewController:playerConfig];
}

-(void)dismissPlayerViewController
{
    if (_playerViewController != nil) {
        [_playerViewController willMoveToParentViewController:nil];
        [_playerViewController.view removeFromSuperview];
        [_playerViewController removeFromParentViewController];
        _playerViewController = nil;
    }
}

-(void)presentPlayerViewController:(JWPlayerConfiguration*)configuration
{
    UIWindow *window = (UIWindow*)[[UIApplication sharedApplication] keyWindow];
    [window.rootViewController addChildViewController:_playerViewController];
    _playerViewController.view.frame = self.superview.frame;
    [self addSubview:_playerViewController.view];
    [_playerViewController didMoveToParentViewController:window.rootViewController];
    
    // before presentation of viewcontroller player is nil so acces only after
    if (configuration != nil) {
        [_playerViewController.player configurePlayerWith:configuration];
    }

    _playerViewController.playerView.delegate = self;
    _playerViewController.player.delegate = self;
    _playerViewController.player.playbackStateDelegate = self;
    _playerViewController.player.adDelegate = self;
    _playerViewController.player.avDelegate = self;
}

#pragma mark - JWPlayer View helpers

-(void)setupPlayerView:config :(JWPlayerConfiguration*)playerConfig
{
    _playerView = [[JWPlayerView new] initWithFrame:self.superview.frame];
    
    _playerView.delegate = self;
    _playerView.player.delegate = self;
    _playerView.player.playbackStateDelegate = self;
    _playerView.player.adDelegate = self;
    _playerView.player.avDelegate = self;
    
    [_playerView.player configurePlayerWith:playerConfig];

    if (_pipEnabled) {
        AVPictureInPictureController* pipController = _playerView.pictureInPictureController;
        pipController.delegate = self;
        
        [pipController addObserver:self forKeyPath:@"isPictureInPicturePossible" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
    }
    
    [self addSubview:self.playerView];
}

-(void)removePlayerView
{
    if (_playerView != nil) {
        [_playerView removeFromSuperview];
        _playerView = nil;
    }
}

#pragma mark - JWPlayer Delegate

- (void)jwplayerIsReady:(id<JWPlayer>)player
{
    if (self.onPlayerReady) {
        self.onPlayerReady(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player failedWithError:(NSUInteger)code message:(NSString *)message
{
    if (self.onPlayerError) {
        self.onPlayerError(@{@"error": message});
    }
}

- (void)jwplayer:(id<JWPlayer>)player failedWithSetupError:(NSUInteger)code message:(NSString *)message
{
    if (self.onSetupPlayerError) {
        self.onSetupPlayerError(@{@"error": message});
    }
}

- (void)jwplayer:(id<JWPlayer>)player encounteredWarning:(NSUInteger)code message:(NSString *)message
{
    if (self.onPlayerWarning) {
        self.onPlayerWarning(@{@"warning": message});
    }
}

- (void)jwplayer:(id<JWPlayer> _Nonnull)player encounteredAdError:(NSUInteger)code message:(NSString * _Nonnull)message {
    if (self.onPlayerAdError) {
        self.onPlayerAdError(@{@"error": message});
    }
}


- (void)jwplayer:(id<JWPlayer> _Nonnull)player encounteredAdWarning:(NSUInteger)code message:(NSString * _Nonnull)message {
    if (self.onPlayerAdWarning) {
        self.onPlayerAdWarning(@{@"warning": message});
    }
}


#pragma mark - JWPlayer View Delegate

- (void)playerView:(JWPlayerView *)view sizeChangedFrom:(CGSize)oldSize to:(CGSize)newSize
{
    if (self.onPlayerSizeChange) {
        NSMutableDictionary* oldSizeDict = [[NSMutableDictionary alloc] init];
        [oldSizeDict setObject:[NSNumber numberWithFloat: oldSize.width] forKey:@"width"];
        [oldSizeDict setObject:[NSNumber numberWithFloat: oldSize.height] forKey:@"height"];
        
        NSMutableDictionary* newSizeDict = [[NSMutableDictionary alloc] init];
        [newSizeDict setObject:[NSNumber numberWithFloat: newSize.width] forKey:@"width"];
        [newSizeDict setObject:[NSNumber numberWithFloat: newSize.height] forKey:@"height"];
        
        NSMutableDictionary* sizesDict = [[NSMutableDictionary alloc] init];
        [sizesDict setObject:oldSizeDict forKey:@"oldSize"];
        [sizesDict setObject:newSizeDict forKey:@"newSize"];
        
        NSError* error = nil;
        NSData* data = [NSJSONSerialization dataWithJSONObject:sizesDict options:NSJSONWritingPrettyPrinted error: &error];
        self.onPlayerSizeChange(@{@"sizes": data});
    }
}

#pragma mark - JWPlayer View Controller Delegate

- (void)playerViewController:(JWPlayerViewController *)controller sizeChangedFrom:(CGSize)oldSize to:(CGSize)newSize
{
    if (self.onPlayerSizeChange) {
        NSMutableDictionary* oldSizeDict = [[NSMutableDictionary alloc] init];
        [oldSizeDict setObject:[NSNumber numberWithFloat: oldSize.width] forKey:@"width"];
        [oldSizeDict setObject:[NSNumber numberWithFloat: oldSize.height] forKey:@"height"];
        
        NSMutableDictionary* newSizeDict = [[NSMutableDictionary alloc] init];
        [newSizeDict setObject:[NSNumber numberWithFloat: newSize.width] forKey:@"width"];
        [newSizeDict setObject:[NSNumber numberWithFloat: newSize.height] forKey:@"height"];
        
        NSMutableDictionary* sizesDict = [[NSMutableDictionary alloc] init];
        [sizesDict setObject:oldSizeDict forKey:@"oldSize"];
        [sizesDict setObject:newSizeDict forKey:@"newSize"];
        
        NSError* error = nil;
        NSData* data = [NSJSONSerialization dataWithJSONObject:sizesDict options:NSJSONWritingPrettyPrinted error: &error];
        self.onPlayerSizeChange(@{@"sizes": data});
    }
}

- (void)playerViewController:(JWPlayerViewController *)controller screenTappedAt:(CGPoint)position
{
    if (self.onScreenTapped) {
        self.onScreenTapped(@{@"x": @(position.x), @"y": @(position.y)});
    }
}

- (void)playerViewController:(JWPlayerViewController *)controller controlBarVisibilityChanged:(BOOL)isVisible frame:(CGRect)frame
{
    if (self.onControlBarVisible) {
        self.onControlBarVisible(@{@"visible": @(isVisible)});
    }
}

- (JWFullScreenViewController * _Nullable)playerViewControllerWillGoFullScreen:(JWPlayerViewController * _Nonnull)controller {
    if (self.onFullScreenRequested) {
        self.onFullScreenRequested(@{});
    }
    return nil;
}

- (void)playerViewControllerDidGoFullScreen:(JWPlayerViewController *)controller
{
    if (self.onFullScreen) {
        self.onFullScreen(@{});
    }
}

- (void)playerViewControllerWillDismissFullScreen:(JWPlayerViewController *)controller
{
    if (self.onFullScreenExitRequested) {
        self.onFullScreenExitRequested(@{});
    }
}

- (void)playerViewControllerDidDismissFullScreen:(JWPlayerViewController *)controller
{
    if (self.onFullScreenExit) {
        self.onFullScreenExit(@{});
    }
}

- (void)playerViewController:(JWPlayerViewController *)controller relatedMenuClosedWithMethod:(enum JWRelatedInteraction)method
{
    
}

- (void)playerViewController:(JWPlayerViewController *)controller relatedMenuOpenedWithItems:(NSArray<JWPlayerItem *> *)items withMethod:(enum JWRelatedInteraction)method
{
    
}

- (void)playerViewController:(JWPlayerViewController *)controller relatedItemBeganPlaying:(JWPlayerItem *)item atIndex:(NSInteger)index withMethod:(enum JWRelatedInteraction)method
{
    
}

#pragma mark - AV Picture In Picture Delegate

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context
{
    if (_playerView != nil && [object isEqual:_playerView.pictureInPictureController] && [keyPath isEqualToString:@"isPictureInPicturePossible"]) {
        
    }
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    
}

- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error
{
    
}

- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler
{
    
}

#pragma mark - JWPlayer State Delegate

- (void)jwplayerContentIsBuffering:(id<JWPlayer>)player
{
    if (_playerViewController) {
        [_playerViewController jwplayerContentIsBuffering:player];
    }
    
    if (self.onBuffer) {
        self.onBuffer(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player updatedBuffer:(double)percent position:(JWTimeData *)time
{
    if (_playerViewController) {
        [_playerViewController jwplayer:player updatedBuffer:percent position:time];
    }
    
    if (self.onUpdateBuffer) {
        self.onUpdateBuffer(@{@"percent": @(percent), @"position": time});
    }
}

- (void)jwplayer:(id<JWPlayer>)player didFinishLoadingWithTime:(NSTimeInterval)loadTime
{
    if (_playerViewController) {
        [_playerViewController jwplayer:player didFinishLoadingWithTime:loadTime];
    }
    
    if (self.onLoaded) {
        self.onLoaded(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player isAttemptingToPlay:(JWPlayerItem *)playlistItem reason:(enum JWPlayReason)reason
{
    if (_playerViewController) {
        [_playerViewController jwplayer:player isAttemptingToPlay:playlistItem reason:reason];
    }
    
    if (self.onAttemptPlay) {
        self.onAttemptPlay(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player isPlayingWithReason:(enum JWPlayReason)reason
{
    if (_playerViewController) {
        [_playerViewController jwplayer:player isPlayingWithReason:reason];
    }
    
    if (self.onPlay) {
        self.onPlay(@{});
    }
    
    _userPaused = NO;
    _wasInterrupted = NO;
}

- (void)jwplayer:(id<JWPlayer>)player willPlayWithReason:(enum JWPlayReason)reason
{
    if (_playerViewController) {
        [_playerViewController jwplayer:player willPlayWithReason:reason];
    }
    
    if (self.onBeforePlay) {
        self.onBeforePlay(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player didPauseWithReason:(enum JWPauseReason)reason
{
    if (_playerViewController) {
        [_playerViewController jwplayer:player didPauseWithReason:reason];
    }
    
    if (self.onPause) {
        self.onPause(@{});
    }
    
    if (!_wasInterrupted) {
        _userPaused = YES;
    }
}

- (void)jwplayer:(id<JWPlayer>)player didBecomeIdleWithReason:(enum JWIdleReason)reason
{
    if (_playerViewController) {
        [_playerViewController jwplayer:player didBecomeIdleWithReason:reason];
    }
    
    if (self.onIdle) {
        self.onIdle(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player isVisible:(BOOL)isVisible
{
    if (_playerViewController) {
        [_playerViewController jwplayer:player isVisible:isVisible];
    }
    
    if (self.onVisible) {
        self.onVisible(@{@"visible": @(isVisible)});
    }
}

- (void)jwplayerContentWillComplete:(id<JWPlayer>)player
{
    if (_playerViewController) {
        [_playerViewController jwplayerContentWillComplete:player];
    }
    
    if (self.onBeforeComplete) {
        self.onBeforeComplete(@{});
    }
}

- (void)jwplayerContentDidComplete:(id<JWPlayer>)player
{
    if (_playerViewController) {
        [_playerViewController jwplayerContentDidComplete:player];
    }
    
    if (self.onComplete) {
        self.onComplete(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player didLoadPlaylistItem:(JWPlayerItem *)item at:(NSUInteger)index
{
    if (_playerViewController) {
        [_playerViewController jwplayer:player didLoadPlaylistItem:item at:index];
    }
    
    if (self.onPlaylistItem) {
        NSMutableDictionary* sourceDict = [[NSMutableDictionary alloc] init];
        for (JWVideoSource* source in item.videoSources) {
            [sourceDict setObject:source.file forKey:@"file"];
            [sourceDict setObject:source.label forKey:@"label"];
            [sourceDict setObject:@(source.defaultVideo) forKey:@"default"];
        }
        
        NSMutableDictionary* schedDict = [[NSMutableDictionary alloc] init];
        for (JWAdBreak* sched in item.adSchedule) {
            [schedDict setObject:sched.offset forKey:@"offset"];
            [schedDict setObject:sched.tagArray forKey:@"tags"];
            [schedDict setObject:@(sched.type) forKey:@"type"];
        }
        
        NSMutableDictionary* trackDict = [[NSMutableDictionary alloc] init];
        for (JWMediaTrack* track in item.mediaTracks) {
            [trackDict setObject:track.file forKey:@"file"];
            [trackDict setObject:track.label forKey:@"label"];
            [trackDict setObject:@(track.defaultTrack) forKey:@"default"];
        }
        
        NSDictionary* itemDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  item.mediaId, @"mediaId",
                                  item.title, @"title",
                                  item.description, @"description",
                                  item.posterImage.absoluteString, @"image",
                                  @(item.startTime), @"startTime",
                                  item.vmapURL.absoluteString, @"adVmap",
                                  item.recommendations.absoluteString, @"recommendations",
                                  sourceDict, @"sources",
                                  schedDict, @"adSchedule",
                                  trackDict, @"tracks",
                                  nil];

        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:itemDict options:NSJSONWritingPrettyPrinted error: &error];
        
        self.onPlaylistItem(@{@"playlistItem": [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], @"index": [NSNumber numberWithInteger:index]});
    }
}

- (void)jwplayer:(id<JWPlayer>)player didLoadPlaylist:(NSArray<JWPlayerItem *> *)playlist
{
    if (_playerViewController) {
        [_playerViewController jwplayer:player didLoadPlaylist:playlist];
    }
    
    if (self.onPlaylist) {
        NSMutableArray* playlistArray = [[NSMutableArray alloc] init];
        
        for (JWPlayerItem* item in playlist) {
            NSMutableDictionary* sourceDict = [[NSMutableDictionary alloc] init];
            for (JWVideoSource* source in item.videoSources) {
                [sourceDict setObject:source.file forKey:@"file"];
                [sourceDict setObject:source.label forKey:@"label"];
                [sourceDict setObject:@(source.defaultVideo) forKey:@"default"];
            }
            
            NSMutableDictionary* schedDict = [[NSMutableDictionary alloc] init];
            for (JWAdBreak* sched in item.adSchedule) {
                [schedDict setObject:sched.offset forKey:@"offset"];
                [schedDict setObject:sched.tagArray forKey:@"tags"];
                [schedDict setObject:@(sched.type) forKey:@"type"];
            }
            
            NSMutableDictionary* trackDict = [[NSMutableDictionary alloc] init];
            for (JWMediaTrack* track in item.mediaTracks) {
                [trackDict setObject:track.file forKey:@"file"];
                [trackDict setObject:track.label forKey:@"label"];
                [trackDict setObject:@(track.defaultTrack) forKey:@"default"];
            }
            
            NSDictionary* itemDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      item.mediaId, @"mediaId",
                                      item.title, @"title",
                                      item.description, @"description",
                                      item.posterImage.absoluteString, @"image",
                                      @(item.startTime), @"startTime",
                                      item.vmapURL.absoluteString, @"adVmap",
                                      item.recommendations.absoluteString, @"recommendations",
                                      sourceDict, @"sources",
                                      schedDict, @"adSchedule",
                                      trackDict, @"tracks",
                                      nil];
            
            [playlistArray addObject:itemDict];
        }
        
        NSError *error;
        NSData* data = [NSJSONSerialization dataWithJSONObject:playlistArray options:NSJSONWritingPrettyPrinted error: &error];
        
        self.onPlaylist(@{@"playlist": [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]});
    }
}

- (void)jwplayerPlaylistHasCompleted:(id<JWPlayer>)player
{
    if (_playerViewController) {
        [_playerViewController jwplayerPlaylistHasCompleted:player];
    }
    
    if (self.onPlaylistComplete) {
        self.onPlaylistComplete(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player usesMediaType:(enum JWMediaType)type
{
    if (_playerViewController) {
        [_playerViewController jwplayer:player usesMediaType:type];
    }
}

- (void)jwplayer:(id<JWPlayer>)player seekedFrom:(NSTimeInterval)oldPosition to:(NSTimeInterval)newPosition
{
    if (_playerViewController) {
        [_playerViewController jwplayer:player seekedFrom:oldPosition to:newPosition];
    }
    
    if (self.onSeek) {
        self.onSeek(@{@"from": @(oldPosition), @"to": @(newPosition)});
    }
}

- (void)jwplayerHasSeeked:(id<JWPlayer>)player
{
    if (_playerViewController) {
        [_playerViewController jwplayerHasSeeked:player];
    }
    
    if (self.onSeeked) {
        self.onSeeked(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player playbackRateChangedTo:(double)rate at:(NSTimeInterval)time
{
    if (_playerViewController) {
        [_playerViewController jwplayer:player playbackRateChangedTo:rate at:time];
    }
}

#pragma mark - JWPlayer Ad Delegate

- (void)jwplayer:(id _Nonnull)player adEvent:(JWAdEvent * _Nonnull)event {
    if (self.onAdEvent) {
        self.onAdEvent(@{@"client": @(event.client), @"type": @(event.type)});
    }
}

#pragma Mark - Casting methods

-(void)setUpCastController
{
   if (_playerView != nil && _playerView.player != nil && _castController == nil) {
       _castController = [[JWCastController alloc] initWithPlayer:_playerView.player];
       _castController.delegate = self;
   }
   
   [self scanForDevices];
}

- (void)scanForDevices
{
   if (_castController != nil) {
       [_castController startDiscovery];
   }
}

- (void)stopScanForDevices
{
   if (_castController != nil) {
       [_castController stopDiscovery];
   }
}

- (void)presentCastDialog
{
    [GCKCastContext.sharedInstance presentCastDialog];
}

- (void)startDiscovery
{
    [[GCKCastContext.sharedInstance discoveryManager] startDiscovery];
}

- (void)stopDiscovery
{
    [[GCKCastContext.sharedInstance discoveryManager] stopDiscovery];
}

- (BOOL)discoveryActive
{
    return [[GCKCastContext.sharedInstance discoveryManager] discoveryActive];
}

- (BOOL)hasDiscoveredDevices
{
    return [[GCKCastContext.sharedInstance discoveryManager] hasDiscoveredDevices];
}

- (GCKDiscoveryState)discoveryState
{
    return [[GCKCastContext.sharedInstance discoveryManager] discoveryState];
}

- (void)setPassiveScan:(BOOL)passive
{
    [[GCKCastContext.sharedInstance discoveryManager] setPassiveScan:passive];
}

- (GCKCastState)castState
{
    return [GCKCastContext.sharedInstance castState];
}

- (NSUInteger)deviceCount
{
    return [[GCKCastContext.sharedInstance discoveryManager] deviceCount];
}

- (NSArray <JWCastingDevice *>*)availableDevices
{
    return _castController.availableDevices;
}

- (JWCastingDevice*)connectedDevice
{
    return _castController.connectedDevice;
}

- (void)connectToDevice:(JWCastingDevice*)device
{
    return [_castController connectToDevice:device];
}

- (void)cast
{
    return [_castController cast];
}

- (void)stopCasting
{
    return [_castController stopCasting];
}

#pragma mark - JWPlayer Cast Delegate

- (void)castController:(JWCastController * _Nonnull)controller castingBeganWithDevice:(JWCastingDevice * _Nonnull)device {
    if (self.onCasting) {
        self.onCasting(@{});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller castingEndedWithError:(NSError * _Nullable)error {
    if (self.onCastingEnded) {
        self.onCastingEnded(@{@"error": error});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller castingFailedWithError:(NSError * _Nonnull)error {
    if (self.onCastingFailed) {
        self.onCastingFailed(@{@"error": error});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller connectedTo:(JWCastingDevice * _Nonnull)device {
    if (self.onConnectedToCastingDevice) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
        [dict setObject:device.name forKey:@"name"];
        [dict setObject:device.identifier forKey:@"identifier"];

        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error: &error];
        
        self.onConnectedToCastingDevice(@{@"device": [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller connectionFailedWithError:(NSError * _Nonnull)error {
    if (self.onConnectionFailed) {
        self.onConnectionFailed(@{@"error": error});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller connectionRecoveredWithDevice:(JWCastingDevice * _Nonnull)device {
    if (self.onConnectionRecovered) {
        self.onConnectionRecovered(@{});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller connectionSuspendedWithDevice:(JWCastingDevice * _Nonnull)device {
    if (self.onConnectionTemporarilySuspended) {
        self.onConnectionTemporarilySuspended(@{});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller devicesAvailable:(NSArray<JWCastingDevice *> * _Nonnull)devices {
    self.availableDevices = devices;
    
    if (self.onCastingDevicesAvailable) {
        NSMutableArray *devicesInfo = [[NSMutableArray alloc] init];

        for (JWCastingDevice *device in devices) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                
            [dict setObject:device.name forKey:@"name"];
            [dict setObject:device.identifier forKey:@"identifier"];

            [devicesInfo addObject:dict];
        }

        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:devicesInfo options:NSJSONWritingPrettyPrinted error: &error];
        
        self.onCastingDevicesAvailable(@{@"devices": [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller disconnectedWithError:(NSError * _Nullable)error {
    if (self.onDisconnectedFromCastingDevice) {
        self.onDisconnectedFromCastingDevice(@{@"error": error});
    }
}

#pragma mark - JWPlayer AV Delegate

- (void)jwplayer:(id<JWPlayer> _Nonnull)player audioTracksUpdated:(NSArray<JWMediaSelectionOption *> * _Nonnull)levels {
    if (self.onAudioTracks) {
        self.onAudioTracks(@{});
    }
}

- (void)jwplayer:(id<JWPlayer> _Nonnull)player audioTrackChanged:(NSInteger)currentLevel {
    
}

- (void)jwplayer:(id<JWPlayer> _Nonnull)player captionPresented:(NSArray<NSString *> * _Nonnull)caption at:(JWTimeData * _Nonnull)time {
    
}

- (void)jwplayer:(id<JWPlayer> _Nonnull)player captionTrackChanged:(NSInteger)index {
    
}

- (void)jwplayer:(id<JWPlayer> _Nonnull)player qualityLevelChanged:(NSInteger)currentLevel {
    
}

- (void)jwplayer:(id<JWPlayer> _Nonnull)player qualityLevelsUpdated:(NSArray<JWVideoSource *> * _Nonnull)levels {
    
}

- (void)jwplayer:(id<JWPlayer> _Nonnull)player updatedCaptionList:(NSArray<JWMediaSelectionOption *> * _Nonnull)options {
    
}

#pragma mark - JWPlayer audio session && interruption handling

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
    
    if (_playerView != nil) {
        [_playerView.player pause];
    } else if (_playerViewController != nil) {
        [_playerViewController.player pause];
    }
}

-(void)audioInterruptionsEnded:(NSNotification *)note {
    if (!_userPaused && _backgroundAudioEnabled) {
        if (_playerView != nil) {
            [_playerView.player play];
        } else if (_playerViewController != nil) {
            [_playerViewController.player play];
        }
    }
}

@end
