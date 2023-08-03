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

- (void)removeFromSuperview {
    [self startDeinitProcess];
}

-(void)startDeinitProcess
{
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    } @catch(id anException) {
       
    }
    
    [self reset];
    [super removeFromSuperview];
}

-(void)reset
{
    @try {
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionMediaServicesWereResetNotification object:_audioSession];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:_audioSession];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
        
        if (_playerViewController || _playerView) {
            [[_playerViewController.player currentItem] removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:nil];
            if (_playerView) {
                [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"isPictureInPicturePossible" context:NULL];
            }
        }
    } @catch(id anException) {
       
    }
    
    [self removePlayerView];
    [self dismissPlayerViewController];
    
    [self deinitAudioSession];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.playerView != nil) {
        self.playerView.frame = self.frame;
    }
    
    if (self.playerViewController != nil) {
        self.playerViewController.view.frame = self.frame;
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

-(void)setLicense:(id)license
{
    if ((license != nil) && (license != (id)[NSNull null])) {
        [JWPlayerKitLicense setLicenseKey:license];
    } else {
        NSLog(@"JW SDK License key not set.");
    }
}

- (NSArray *)keysForDifferingValuesInDict1:(NSDictionary *)dict1 andDict2:(NSDictionary *)dict2 {
    NSMutableArray *diffKeys = [NSMutableArray new];
    for (NSString *key in dict1) {
        if (![dict1[key] isEqual:dict2[key]]) {
            [diffKeys addObject:key];
        }
    }
    return [diffKeys copy];
}

- (void)setConfig:(NSDictionary*)config
{
    // Create mutable copies of the dictionaries
    NSMutableDictionary *configCopy = [config mutableCopy];
    NSMutableDictionary *currentConfigCopy = [_currentConfig mutableCopy];
    
    // Remove the playlist key
    [configCopy removeObjectForKey:@"playlist"];
    [currentConfigCopy removeObjectForKey:@"playlist"];

    // Compare dictionaries without playlist key
    if (![configCopy isEqualToDictionary:currentConfigCopy]) {
        NSLog(@"There are differences other than the 'playlist' key.");
        
        NSArray *diffKeys = [self keysForDifferingValuesInDict1:configCopy andDict2:currentConfigCopy];
        NSLog(@"There are differences in these keys: %@", diffKeys);
        
        [self setNewConfig:config];
    } else {
        // Compare original dictionaries
        if(![_currentConfig isEqualToDictionary:config]) {
            NSLog(@"The only difference is the 'playlist' key.");
            
            if (_playerViewController || _playerView) {
                NSMutableArray <JWPlayerItem *> *playlistArray = [[NSMutableArray alloc] init];
                
                for (id item in config[@"playlist"]) {
                    JWPlayerItem *playerItem = [self getPlayerItem:item];
                    [playlistArray addObject:playerItem];
                }
                
                if (_playerViewController) {
                    [_playerViewController.player loadPlaylistWithItems:playlistArray];
                } else { // if (_playerView)
                    [_playerView.player loadPlaylistWithItems:playlistArray];
                }
            } else {
                [self setNewConfig:config];
            }
        } else {
            NSLog(@"There are no differences.");
        }
    }
}

-(void)setNewConfig:(NSDictionary*)config
{
    _currentConfig = config;
    
    if (!_settingConfig) {
        _pendingConfig = NO;
        _settingConfig = YES;
        
        id license = config[@"license"];
        [self setLicense:license];
        
        _backgroundAudioEnabled = [config[@"backgroundAudioEnabled"] boolValue];
        _pipEnabled = [config[@"pipEnabled"] boolValue];
        if (_backgroundAudioEnabled || _pipEnabled) {
            id category = config[@"category"];
            id categoryOptions = config[@"categoryOptions"];
            id mode = config[@"mode"];
            
            [self initAudioSession:category :categoryOptions :mode];
        } else {
            [self deinitAudioSession];
        }
        
        id viewOnly = config[@"viewOnly"];
        if ((viewOnly != nil) && (viewOnly != (id)[NSNull null])) {
            [self setupPlayerView:config :[self getPlayerConfiguration:config]];
        } else {
            [self setupPlayerViewController:config :[self getPlayerConfiguration:config]];
        }

        _processSpcUrl = config[@"processSpcUrl"];
        _fairplayCertUrl = config[@"fairplayCertUrl"];
        _contentUUID = config[@"contentUUID"];
    } else {
        _pendingConfig = YES;
    }
}

-(void)setControls:(BOOL)controls
{
    [self toggleUIGroup:_playerViewController.view :@"JWPlayerKit.InterfaceView" :nil :controls];
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
    } else if (newFile != nil) {
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
                
                JWVideoSourceBuilder* sourceBuilder = [[JWVideoSourceBuilder alloc] init];
                
                [sourceBuilder file:fileUrl];
                [sourceBuilder label:label];
                [sourceBuilder defaultVideo:isDefault];
                
                [sourcesArray addObject:[sourceBuilder buildAndReturnError:&error]];
            }
            
            [itemBuilder videoSources:sourcesArray];
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
                bool isDefault = [item objectForKey:@"default"];
                
                JWCaptionTrackBuilder* trackBuilder = [[JWCaptionTrackBuilder alloc] init];
                
                [trackBuilder file:fileUrl];
                [trackBuilder label:label];
                [trackBuilder defaultTrack:isDefault];
                
                JWMediaTrack *trackItem = [trackBuilder buildAndReturnError:&error];
                
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
                
                JWAdBreakBuilder* adBreakBuilder = [[JWAdBreakBuilder alloc] init];
                JWAdOffset* offset = [JWAdOffset fromString:offsetString];
                
                [adBreakBuilder offset:offset];
                [adBreakBuilder tags:@[tagUrl]];
                
                JWAdBreak *adBreak = [adBreakBuilder buildAndReturnError:&error];
                
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
        
        [configBuilder playlistWithItems:playlistArray];
    }
    
    id autostart = config[@"autostart"];
    if ([autostart boolValue]) {
        [configBuilder autostart:autostart];
    }
    
    id repeatContent = config[@"repeat"];
    if (repeatContent != nil && (repeatContent != (id)[NSNull null])) {
        if ([repeatContent boolValue]) {
            [configBuilder repeatContent:repeatContent];
        }
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
                    
                    JWAdBreakBuilder* adBreakBuilder = [[JWAdBreakBuilder alloc] init];
                    JWAdOffset* offset = [JWAdOffset fromString:offsetString];
                    
                    [adBreakBuilder offset:offset];
                    [adBreakBuilder tags:@[tagUrl]];
                    
                    JWAdBreak *adBreak = [adBreakBuilder buildAndReturnError:&error];
                    
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
    if (_playerViewController == nil) {
        _playerViewController = [RNJWPlayerViewController new];
        _playerViewController.parentView = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.reactViewController) {
                [self.reactViewController addChildViewController:self.playerViewController];
                [self.playerViewController didMoveToParentViewController:self.reactViewController];
            } else {
                [self reactAddControllerToClosestParent:self.playerViewController];
            }
        });
        _playerViewController.view.frame = self.frame;
        [self addSubview:_playerViewController.view];
        [_playerViewController setDelegates];
    }
    
    id interfaceBehavior = config[@"interfaceBehavior"];
    if ((interfaceBehavior != nil) && (interfaceBehavior != (id)[NSNull null])) {
        _interfaceBehavior = [RCTConvert JWInterfaceBehavior:interfaceBehavior];
    }
    
    id forceFullScreenOnLandscape = config[@"fullScreenOnLandscape"];
    if (forceFullScreenOnLandscape != nil && forceFullScreenOnLandscape != (id)[NSNull null]) {
        _playerViewController.forceFullScreenOnLandscape = forceFullScreenOnLandscape;
    }
    
    id forceLandscapeOnFullScreen = config[@"landscapeOnFullScreen"];
    if (forceLandscapeOnFullScreen != nil && forceLandscapeOnFullScreen != (id)[NSNull null]) {
        _playerViewController.forceLandscapeOnFullScreen = forceLandscapeOnFullScreen;
    }
    
    id enableLockScreenControls = config[@"enableLockScreenControls"];
    if ((enableLockScreenControls != nil && enableLockScreenControls != (id)[NSNull null]) || _backgroundAudioEnabled) {
        _playerViewController.enableLockScreenControls = YES;
    }
    
    id allowsPictureInPicturePlayback = config[@"allowsPictureInPicturePlayback"];
    if ((allowsPictureInPicturePlayback != nil && allowsPictureInPicturePlayback != (id)[NSNull null])) {
        _playerViewController.allowsPictureInPicturePlayback = allowsPictureInPicturePlayback;
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
    if (_playerViewController) {
        [_playerViewController.player pause]; // hack for stop not always stopping on unmount
        [_playerViewController.player stop];
        _playerViewController.enableLockScreenControls = NO;
        
        // hack for stop not always stopping on unmount
        JWPlayerConfigurationBuilder *configBuilder = [[JWPlayerConfigurationBuilder alloc] init];
        [configBuilder playlistWithItems:@[]];
        NSError* error = nil;
        [_playerViewController.player configurePlayerWith:[configBuilder buildAndReturnError:&error]];
        
        _playerViewController.parentView = nil;
        [_playerViewController setVisibility:NO forControls:@[@(JWControlTypePictureInPictureButton)]];
        [_playerViewController.view removeFromSuperview];
        [_playerViewController removeFromParentViewController];
        [_playerViewController willMoveToParentViewController:nil];
        [_playerViewController removeDelegates];
        _playerViewController = nil;
    }
}

-(void)presentPlayerViewController:(JWPlayerConfiguration*)configuration
{
    if (configuration != nil) {
        [_playerViewController.player configurePlayerWith:configuration];
        
        if (_interfaceBehavior) {
            _playerViewController.interfaceBehavior = JWInterfaceBehaviorHidden;
        }
    }
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
    _playerView.player.contentKeyDataSource = self;
    
    [_playerView.player configurePlayerWith:playerConfig];

    if (_pipEnabled) {
        AVPictureInPictureController* pipController = _playerView.pictureInPictureController;
        pipController.delegate = self;
        
        [pipController addObserver:self forKeyPath:@"isPictureInPicturePossible" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
    }
    
    [self addSubview:self.playerView];
    
    id autostart = config[@"autostart"];
    if ([autostart boolValue]) {
        [_playerView.player play];
    }
    
    // Time observers
    __weak RNJWPlayerView *weakSelf = self;
    _playerView.player.adTimeObserver = ^(JWTimeData * time) {
        if (weakSelf.onAdTime) {
            weakSelf.onAdTime(@{@"position": @(time.position), @"duration": @(time.duration)});
        }
    };
    
    _playerView.player.mediaTimeObserver = ^(JWTimeData * time) {
        if (weakSelf.onTime) {
            weakSelf.onTime(@{@"position": @(time.position), @"duration": @(time.duration)});
        }
    };
}

-(void)removePlayerView
{
    if (_playerView) {
        [_playerView.player stop];
        [_playerView removeFromSuperview];
        _playerView = nil;
    }
}

-(void)toggleUIGroup:(UIView*)view :(NSString*)name :(NSString*)ofSubview :(BOOL)show
{
    NSArray *subviews = [view subviews];

    for (UIView *subview in subviews) {
        if ([NSStringFromClass(subview.class) isEqualToString:name] && (ofSubview == nil || [NSStringFromClass(subview.superview.class) isEqualToString:name])) {
            [subview setHidden:!show];
        } else {
            [self toggleUIGroup:subview :name :ofSubview :show];
        }
    }
}

- (void)setVisibility:(BOOL)isVisible forControls:(NSArray* _Nonnull)controls
{
    NSMutableArray<NSNumber *> * _controls = [[NSMutableArray alloc] init];
    
    for (id control in controls) {
        JWControlType type = [RCTConvert JWControlType:control];
        if (type) {
            [_controls addObject:@(type)];
        }
    }
    
    if ([_controls count]) {
        [_playerViewController setVisibility:isVisible forControls:_controls];
    }
}

#pragma mark - JWPlayer Delegate

- (void)jwplayerIsReady:(id<JWPlayer>)player
{
    _settingConfig = NO;
    if (self.onPlayerReady) {
        self.onPlayerReady(@{});
    }
    
    if (_pendingConfig && _currentConfig) {
        [self setConfig:_currentConfig];
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

#pragma mark - DRM Delegate

- (void)contentIdentifierForURL:(NSURL * _Nonnull)url completionHandler:(void (^ _Nonnull)(NSData * _Nullable))handler {
    if (!_contentUUID) {
        _contentUUID = [[url.absoluteString componentsSeparatedByString:@";"] lastObject];
    }
    
    NSData *uuidData = [_contentUUID dataUsingEncoding:NSUTF8StringEncoding];
    handler(uuidData);
}

- (void)appIdentifierForURL:(NSURL * _Nonnull)url completionHandler:(void (^ _Nonnull)(NSData * _Nullable))handler {
    NSURL *certURL = [NSURL URLWithString:_fairplayCertUrl];
    NSData *certData = [NSData dataWithContentsOfURL:certURL];
    handler(certData);
}

- (void)contentKeyWithSPCData:(NSData * _Nonnull)spcData completionHandler:(void (^ _Nonnull)(NSData * _Nullable, NSDate * _Nullable, NSString * _Nullable))handler {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSString *spcProcessURL = [NSString stringWithFormat:@"%@/%@?p1=%li", _processSpcUrl, _contentUUID, (NSInteger)currentTime];
    NSMutableURLRequest *ckcRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:spcProcessURL]];
    [ckcRequest setHTTPMethod:@"POST"];
    [ckcRequest setHTTPBody:spcData];
    [ckcRequest addValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
 
    [[[NSURLSession sharedSession] dataTaskWithRequest:ckcRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (error != nil || (httpResponse != nil && !NSLocationInRange(httpResponse.statusCode , NSMakeRange(200, (299 - 200))))) {
            handler(nil, nil, nil);
            return;
        }
 
        handler(data, nil, nil);
    }] resume];
}

#pragma mark - AV Picture In Picture Delegate

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context
{
    if (_playerView || _playerViewController) {
        if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            if (_playerView) {
                [_playerView.player play];
            } else if (_playerViewController) {
                [_playerViewController.player play];
            }
        } else if (_playerView && [object isEqual:_playerView.pictureInPictureController] && [keyPath isEqualToString:@"isPictureInPicturePossible"]) {
            
        }
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
    if (self.onBuffer) {
        self.onBuffer(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player isBufferingWithReason:(enum JWBufferReason)reason
{
    if (self.onBuffer) {
        self.onBuffer(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player updatedBuffer:(double)percent position:(JWTimeData *)time
{
    if (self.onUpdateBuffer) {
        self.onUpdateBuffer(@{@"percent": @(percent), @"position": time});
    }
}

- (void)jwplayer:(id<JWPlayer>)player didFinishLoadingWithTime:(NSTimeInterval)loadTime
{
    if (self.onLoaded) {
        self.onLoaded(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player isAttemptingToPlay:(JWPlayerItem *)playlistItem reason:(enum JWPlayReason)reason
{
    if (self.onAttemptPlay) {
        self.onAttemptPlay(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player isPlayingWithReason:(enum JWPlayReason)reason
{
    if (self.onPlay) {
        self.onPlay(@{});
    }
    
    _userPaused = NO;
    _wasInterrupted = NO;
}

- (void)jwplayer:(id<JWPlayer>)player willPlayWithReason:(enum JWPlayReason)reason
{
    if (self.onBeforePlay) {
        self.onBeforePlay(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player didPauseWithReason:(enum JWPauseReason)reason
{
    if (self.onPause) {
        self.onPause(@{});
    }
    
    if (!_wasInterrupted) {
        _userPaused = YES;
    }
}

- (void)jwplayer:(id<JWPlayer>)player didBecomeIdleWithReason:(enum JWIdleReason)reason
{
    if (self.onIdle) {
        self.onIdle(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player isVisible:(BOOL)isVisible
{
    if (self.onVisible) {
        self.onVisible(@{@"visible": @(isVisible)});
    }
}

- (void)jwplayerContentWillComplete:(id<JWPlayer>)player
{
    if (self.onBeforeComplete) {
        self.onBeforeComplete(@{});
    }
}

- (void)jwplayerContentDidComplete:(id<JWPlayer>)player
{
    if (self.onComplete) {
        self.onComplete(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player didLoadPlaylistItem:(JWPlayerItem *)item at:(NSUInteger)index
{
    if (self.onPlaylistItem) {
        NSMutableDictionary* sourceDict = [[NSMutableDictionary alloc] init];
        NSString *file;
        
        for (JWVideoSource* source in item.videoSources) {
            [sourceDict setObject:source.file forKey:@"file"];
            [sourceDict setObject:source.label forKey:@"label"];
            [sourceDict setObject:@(source.defaultVideo) forKey:@"default"];
            
            if (source.defaultVideo) {
                file = [source.file absoluteString];
            }
        }
        
        NSMutableDictionary* schedDict = [[NSMutableDictionary alloc] init];
        for (JWAdBreak* sched in item.adSchedule) {
            [schedDict setObject:sched.offset forKey:@"offset"];
            [schedDict setObject:sched.tags forKey:@"tags"];
            [schedDict setObject:@(sched.type) forKey:@"type"];
        }
        
        NSMutableDictionary* trackDict = [[NSMutableDictionary alloc] init];
        for (JWMediaTrack* track in item.mediaTracks) {
            [trackDict setObject:track.file forKey:@"file"];
            [trackDict setObject:track.label forKey:@"label"];
            [trackDict setObject:@(track.defaultTrack) forKey:@"default"];
        }
        
        NSDictionary* itemDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  file, @"file",
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
    
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)jwplayer:(id<JWPlayer>)player didLoadPlaylist:(NSArray<JWPlayerItem *> *)playlist
{
    if (self.onPlaylist) {
        NSMutableArray* playlistArray = [[NSMutableArray alloc] init];
        
        for (JWPlayerItem* item in playlist) {
            NSString *file;
            
            NSMutableDictionary* sourceDict = [[NSMutableDictionary alloc] init];
            for (JWVideoSource* source in item.videoSources) {
                [sourceDict setObject:source.file forKey:@"file"];
                [sourceDict setObject:source.label forKey:@"label"];
                [sourceDict setObject:@(source.defaultVideo) forKey:@"default"];
                
                if (source.defaultVideo) {
                    file = [source.file absoluteString];
                }
            }
            
            NSMutableDictionary* schedDict = [[NSMutableDictionary alloc] init];
            for (JWAdBreak* sched in item.adSchedule) {
                [schedDict setObject:sched.offset forKey:@"offset"];
                [schedDict setObject:sched.tags forKey:@"tags"];
                [schedDict setObject:@(sched.type) forKey:@"type"];
            }
            
            NSMutableDictionary* trackDict = [[NSMutableDictionary alloc] init];
            for (JWMediaTrack* track in item.mediaTracks) {
                [trackDict setObject:track.file forKey:@"file"];
                [trackDict setObject:track.label forKey:@"label"];
                [trackDict setObject:@(track.defaultTrack) forKey:@"default"];
            }
            
            NSDictionary* itemDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      file, @"file",
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
    if (self.onPlaylistComplete) {
        self.onPlaylistComplete(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player usesMediaType:(enum JWMediaType)type
{
   
}

- (void)jwplayer:(id<JWPlayer>)player seekedFrom:(NSTimeInterval)oldPosition to:(NSTimeInterval)newPosition
{
    if (self.onSeek) {
        self.onSeek(@{@"from": @(oldPosition), @"to": @(newPosition)});
    }
}

- (void)jwplayerHasSeeked:(id<JWPlayer>)player
{
    if (self.onSeeked) {
        self.onSeeked(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player playbackRateChangedTo:(double)rate at:(NSTimeInterval)time
{
    
}

- (void)jwplayer:(id<JWPlayer>)player updatedCues:(NSArray<JWCue *> * _Nonnull)cues
{
    
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
   if (_playerView && _playerView.player && !_castController) {
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

- (void)initAudioSession:(NSString*)category :(NSArray*)categoryOptions :(NSString*)mode
{
    [self setObservers];
    
    BOOL somethingChanged = NO;
    
    if (![category isEqualToString:_audioCategory] || ![categoryOptions isEqualToArray:_audioCategoryOptions]) {
        somethingChanged = YES;
        _audioCategory = category;
        _audioCategoryOptions = categoryOptions;
        [self setCategory:category categoryOptions:categoryOptions];
    }
    
    if (![mode isEqualToString:_audioMode]) {
        somethingChanged = YES;
        _audioMode = mode;
        [self setMode:mode];
    }
    
    if (somethingChanged) {
        NSError* activationError = nil;
        BOOL success = [_audioSession setActive:YES error:&activationError];
        NSLog(@"setActive - success: @%@, error: @%@", @(success), activationError);
    }
}

- (void)deinitAudioSession
{
    NSError* activationError = nil;
    BOOL success = [_audioSession setActive:NO withOptions: AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&activationError];
    NSLog(@"setUnactive - success: @%@, error: @%@", @(success), activationError);
    _audioSession = nil;
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = @{}.mutableCopy;
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

-(void)setObservers
{
    if (_audioSession == nil) {
        _audioSession = [AVAudioSession sharedInstance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMediaServicesReset)
                                                     name:AVAudioSessionMediaServicesWereResetNotification
                                                   object:_audioSession];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(audioSessionInterrupted:)
                                                     name: AVAudioSessionInterruptionNotification
                                                   object: _audioSession];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationWillResignActive:)
                                                         name:UIApplicationWillResignActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationDidEnterBackground:)
                                                         name:UIApplicationDidEnterBackgroundNotification
                                                       object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationWillEnterForeground:)
                                                         name:UIApplicationWillEnterForegroundNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(audioRouteChanged:)
                                                         name:AVAudioSessionRouteChangeNotification
                                                       object:nil];
    }
}

-(void)setCategory:(NSString *)categoryName categoryOptions :(NSArray *)categoryOptions
{
    if (!_audioSession) {
        _audioSession = [AVAudioSession sharedInstance];
    }
    
    NSString* category = nil;

    if ([categoryName isEqual:@"Ambient"]) {
        category = AVAudioSessionCategoryAmbient;
    } else if ([categoryName isEqual:@"SoloAmbient"]) {
        category = AVAudioSessionCategorySoloAmbient;
    } else if ([categoryName isEqual:@"Playback"]) {
        category = AVAudioSessionCategoryPlayback;
    } else if ([categoryName isEqual:@"Record"]) {
        category = AVAudioSessionCategoryRecord;
    } else if ([categoryName isEqual:@"PlayAndRecord"]) {
        category = AVAudioSessionCategoryPlayAndRecord;
    } else if ([categoryName isEqual:@"MultiRoute"]) {
        category = AVAudioSessionCategoryMultiRoute;
    } else {
        category = AVAudioSessionCategoryPlayback;
    }
    
    int options = 0;
    
    if ([categoryOptions containsObject:@"MixWithOthers"]) {
        options |= AVAudioSessionCategoryOptionMixWithOthers;
    } else if ([categoryOptions containsObject:@"DuckOthers"]) {
        options |= AVAudioSessionCategoryOptionDuckOthers;
    }  else if ([categoryOptions containsObject:@"AllowBluetooth"]) {
        options |= AVAudioSessionCategoryOptionAllowBluetooth;
    }  else if ([categoryOptions containsObject:@"InterruptSpokenAudioAndMix"]) {
        options |= AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers;
    }  else if ([categoryOptions containsObject:@"AllowBluetoothA2DP"]) {
        options |= AVAudioSessionCategoryOptionAllowBluetoothA2DP;
    } else if ([categoryOptions containsObject:@"AllowAirPlay"]) {
        options |= AVAudioSessionCategoryOptionAllowAirPlay;
    } else if ([categoryOptions containsObject:@"OverrideMutedMicrophone"]) {
        if (@available(iOS 14.5, *)) {
            options |= AVAudioSessionCategoryOptionOverrideMutedMicrophoneInterruption;
        } else {
            // Fallback on earlier versions
        }
    }

    NSError* categoryError = nil;
    BOOL success = [_audioSession setCategory:category withOptions:options error:&categoryError];
    NSLog(@"setCategory - success: @%@, error: @%@", @(success), categoryError);
}

-(void)setMode:(NSString *)modeName
{
    if (!_audioSession) {
        _audioSession = [AVAudioSession sharedInstance];
    }
    
    NSString* mode = nil;

    if ([modeName isEqual:@"Default"]) {
        mode = AVAudioSessionModeDefault;
    } else if ([modeName isEqual:@"VoiceChat"]) {
        mode = AVAudioSessionModeVoiceChat;
    } else if ([modeName isEqual:@"VideoChat"]) {
        mode = AVAudioSessionModeVideoChat;
    } else if ([modeName isEqual:@"GameChat"]) {
        mode = AVAudioSessionModeGameChat;
    } else if ([modeName isEqual:@"VideoRecording"]) {
        mode = AVAudioSessionModeVideoRecording;
    } else if ([modeName isEqual:@"Measurement"]) {
        mode = AVAudioSessionModeMeasurement;
    } else if ([modeName isEqual:@"MoviePlayback"]) {
        mode = AVAudioSessionModeMoviePlayback;
    } else if ([modeName isEqual:@"SpokenAudio"]) {
        mode = AVAudioSessionModeSpokenAudio;
    } else if ([modeName isEqual:@"VoicePrompt"]) {
        if (@available(iOS 12.0, *)) {
            mode = AVAudioSessionModeVoicePrompt;
        } else {
            // Fallback on earlier versions
        }
    }

    if (mode) {
        NSError* modeError = nil;
        BOOL success = [_audioSession setMode:mode error:&modeError];
        NSLog(@"setMode - success: @%@, error: @%@", @(success), modeError);
    }
}

// Interupted
-(void)audioSessionInterrupted:(NSNotification*)note
{
    NSNumber *interruptionType = [[note userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
    NSNumber *interruptionOption = [[note userInfo] objectForKey:AVAudioSessionInterruptionOptionKey];

    switch (interruptionType.unsignedIntegerValue) {
        case AVAudioSessionInterruptionTypeBegan: {
            _wasInterrupted = YES;
            
            if (_playerView) {
                [_playerView.player pause];
            } else if (_playerViewController) {
                [_playerViewController.player pause];
            }
        } break;
        case AVAudioSessionInterruptionTypeEnded: {
            if (interruptionOption.unsignedIntegerValue == AVAudioSessionInterruptionOptionShouldResume || (!_userPaused && _backgroundAudioEnabled)) {
                if (_playerView) {
                    [self->_playerView.player play];
                } else if (_playerViewController) {
                    [self->_playerViewController.player play];
                }
            }
        } break;
        default:
            break;
    }
}

// Service reset
-(void)handleMediaServicesReset
{
    // • Handle this notification by fully reconfiguring audio
}

// Inactive
// Hack for ios 14 stopping audio when going to background
-(void)applicationWillResignActive:(NSNotification *)notification {
    if (!_userPaused && _backgroundAudioEnabled) {
        if (_playerView && [_playerView.player getState] == JWPlayerStatePlaying) {
            [_playerView.player play];
        } else if (_playerViewController && [_playerViewController.player getState] == JWPlayerStatePlaying) {
            [_playerViewController.player play];
        }
    }
}

// Background
- (void)applicationDidEnterBackground:(NSNotification *)notification
{
  
}


// Active
-(void)applicationWillEnterForeground:(NSNotification *)notification{
    if (!_userPaused && _backgroundAudioEnabled) {
        if (_playerView && [_playerView.player getState] == JWPlayerStatePlaying) {
            [_playerView.player play];
        } else if (_playerViewController && [_playerViewController.player getState] == JWPlayerStatePlaying) {
            [_playerViewController.player play];
        }
    }
}

// Route change
- (void)audioRouteChanged:(NSNotification *)notification
{
  NSNumber *reason = [[notification userInfo] objectForKey:AVAudioSessionRouteChangeReasonKey];
//  NSNumber *previousRoute = [[notification userInfo] objectForKey:AVAudioSessionRouteChangePreviousRouteKey];
  if (reason.unsignedIntValue == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
      if (_playerView) {
          [_playerView.player pause];
      } else if (_playerViewController) {
          [_playerViewController.player pause];
      }
  }
}

@end
