#import <JWPlayer_iOS_SDK/JWPlayerController.h>

#import "RNJWPlayerManager.h"
#import "RNJWPlayerNativeView.h"

#import "RCTUIManager.h"

@interface RNJWPlayerManager ()

@property(nonatomic, strong)RNJWPlayerNativeView *playerView;

@end

@implementation RNJWPlayerManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    if (!_playerView) {
        _playerView = [[RNJWPlayerNativeView alloc] init];
    }
    
    return _playerView;
}

RCT_EXPORT_VIEW_PROPERTY(onBeforePlay, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlay, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPause, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBuffer, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onIdle, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlaylistItem, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onSetupPlayerError, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerError, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onTime, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFullScreen, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFullScreenRequested, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFullScreenExit, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFullScreenExitRequested, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onSeek, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlaylist, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onReady, RCTBubblingEventBlock);

//RCT_EXPORT_VIEW_PROPERTY(file, NSString);
//RCT_EXPORT_VIEW_PROPERTY(mediaId, NSString);
//RCT_EXPORT_VIEW_PROPERTY(title, NSString);
//RCT_EXPORT_VIEW_PROPERTY(image, NSString);
//RCT_EXPORT_VIEW_PROPERTY(desc, NSString);
RCT_EXPORT_VIEW_PROPERTY(autostart, BOOL);
//RCT_EXPORT_VIEW_PROPERTY(controls, BOOL);
//RCT_EXPORT_VIEW_PROPERTY(repeat, BOOL);
//RCT_EXPORT_VIEW_PROPERTY(displayTitle, BOOL);
//RCT_EXPORT_VIEW_PROPERTY(displayDesc, BOOL);
//RCT_EXPORT_VIEW_PROPERTY(nextUpDisplay, BOOL);
RCT_EXPORT_VIEW_PROPERTY(playlistItem, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(playlist, NSArray);
//RCT_EXPORT_VIEW_PROPERTY(playlistId, NSString);
//RCT_EXPORT_VIEW_PROPERTY(time, NSNumber);

RCT_REMAP_METHOD(state,
                 stateWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
//    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
//        RNJWPlayerNativeView *view = viewRegistry[reactTag];
//        if (![view isKindOfClass:[RNJWPlayerNativeView class]]) {
//            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
//
//            NSError *error = [[NSError alloc] init];
//            reject(@"no_player", @"There is no player", error);
//        } else {
//            if (view.player) {
//                resolve([NSNumber numberWithInt:[view.player state]]);
//            } else {
//                NSError *error = [[NSError alloc] init];
//                reject(@"no_player", @"There is no player", error);
//            };
//        }
//    }];
    
    if (_playerView != nil && _playerView.player != nil) {
        resolve([NSNumber numberWithInt:[_playerView.player state]]);
    } else {
        NSError *error = [[NSError alloc] init];
        reject(@"no_player", @"There is no player", error);
    };
}

RCT_EXPORT_METHOD(pause) {
//    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
//        RNJWPlayerNativeView *view = viewRegistry[reactTag];
//        if (![view isKindOfClass:[RNJWPlayerNativeView class]]) {
//            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
//        } else {
//            [view.player pause];
//        }
//    }];
    
    if (_playerView != nil && _playerView.player != nil) {
        [_playerView.player pause];
    } else {
        RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", _playerView);
    };
}

RCT_EXPORT_METHOD(play) {
//    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
//        RNJWPlayerNativeView *view = viewRegistry[reactTag];
//        if (![view isKindOfClass:[RNJWPlayerNativeView class]]) {
//            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
//        } else {
//            view.player.config.controls = [view.player controls];
//            [view.player play];
//        }
//    }];
    
    if (_playerView != nil && _playerView.player != nil) {
        _playerView.player.config.controls = [_playerView.player controls];
        [_playerView.player play];
    } else {
        RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", _playerView);
    };
}

RCT_EXPORT_METHOD(stop) {
//    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
//        RNJWPlayerNativeView *view = viewRegistry[reactTag];
//        if (![view isKindOfClass:[RNJWPlayerNativeView class]]) {
//            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
//        } else {
//            [view.player stop];
//        }
//    }];
    
    if (_playerView != nil && _playerView.player != nil) {
        [_playerView.player stop];
    } else {
        RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", _playerView);
    };
}

RCT_REMAP_METHOD(position,
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
//    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
//        RNJWPlayerNativeView *view = viewRegistry[reactTag];
//        if (![view isKindOfClass:[RNJWPlayerNativeView class]]) {
//            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
//
//            NSError *error = [[NSError alloc] init];
//            reject(@"no_player", @"There is no player", error);
//        } else {
//            if (view.player) {
//                resolve([NSNumber numberWithInt:[view.player position]]);
//            } else {
//                NSError *error = [[NSError alloc] init];
//                reject(@"no_player", @"There is no player", error);
//            };
//        }
//    }];
    
    if (_playerView != nil && _playerView.player != nil) {
        resolve([NSNumber numberWithInt:[_playerView.player position]]);
    } else {
        NSError *error = [[NSError alloc] init];
        reject(@"no_player", @"There is no player", error);
    };
}

RCT_EXPORT_METHOD(toggleSpeed) {
//    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
//        RNJWPlayerNativeView *view = viewRegistry[reactTag];
//        if (![view isKindOfClass:[RNJWPlayerNativeView class]]) {
//            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
//        } else {
//            if ([view.player playbackRate] < 2.0) {
//                view.player.playbackRate = [view.player playbackRate] + 0.5;
//            } else {
//                view.player.playbackRate = 0.5;
//            }
//        }
//    }];
    
    if (_playerView != nil && _playerView.player != nil) {
        if ([_playerView.player playbackRate] < 2.0) {
            _playerView.player.playbackRate = [_playerView.player playbackRate] + 0.5;
        } else {
            _playerView.player.playbackRate = 0.5;
        }
    } else {
        RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", _playerView);
    };
}

RCT_EXPORT_METHOD(setPlaylistIndex: (nonnull NSNumber *)index) {
    if (_playerView != nil && _playerView.player != nil) {
        _playerView.player.playlistIndex = [index integerValue];
    } else {
        RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", _playerView);
    };
}

RCT_EXPORT_METHOD(setControls: (BOOL)show) {
    if (_playerView != nil && _playerView.player != nil) {
        _playerView.player.controls = show;
        _playerView.player.config.controls = show;
    } else {
        RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", _playerView);
    };
}

RCT_EXPORT_METHOD(loadPlaylistItem: (nonnull NSDictionary *)playlistItem) {
    if (_playerView != nil && playlistItem) {
        NSString *newFile = [playlistItem objectForKey:@"file"];
        NSString* encodedUrl = [newFile stringByAddingPercentEscapesUsingEncoding:
                                NSUTF8StringEncoding];
        
        if (newFile != nil && newFile.length > 0) {
//            if (![encodedUrl isEqualToString: _playerView.player.config.file]) {
                [_playerView reset];
                
                JWConfig *config = [_playerView setupConfig];
                
                config.file = encodedUrl;
                config.mediaId = [playlistItem objectForKey:@"mediaId"];
                config.title = [playlistItem objectForKey:@"title"];
                config.desc = [playlistItem objectForKey:@"desc"];
                config.image = [playlistItem objectForKey:@"image"];
                
                config.autostart = [[playlistItem objectForKey:@"autostart"] boolValue];
                config.controls = [[playlistItem objectForKey:@"controls"] boolValue];
                //            config.repeat = [[playlistItem objectForKey:@"repeat"] boolValue];
                //            config.displayDescription = [[playlistItem objectForKey:@"displayDesc"] boolValue];
                //            config.displayTitle = [[playlistItem objectForKey:@"displayTitle"] boolValue];
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    _playerView.proxy = [RNJWPlayerDelegateProxy new];
                    _playerView.proxy.delegate = _playerView;
                    
                    _playerView.player = [[JWPlayerController alloc] initWithConfig:config delegate:_playerView.proxy];
                    
                    [_playerView addSubview:_playerView.player.view];
                    
                    _playerView.player.controls = [[playlistItem objectForKey:@"controls"] boolValue];
                    
                    _playerView.player.forceFullScreenOnLandscape = YES;
                    _playerView.player.forceLandscapeOnFullScreen = YES;
                });
//            } else {
//                [_playerView.player play];
//            }
        } else {
            RCTLogError(@"No file prop, expecting url or file path, got: %@", newFile);
        }
    } else {
        RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", _playerView);
    };
}

RCT_EXPORT_METHOD(loadPlaylist: (nonnull NSArray *)playlist) {
    if (_playerView != nil) {
        if (playlist != nil && playlist.count > 0) {
            [_playerView reset];
            
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
            
            JWConfig *config = [_playerView setupConfig];
            
            config.autostart = [[playlist[0] objectForKey:@"autostart"] boolValue];
            config.controls = YES;
//            config.repeat = NO;
//            config.displayDescription = YES;
//            config.displayTitle = YES;
            
            config.playlist = playlistArray;
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                _playerView.proxy = [RNJWPlayerDelegateProxy new];
                _playerView.proxy.delegate = _playerView;
                
                _playerView.player = [[JWPlayerController alloc] initWithConfig:config delegate:_playerView.proxy];
                
                [_playerView addSubview:_playerView.player.view];
                
                _playerView.player.controls = YES;
                
                _playerView.player.forceFullScreenOnLandscape = YES;
                _playerView.player.forceLandscapeOnFullScreen = YES;
            });
        }
    } else {
        RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", _playerView);
    };
}

RCT_EXPORT_METHOD(seekTo: (nonnull NSNumber *)time) {
    if (_playerView != nil && _playerView.player != nil) {
        [_playerView.player seek:[time integerValue] ];
    } else {
        RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", _playerView);
    };
}

@end
