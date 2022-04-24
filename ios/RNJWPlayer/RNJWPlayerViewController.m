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

#pragma mark - JWPlayer Delegate

- (void)jwplayerIsReady:(id<JWPlayer>)player
{
    if (_parentView.onPlayerReady) {
        _parentView.onPlayerReady(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player failedWithError:(NSUInteger)code message:(NSString *)message
{
    if (_parentView.onPlayerError) {
        _parentView.onPlayerError(@{@"error": message});
    }
}

- (void)jwplayer:(id<JWPlayer>)player failedWithSetupError:(NSUInteger)code message:(NSString *)message
{
    if (_parentView.onSetupPlayerError) {
        _parentView.onSetupPlayerError(@{@"error": message});
    }
}

- (void)jwplayer:(id<JWPlayer>)player encounteredWarning:(NSUInteger)code message:(NSString *)message
{
    if (_parentView.onPlayerWarning) {
        _parentView.onPlayerWarning(@{@"warning": message});
    }
}

- (void)jwplayer:(id<JWPlayer> _Nonnull)player encounteredAdError:(NSUInteger)code message:(NSString * _Nonnull)message {
    if (_parentView.onPlayerAdError) {
        _parentView.onPlayerAdError(@{@"error": message});
    }
}


- (void)jwplayer:(id<JWPlayer> _Nonnull)player encounteredAdWarning:(NSUInteger)code message:(NSString * _Nonnull)message {
    if (_parentView.onPlayerAdWarning) {
        _parentView.onPlayerAdWarning(@{@"warning": message});
    }
}


#pragma mark - JWPlayer View Delegate

- (void)playerView:(JWPlayerView *)view sizeChangedFrom:(CGSize)oldSize to:(CGSize)newSize
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

#pragma mark - DRM Delegate

- (void)contentIdentifierForURL:(NSURL * _Nonnull)url completionHandler:(void (^ _Nonnull)(NSData * _Nullable))handler {
    NSData *uuidData = [_parentView.contentUUID dataUsingEncoding:NSUTF8StringEncoding];
    handler(uuidData);
}

- (void)appIdentifierForURL:(NSURL * _Nonnull)url completionHandler:(void (^ _Nonnull)(NSData * _Nullable))handler {
    NSURL *certURL = [NSURL URLWithString:_parentView.fairplayCertUrl];
    NSData *certData = [NSData dataWithContentsOfURL:certURL];
    handler(certData);
}

- (void)contentKeyWithSPCData:(NSData * _Nonnull)spcData completionHandler:(void (^ _Nonnull)(NSData * _Nullable, NSDate * _Nullable, NSString * _Nullable))handler {
    NSMutableURLRequest *ckcRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_parentView.processSpcUrl]];
    [ckcRequest setHTTPMethod:@"POST"];
    [ckcRequest setHTTPBody:spcData];
    [ckcRequest addValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];

    [[[NSURLSession sharedSession] dataTaskWithRequest:ckcRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (error != nil || (httpResponse != nil && httpResponse.statusCode != 200)) {
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
    if (_parentView.onBuffer) {
        _parentView.onBuffer(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player isBufferingWithReason:(enum JWBufferReason)reason
{
    if (_parentView.onBuffer) {
        _parentView.onBuffer(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player updatedBuffer:(double)percent position:(JWTimeData *)time
{
    if (_parentView.onUpdateBuffer) {
        _parentView.onUpdateBuffer(@{@"percent": @(percent), @"position": time});
    }
}

- (void)jwplayer:(id<JWPlayer>)player didFinishLoadingWithTime:(NSTimeInterval)loadTime
{
    if (_parentView.onLoaded) {
        _parentView.onLoaded(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player isAttemptingToPlay:(JWPlayerItem *)playlistItem reason:(enum JWPlayReason)reason
{
    if (_parentView.onAttemptPlay) {
        _parentView.onAttemptPlay(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player isPlayingWithReason:(enum JWPlayReason)reason
{
    if (_parentView.onPlay) {
        _parentView.onPlay(@{});
    }
    
    _parentView.userPaused = NO;
    _parentView.wasInterrupted = NO;
}

- (void)jwplayer:(id<JWPlayer>)player willPlayWithReason:(enum JWPlayReason)reason
{
    if (_parentView.onBeforePlay) {
        _parentView.onBeforePlay(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player didPauseWithReason:(enum JWPauseReason)reason
{
    if (_parentView.onPause) {
        _parentView.onPause(@{});
    }
    
    if (!_parentView.wasInterrupted) {
        _parentView.userPaused = YES;
    }
}

- (void)jwplayer:(id<JWPlayer>)player didBecomeIdleWithReason:(enum JWIdleReason)reason
{
    if (_parentView.onIdle) {
        _parentView.onIdle(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player isVisible:(BOOL)isVisible
{
    if (_parentView.onVisible) {
        _parentView.onVisible(@{@"visible": @(isVisible)});
    }
}

- (void)jwplayerContentWillComplete:(id<JWPlayer>)player
{
    if (_parentView.onBeforeComplete) {
        _parentView.onBeforeComplete(@{});
    }
}

- (void)jwplayerContentDidComplete:(id<JWPlayer>)player
{
    if (_parentView.onComplete) {
        _parentView.onComplete(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player didLoadPlaylistItem:(JWPlayerItem *)item at:(NSUInteger)index
{
    if (_parentView.onPlaylistItem) {
        NSMutableDictionary* sourceDict = [[NSMutableDictionary alloc] init];
        for (JWVideoSource* source in item.videoSources) {
            [sourceDict setObject:source.file forKey:@"file"];
            [sourceDict setObject:source.label forKey:@"label"];
            [sourceDict setObject:@(source.defaultVideo) forKey:@"default"];
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
    if (_parentView.onPlaylist) {
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
    if (_parentView.onPlaylistComplete) {
        _parentView.onPlaylistComplete(@{});
    }
}

- (void)jwplayer:(id<JWPlayer>)player usesMediaType:(enum JWMediaType)type
{

}

- (void)jwplayer:(id<JWPlayer>)player seekedFrom:(NSTimeInterval)oldPosition to:(NSTimeInterval)newPosition
{
    if (_parentView.onSeek) {
        _parentView.onSeek(@{@"from": @(oldPosition), @"to": @(newPosition)});
    }
}

- (void)jwplayerHasSeeked:(id<JWPlayer>)player
{
    if (_parentView.onSeeked) {
        _parentView.onSeeked(@{});
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
    if (_parentView.onAdEvent) {
        _parentView.onAdEvent(@{@"client": @(event.client), @"type": @(event.type)});
    }
}

#pragma mark - JWPlayer Cast Delegate

- (void)castController:(JWCastController * _Nonnull)controller castingBeganWithDevice:(JWCastingDevice * _Nonnull)device {
    if (_parentView.onCasting) {
        _parentView.onCasting(@{});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller castingEndedWithError:(NSError * _Nullable)error {
    if (_parentView.onCastingEnded) {
        _parentView.onCastingEnded(@{@"error": error});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller castingFailedWithError:(NSError * _Nonnull)error {
    if (_parentView.onCastingFailed) {
        _parentView.onCastingFailed(@{@"error": error});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller connectedTo:(JWCastingDevice * _Nonnull)device {
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
    if (_parentView.onConnectionFailed) {
        _parentView.onConnectionFailed(@{@"error": error});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller connectionRecoveredWithDevice:(JWCastingDevice * _Nonnull)device {
    if (_parentView.onConnectionRecovered) {
        _parentView.onConnectionRecovered(@{});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller connectionSuspendedWithDevice:(JWCastingDevice * _Nonnull)device {
    if (_parentView.onConnectionTemporarilySuspended) {
        _parentView.onConnectionTemporarilySuspended(@{});
    }
}

- (void)castController:(JWCastController * _Nonnull)controller devicesAvailable:(NSArray<JWCastingDevice *> * _Nonnull)devices {
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
    if (_parentView.onDisconnectedFromCastingDevice) {
        _parentView.onDisconnectedFromCastingDevice(@{@"error": error});
    }
}

#pragma mark - JWPlayer AV Delegate

- (void)jwplayer:(id<JWPlayer> _Nonnull)player audioTracksUpdated:(NSArray<JWMediaSelectionOption *> * _Nonnull)levels {
    if (_parentView.onAudioTracks) {
        _parentView.onAudioTracks(@{});
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

@end
