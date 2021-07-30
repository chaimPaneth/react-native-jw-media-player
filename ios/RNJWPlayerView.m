#import "RNJWPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>

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

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.playerView != nil) {
        self.playerView.frame = self.frame;
    }
    
    if (_initFrame.size.height == 0) {
        _initFrame = self.frame;
    }
}

- (void)removeFromSuperview {
    [self reset];
    [super removeFromSuperview];
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

-(void)customStyle: (JWPlayerView*)playerView :(NSString*)name
{
    JWPlayerSkin *skinStyling = [JWPlayerSkin init];
    
//    skinStyling.url = [NSString stringWithFormat:@"file://%@", [[NSBundle mainBundle] pathForResource:name ofType:@"css"]];
//    skinStyling.name = name;
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



#pragma mark - RNJWPlayer props

-(BOOL)shouldAutorotate {
    return NO;
}

-(void)reset
{
    _playerView = nil;
}

-(JWPlayerItem*)getPlayerItem:item
{
    JWPlayerItemBuilder* itemBuilder = [JWPlayerItemBuilder new];
    
    NSString* newFile = [item objectForKey:@"file"];
    NSURL* url = [NSURL URLWithString:newFile];
    
    if (url && url.scheme && url.host) {
        [itemBuilder file:url];
    } else {
        NSString* encodedString = [newFile stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSURL* encodedUrl = [NSURL URLWithString:encodedString];
        [itemBuilder file:encodedUrl];
    }
    
    id mediaId = item[@"mediaId"];
    if ((mediaId != nil) && (mediaId != (id)[NSNull null])) {
        [itemBuilder mediaId:mediaId];
    }
    
    id title = item[@"title"];
    if ((title != nil) && (title != (id)[NSNull null])) {
        [itemBuilder title:title];
    }
    
    id desc = item[@"desc"];
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

    NSMutableArray <JWMediaTrack*> *tracksArray = [[NSMutableArray alloc] init];
    id tracksItem = item[@"tracks"];
    if(tracksItem != nil) {
        NSArray* tracksItemArray = (NSArray*)tracksItem;
        if(tracksItemArray.count > 0) {
            for (id item in tracksItemArray) {
                NSString *file = [item objectForKey:@"file"];
                NSURL *fileUrl = [NSURL URLWithString:file];
                NSString *label = [item objectForKey:@"label"];
                
                JWMediaTrack *trackItem = [JWMediaTrack init];
                JWCaptionTrackBuilder* trackBuilder = [JWCaptionTrackBuilder new];
                
                [trackBuilder file:fileUrl];
                [trackBuilder label:label];
                
                NSError* error = nil;
                trackItem = [trackBuilder buildAndReturnError:&error];
                
                [tracksArray addObject:trackItem];
            }
        }
    }
    if (tracksArray.count > 0) {
        [itemBuilder mediaTracks:tracksArray];
    }
    
    NSMutableArray <JWAdBreak*>* adsArray = [[NSMutableArray alloc] init];
    id ads = item[@"adSchedule"];
    if(ads != nil) {
        NSArray* adsAr = (NSArray*)ads;
        if(adsAr.count > 0) {
            for (id item in adsAr) {
                NSString *offsetString = [item objectForKey:@"offset"];
                NSString *tag = [item objectForKey:@"tag"];
                NSURL* tagUrl = [NSURL URLWithString:tag];
                
                JWAdBreak *adBreak = [JWAdBreak init];
                JWAdBreakBuilder* adBreakBuilder = [JWAdBreakBuilder new];
                JWAdOffset* offset = [JWAdOffset fromString:offsetString];
                
                [adBreakBuilder offset:offset];
                [adBreakBuilder tags:@[tagUrl]];
                
                NSError* error = nil;
                adBreak = [adBreakBuilder buildAndReturnError:&error];
                
                [adsArray addObject:adBreak];
            }
        }
    }

    if(adsArray.count > 0) {
        [itemBuilder adSchedule:adsArray];
    }
    
    NSError* error = nil;
    return [itemBuilder buildAndReturnError:&error];
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
        
        NSMutableArray <JWPlayerItem *> *playlistArray = [[NSMutableArray alloc] init];
        for (id item in playlist) {
            JWPlayerItem *playerItem = [self getPlayerItem:item];
            [playlistArray addObject:playerItem];
        }
        
        JWPlayerConfigurationBuilder *configBuilder = [JWPlayerConfigurationBuilder new];
        
        
//        JWAdClientJWPlayer = 0,
//      /// Google IMA
//        JWAdClientGoogleIMA = 1,
//      /// Google IMA DAI
//        JWAdClientGoogleIMADAI = 2,
//      /// An unrecognized ad client.
//        JWAdClientUnknown = 3,
        
//        JWAdsAdvertisingConfigBuilder* adConfigBuilder = [JWAdsAdvertisingConfigBuilder new];
        
//        id adClient = [playlist[0] objectForKey:@"adClient"];
//        if ((adClient != nil) && (adClient != (id)[NSNull null])) {
//            switch ([adClient intValue]) {
//                case 1:
//                    advertising.client = JWAdClientGoogima;
//                    break;
//                case 2:
//                    advertising.client = JWAdClientGoogimaDAI;
//                    break;
//                case 3:
//                    advertising.client = JWAdClientFreewheel;
//                    break;
//
//                default:
//                    advertising.client = JWAdClientVast;
//                    break;
//            }
//        } else {
//            advertising.client = JWAdClientVast;
//        }
//
//        config.advertising = advertising;
        
//        if ([playlist[0] objectForKey:@"adVmap"] != nil) {
//            id adVmap = [playlist[0] objectForKey:@"adVmap"];
//            if ((adVmap != nil) && (adVmap != (id)[NSNull null])) {
//                config.advertising.adVmap = adVmap;
//            }
//        }
        
        if (_playerView == nil) {
//            [self reset];
            
            [configBuilder playlist:playlistArray];
            [configBuilder autostart:YES];
            [configBuilder repeatContent:NO];
//            preload
//            JWRelatedContentConfiguration
//            [configBuilder related:(JWRelatedContentConfiguration * _Nonnull)]
            
            NSError* error = nil;
            JWPlayerConfiguration* config = [configBuilder buildAndReturnError:&error];
            
            _playerView = [[JWPlayerView new] initWithFrame:self.frame];
            _playerView.delegate = self;
            [_playerView.player configurePlayerWith:config];
            _playerView.player.delegate = self;
            _playerView.player.playbackStateDelegate = self;
            _playerView.player.adDelegate = self;
            _playerView.player.avDelegate = self;
            
            AVPictureInPictureController* pipController = _playerView.pictureInPictureController;
            pipController.delegate = self;
            
            [pipController addObserver:self forKeyPath:@"isPictureInPicturePossible" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
            
//            _playerView.videoGravity = 0;
//            _playerView.captionStyle
            
            [self addSubview:self.playerView];
            
//            JWPlayerViewController* controller = [JWPlayerViewController new];
//            controller.delegate = self;
//            controller.playerView.delegate = self;
//
//            controller.playerView.player.delegate = self;
//            controller.playerView.player.playbackStateDelegate = self;
//            controller.playerView.player.adDelegate = self;
//            controller.playerView.player.avDelegate = self;
////            controller.interfaceBehavior
////            controller.forceFullScreenOnLandscape
////            controller.forceLandscapeOnFullScreen
////            controller.adInterfaceStyle
////            controller.enableLockScreenControls

//            UIWindow *window = (UIWindow*)[[UIApplication sharedApplication] keyWindow];
//            [window.rootViewController presentViewController:controller animated:NO completion:nil];

//            [controller.playerView.player configurePlayerWith:config];
//            [controller.player configurePlayerWith:config];
        } else {
             [self continuePlaying];
        }
    } else {
        [self continuePlaying];
    }
}

-(void)continuePlaying
{
//    if (_playerView != nil && [_playerView c].file != nil) {
//        if ([_playerView config].autostart) {
//            [_playerView play];
//        }
//    }
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
//        NSString *file = @"";
//        NSString *mediaId = @"";
//        NSString *title = @"";
//        NSString *desc = @"";
//
////        if (item.file != nil) {
////            file = item.file;
////        }
//
//        if (item.mediaId != nil) {
//            mediaId = item.mediaId;
//        }
//
//        if (item.title != nil) {
//            title = item.title;
//        }
//
//        if (item.description != nil) {
//            desc = item.description;
//        }
//
//        NSMutableDictionary *itemDict = [[NSMutableDictionary alloc] init];
//        [itemDict setObject:file forKey:@"file"];
//        [itemDict setObject:mediaId forKey:@"mediaId"];
//        [itemDict setObject:title forKey:@"title"];
//        [itemDict setObject:desc forKey:@"desc"];
//        [itemDict setObject:[NSNumber numberWithInteger:index] forKey:@"index"];
        
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:item options:NSJSONWritingPrettyPrinted error: &error];
        
        self.onPlaylistItem(@{@"playlistItem": [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], @"index": [NSNumber numberWithInteger:index]});
    }
}

- (void)jwplayer:(id<JWPlayer>)player didLoadPlaylist:(NSArray<JWPlayerItem *> *)playlist
{
    if (self.onPlaylist) {
//        NSMutableArray<NSData*>* playlistArray = [[NSMutableArray alloc] init];
//
//        for (JWPlayerItem* item in playlist) {
//            NSError *error;
//            NSString *file = @"";
//            NSString *mediaId = @"";
//            NSString *title = @"";
//            NSString *desc = @"";
//
//    //        if (item.file != nil) {
//    //            file = item.file;
//    //        }
//
//            if (item.mediaId != nil) {
//                mediaId = item.mediaId;
//            }
//
//            if (item.title != nil) {
//                title = item.title;
//            }
//
//            if (item.description != nil) {
//                desc = item.description;
//            }
//
//            NSMutableDictionary *itemDict = [[NSMutableDictionary alloc] init];
//            [itemDict setObject:file forKey:@"file"];
//            [itemDict setObject:mediaId forKey:@"mediaId"];
//            [itemDict setObject:title forKey:@"title"];
//            [itemDict setObject:desc forKey:@"desc"];
//
//            NSData* data = [NSJSONSerialization dataWithJSONObject:itemDict options:NSJSONWritingPrettyPrinted error: &error];
//            [playlistArray addObject:data];
//        }
        
        NSError *error;
        NSData* data = [NSJSONSerialization dataWithJSONObject:playlist options:NSJSONWritingPrettyPrinted error: &error];
        
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

#pragma mark - JWPlayer Ad Delegate

- (void)jwplayer:(id _Nonnull)player adEvent:(JWAdEvent * _Nonnull)event {
    if (self.onAdEvent) {
        self.onAdEvent(@{@"client": @(event.client), @"type": @(event.type)});
    }
}

#pragma mark - JWPlayer Cast Delegate

- (void)castController:(JWCastController * _Nonnull)controller castingBeganWithDevice:(JWCastingDevice * _Nonnull)device {
    
}

- (void)castController:(JWCastController * _Nonnull)controller castingEndedWithError:(NSError * _Nullable)error {
    
}

- (void)castController:(JWCastController * _Nonnull)controller castingFailedWithError:(NSError * _Nonnull)error {
    
}

- (void)castController:(JWCastController * _Nonnull)controller connectedTo:(JWCastingDevice * _Nonnull)device {
    
}

- (void)castController:(JWCastController * _Nonnull)controller connectionFailedWithError:(NSError * _Nonnull)error {
    
}

- (void)castController:(JWCastController * _Nonnull)controller connectionRecoveredWithDevice:(JWCastingDevice * _Nonnull)device {
    
}

- (void)castController:(JWCastController * _Nonnull)controller connectionSuspendedWithDevice:(JWCastingDevice * _Nonnull)device {
    
}

- (void)castController:(JWCastController * _Nonnull)controller devicesAvailable:(NSArray<JWCastingDevice *> * _Nonnull)devices {
    
}

- (void)castController:(JWCastController * _Nonnull)controller disconnectedWithError:(NSError * _Nullable)error {
    
}

#pragma mark - JWPlayer AV Delegate

- (void)jwplayer:(id<JWPlayer> _Nonnull)player audioTrackChanged:(NSInteger)currentLevel {
    
}

- (void)jwplayer:(id<JWPlayer> _Nonnull)player audioTracksUpdated:(NSArray<JWMediaSelectionOption *> * _Nonnull)levels {
    
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

#pragma mark - JWPlayer Interruption handling

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
    [self.playerView.player pause];
}

-(void)audioInterruptionsEnded:(NSNotification *)note {
    if (!_userPaused) {
        [self.playerView.player play];
    }
}

@end
