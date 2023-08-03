//
//  RNJWPlayerViewController.m
//  RNJWPlayer
//
//  Created by Chaim Paneth on 3/30/22.
//

#import "RNJWPlayerViewController.h"

@implementation RNJWPlayerViewController

-(void)setDelegates
{
    self.delegate = self;
    self.playerView.delegate = self;
    self.player.delegate = self;
    self.player.playbackStateDelegate = self;
    self.player.adDelegate = self;
    self.player.avDelegate = self;
    self.player.contentKeyDataSource = self;
}

-(void)removeDelegates
{
    self.delegate = nil;
    self.playerView.delegate = nil;
    self.player.delegate = nil;
    self.player.playbackStateDelegate = nil;
    self.player.adDelegate = nil;
    self.player.avDelegate = nil;
    self.player.contentKeyDataSource = nil;
}

#pragma mark - JWPlayer Delegate

- (void)jwplayerIsReady:(id<JWPlayer>)player
{
    [super jwplayerIsReady:player];
    
    _parentView.settingConfig = NO;
    
    if (_parentView.onPlayerReady) {
        _parentView.onPlayerReady(@{});
    }
    
    if (_parentView.pendingConfig && _parentView.currentConfig) {
        [_parentView setConfig:_parentView.currentConfig];
    }
}

- (void)jwplayer:(id<JWPlayer>)player failedWithError:(NSUInteger)code message:(NSString *)message
{
    [super jwplayer:player failedWithError:code message:message];
    
    if (_parentView.onPlayerError) {
        _parentView.onPlayerError(@{@"error": message});
    }
}

- (void)jwplayer:(id<JWPlayer>)player failedWithSetupError:(NSUInteger)code message:(NSString *)message
{
    [super jwplayer:player failedWithSetupError:code message:message];
    
    if (_parentView.onSetupPlayerError) {
        _parentView.onSetupPlayerError(@{@"error": message});
    }
}

- (void)jwplayer:(id<JWPlayer>)player encounteredWarning:(NSUInteger)code message:(NSString *)message
{
    [super jwplayer:player encounteredWarning:code message:message];
    
    if (_parentView.onPlayerWarning) {
        _parentView.onPlayerWarning(@{@"warning": message});
    }
}

- (void)jwplayer:(id<JWPlayer> _Nonnull)player encounteredAdError:(NSUInteger)code message:(NSString * _Nonnull)message {
    [super jwplayer:player encounteredAdError:code message:message];
    
    if (_parentView.onPlayerAdError) {
        _parentView.onPlayerAdError(@{@"error": message});
    }
}


- (void)jwplayer:(id<JWPlayer> _Nonnull)player encounteredAdWarning:(NSUInteger)code message:(NSString * _Nonnull)message {
    [super jwplayer:player encounteredAdWarning:code message:message];
    
    if (_parentView.onPlayerAdWarning) {
        _parentView.onPlayerAdWarning(@{@"warning": message});
    }
}


#pragma mark - JWPlayer View Delegate

- (void)playerView:(JWPlayerView *)view sizeChangedFrom:(CGSize)oldSize to:(CGSize)newSize
{
    [super playerView:view sizeChangedFrom:oldSize to:newSize];
    
    if (_parentView.onPlayerSizeChange) {
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
        _parentView.onPlayerSizeChange(@{@"sizes": data});
    }
}

#pragma mark - JWPlayer View Controller Delegate

- (void)playerViewController:(JWPlayerViewController *)controller sizeChangedFrom:(CGSize)oldSize to:(CGSize)newSize
{
    if (_parentView.onPlayerSizeChange) {
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
        _parentView.onPlayerSizeChange(@{@"sizes": data});
    }
}

- (void)playerViewController:(JWPlayerViewController *)controller screenTappedAt:(CGPoint)position
{
    if (_parentView.onScreenTapped) {
        _parentView.onScreenTapped(@{@"x": @(position.x), @"y": @(position.y)});
    }
}

- (void)playerViewController:(JWPlayerViewController *)controller controlBarVisibilityChanged:(BOOL)isVisible frame:(CGRect)frame
{
    if (_parentView.onControlBarVisible) {
        _parentView.onControlBarVisible(@{@"visible": @(isVisible)});
    }
}

- (JWFullScreenViewController * _Nullable)playerViewControllerWillGoFullScreen:(JWPlayerViewController * _Nonnull)controller {
    if (_parentView.onFullScreenRequested) {
        _parentView.onFullScreenRequested(@{});
    }
    return nil;
}

- (void)playerViewControllerDidGoFullScreen:(JWPlayerViewController *)controller
{
    if (_parentView.onFullScreen) {
        _parentView.onFullScreen(@{});
    }
}

- (void)playerViewControllerWillDismissFullScreen:(JWPlayerViewController *)controller
{
    if (_parentView.onFullScreenExitRequested) {
        _parentView.onFullScreenExitRequested(@{});
    }
}

- (void)playerViewControllerDidDismissFullScreen:(JWPlayerViewController *)controller
{
    if (_parentView.onFullScreenExit) {
        _parentView.onFullScreenExit(@{});
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

#pragma mark Time events

-(void)onAdTimeEvent:(JWTimeData * _Nonnull)time {
    [super onAdTimeEvent:time];
    if (_parentView.onAdTime) {
        _parentView.onAdTime(@{@"position": @(time.position), @"duration": @(time.duration)});
    }
}

- (void)onMediaTimeEvent:(JWTimeData * _Nonnull)time {
    [super onMediaTimeEvent:time];
    if (_parentView.onTime) {
        _parentView.onTime(@{@"position": @(time.position), @"duration": @(time.duration)});
    }
}

#pragma mark - DRM Delegate

- (void)contentIdentifierForURL:(NSURL * _Nonnull)url completionHandler:(void (^ _Nonnull)(NSData * _Nullable))handler {
    if (!_parentView.contentUUID) {
        _parentView.contentUUID = [[url.absoluteString componentsSeparatedByString:@";"] lastObject];
    }
    
    NSData *uuidData = [_parentView.contentUUID dataUsingEncoding:NSUTF8StringEncoding];
    handler(uuidData);
}

- (void)appIdentifierForURL:(NSURL * _Nonnull)url completionHandler:(void (^ _Nonnull)(NSData * _Nullable))handler {
    NSURL *certURL = [NSURL URLWithString:_parentView.fairplayCertUrl];
    NSData *certData = [NSData dataWithContentsOfURL:certURL];
    handler(certData);
}

- (void)contentKeyWithSPCData:(NSData * _Nonnull)spcData completionHandler:(void (^ _Nonnull)(NSData * _Nullable, NSDate * _Nullable, NSString * _Nullable))handler {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSString *spcProcessURL = [NSString stringWithFormat:@"%@/%@?p1=%li", _parentView.processSpcUrl, _parentView.contentUUID, (NSInteger)currentTime];
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
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        [_parentView.playerViewController.player play];
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
    [super jwplayerContentIsBuffering:player];
    
    if (_parentView.onBuffer) {
        _parentView.onBuffer(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player isBufferingWithReason:(enum JWBufferReason)reason
{
    [super jwplayer:player isBufferingWithReason:reason];
    
    if (_parentView.onBuffer) {
        _parentView.onBuffer(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player updatedBuffer:(double)percent position:(JWTimeData *)time
{
    [super jwplayer:player updatedBuffer:percent position:time];
    
    if (_parentView.onUpdateBuffer) {
        _parentView.onUpdateBuffer(@{@"percent": @(percent), @"position": time});
    }
}

- (void)jwplayer:(id<JWPlayer>)player didFinishLoadingWithTime:(NSTimeInterval)loadTime
{
    [super jwplayer:player didFinishLoadingWithTime:loadTime];
    
    if (_parentView.onLoaded) {
        _parentView.onLoaded(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player isAttemptingToPlay:(JWPlayerItem *)playlistItem reason:(enum JWPlayReason)reason
{
    [super jwplayer:player isAttemptingToPlay:playlistItem reason:reason];
    
    if (_parentView.onAttemptPlay) {
        _parentView.onAttemptPlay(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player isPlayingWithReason:(enum JWPlayReason)reason
{
    [super jwplayer:player isPlayingWithReason:reason];
    
    if (_parentView.onPlay) {
        _parentView.onPlay(@{});
    }
    
    _parentView.userPaused = NO;
    _parentView.wasInterrupted = NO;
}

- (void)jwplayer:(id<JWPlayer>)player willPlayWithReason:(enum JWPlayReason)reason
{
    [super jwplayer:player willPlayWithReason:reason];
    
    if (_parentView.onBeforePlay) {
        _parentView.onBeforePlay(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player didPauseWithReason:(enum JWPauseReason)reason
{
    [super jwplayer:player didPauseWithReason:reason];
    
    if (_parentView.onPause) {
        _parentView.onPause(@{});
    }
    
    if (!_parentView.wasInterrupted) {
        _parentView.userPaused = YES;
    }
}

- (void)jwplayer:(id<JWPlayer>)player didBecomeIdleWithReason:(enum JWIdleReason)reason
{
    [super jwplayer:player didBecomeIdleWithReason:reason];
    
    if (_parentView.onIdle) {
        _parentView.onIdle(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player isVisible:(BOOL)isVisible
{
    [super jwplayer:player isVisible:isVisible];
    
    if (_parentView.onVisible) {
        _parentView.onVisible(@{@"visible": @(isVisible)});
    }
}

- (void)jwplayerContentWillComplete:(id<JWPlayer>)player
{
    [super jwplayerContentWillComplete:player];
    
    if (_parentView.onBeforeComplete) {
        _parentView.onBeforeComplete(@{});
    }
}

- (void)jwplayerContentDidComplete:(id<JWPlayer>)player
{
    [super jwplayerContentDidComplete:player];
    
    if (_parentView.onComplete) {
        _parentView.onComplete(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player didLoadPlaylistItem:(JWPlayerItem *)item at:(NSUInteger)index
{
    [super jwplayer:player didLoadPlaylistItem:item at:index];
    
    if (_parentView.onPlaylistItem) {
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

        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:itemDict options:NSJSONWritingPrettyPrinted error: &error];
        
        _parentView.onPlaylistItem(@{@"playlistItem": [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], @"index": [NSNumber numberWithInteger:index]});
    }
    
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)jwplayer:(id<JWPlayer>)player didLoadPlaylist:(NSArray<JWPlayerItem *> *)playlist
{
    [super jwplayer:player didLoadPlaylist:playlist];
    
    if (_parentView.onPlaylist) {
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
        
        _parentView.onPlaylist(@{@"playlist": [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]});
    }
}

- (void)jwplayerPlaylistHasCompleted:(id<JWPlayer>)player
{
    [super jwplayerPlaylistHasCompleted:player];
    
    if (_parentView.onPlaylistComplete) {
        _parentView.onPlaylistComplete(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player usesMediaType:(enum JWMediaType)type
{
    [super jwplayer:player usesMediaType:type];
}

- (void)jwplayer:(id<JWPlayer>)player seekedFrom:(NSTimeInterval)oldPosition to:(NSTimeInterval)newPosition
{
    [super jwplayer:player seekedFrom:oldPosition to:newPosition];
    
    if (_parentView.onSeek) {
        _parentView.onSeek(@{@"from": @(oldPosition), @"to": @(newPosition)});
    }
}

- (void)jwplayerHasSeeked:(id<JWPlayer>)player
{
    [super jwplayerHasSeeked:player];
    
    if (_parentView.onSeeked) {
        _parentView.onSeeked(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player playbackRateChangedTo:(double)rate at:(NSTimeInterval)time
{
    [super jwplayer:player playbackRateChangedTo:rate at:time];
}

- (void)jwplayer:(id<JWPlayer>)player updatedCues:(NSArray<JWCue *> * _Nonnull)cues
{
    [super jwplayer:player updatedCues:cues];
}

#pragma mark - JWPlayer Ad Delegate

- (void)jwplayer:(id _Nonnull)player adEvent:(JWAdEvent * _Nonnull)event {
    [super jwplayer:player adEvent:event];
    
    if (_parentView.onAdEvent) {
        _parentView.onAdEvent(@{@"client": @(event.client), @"type": @(event.type)});
    }
}

#pragma mark - JWPlayer Cast Delegate

- (void)castController:(JWCastController * _Nonnull)controller castingBeganWithDevice:(JWCastingDevice * _Nonnull)device {
    [super castController:controller castingBeganWithDevice:device];
    
    if (_parentView.onCasting) {
        _parentView.onCasting(@{});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller castingEndedWithError:(NSError * _Nullable)error {
    [super castController:controller castingEndedWithError:error];
    
    if (_parentView.onCastingEnded) {
        _parentView.onCastingEnded(@{@"error": error});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller castingFailedWithError:(NSError * _Nonnull)error {
    [super castController:controller castingFailedWithError:error];
    
    if (_parentView.onCastingFailed) {
        _parentView.onCastingFailed(@{@"error": error});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller connectedTo:(JWCastingDevice * _Nonnull)device {
    [super castController:controller connectedTo:device];
    
    if (_parentView.onConnectedToCastingDevice) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
        [dict setObject:device.name forKey:@"name"];
        [dict setObject:device.identifier forKey:@"identifier"];

        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error: &error];
        
        _parentView.onConnectedToCastingDevice(@{@"device": [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller connectionFailedWithError:(NSError * _Nonnull)error {
    [super castController:controller connectionFailedWithError:error];
    
    if (_parentView.onConnectionFailed) {
        _parentView.onConnectionFailed(@{@"error": error});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller connectionRecoveredWithDevice:(JWCastingDevice * _Nonnull)device {
    [super castController:controller connectionRecoveredWithDevice:device];
    
    if (_parentView.onConnectionRecovered) {
        _parentView.onConnectionRecovered(@{});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller connectionSuspendedWithDevice:(JWCastingDevice * _Nonnull)device {
    [super castController:controller connectionSuspendedWithDevice:device];
    
    if (_parentView.onConnectionTemporarilySuspended) {
        _parentView.onConnectionTemporarilySuspended(@{});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller devicesAvailable:(NSArray<JWCastingDevice *> * _Nonnull)devices {
    [super castController:controller devicesAvailable:devices];
    
    _parentView.availableDevices = devices;
    
    if (_parentView.onCastingDevicesAvailable) {
        NSMutableArray *devicesInfo = [[NSMutableArray alloc] init];

        for (JWCastingDevice *device in devices) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                
            [dict setObject:device.name forKey:@"name"];
            [dict setObject:device.identifier forKey:@"identifier"];

            [devicesInfo addObject:dict];
        }

        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:devicesInfo options:NSJSONWritingPrettyPrinted error: &error];
        
        _parentView.onCastingDevicesAvailable(@{@"devices": [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller disconnectedWithError:(NSError * _Nullable)error {
    [super castController:controller disconnectedWithError:error];
    
    if (_parentView.onDisconnectedFromCastingDevice) {
        _parentView.onDisconnectedFromCastingDevice(@{@"error": error});
    }
}

#pragma mark - JWPlayer AV Delegate

- (void)jwplayer:(id<JWPlayer> _Nonnull)player audioTracksUpdated:(NSArray<JWMediaSelectionOption *> * _Nonnull)levels {
    [super jwplayer:player audioTracksUpdated:levels];
    
    if (_parentView.onAudioTracks) {
        _parentView.onAudioTracks(@{});
    }
}

- (void)jwplayer:(id<JWPlayer> _Nonnull)player audioTrackChanged:(NSInteger)currentLevel {
    [super jwplayer:player audioTrackChanged:currentLevel];
}

- (void)jwplayer:(id<JWPlayer> _Nonnull)player captionPresented:(NSArray<NSString *> * _Nonnull)caption at:(JWTimeData * _Nonnull)time {
    [super jwplayer:player captionPresented:caption at:time];
}

- (void)jwplayer:(id<JWPlayer> _Nonnull)player captionTrackChanged:(NSInteger)index {
    [super jwplayer:player captionTrackChanged:index];
}

- (void)jwplayer:(id<JWPlayer> _Nonnull)player qualityLevelChanged:(NSInteger)currentLevel {
    [super jwplayer:player qualityLevelChanged:currentLevel];
}

- (void)jwplayer:(id<JWPlayer> _Nonnull)player qualityLevelsUpdated:(NSArray<JWVideoSource *> * _Nonnull)levels {
    [super jwplayer:player qualityLevelsUpdated:levels];
}

- (void)jwplayer:(id<JWPlayer> _Nonnull)player updatedCaptionList:(NSArray<JWMediaSelectionOption *> * _Nonnull)options {
    [super jwplayer:player updatedCaptionList:options];
}

@end
