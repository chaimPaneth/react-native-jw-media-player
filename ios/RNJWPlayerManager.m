#import <JWPlayer_iOS_SDK/JWPlayerController.h>

#import "RNJWPlayerManager.h"
#import "RNJWPlayerNativeView.h"

#import "RCTUIManager.h"

@interface RNJWPlayerManager ()

@end

@implementation RNJWPlayerManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    return [[RNJWPlayerNativeView alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(onAudioTracks, RCTBubblingEventBlock);
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
RCT_EXPORT_VIEW_PROPERTY(onSeeked, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlaylist, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerReady, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onControlBarVisible, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBeforeComplete, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onComplete, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onAdPlay, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onAdPause, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(onCastingDevicesAvailable, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onConnectedToCastingDevice, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onDisconnectedFromCastingDevice, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onConnectionTemporarilySuspended, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onConnectionRecovered, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onConnectionFailed, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onCasting, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onCastingEnded, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onCastingFailed, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(file, NSString);
RCT_EXPORT_VIEW_PROPERTY(mediaId, NSString);
RCT_EXPORT_VIEW_PROPERTY(title, NSString);
RCT_EXPORT_VIEW_PROPERTY(image, NSString);
RCT_EXPORT_VIEW_PROPERTY(desc, NSString);
RCT_EXPORT_VIEW_PROPERTY(adVmap, NSString);
RCT_EXPORT_VIEW_PROPERTY(stretching, NSString);
RCT_EXPORT_VIEW_PROPERTY(tracks, NSArray);
RCT_EXPORT_VIEW_PROPERTY(autostart, BOOL);
RCT_EXPORT_VIEW_PROPERTY(controls, BOOL);
RCT_EXPORT_VIEW_PROPERTY(repeat, BOOL);
RCT_EXPORT_VIEW_PROPERTY(mute, BOOL);
RCT_EXPORT_VIEW_PROPERTY(displayTitle, BOOL);
RCT_EXPORT_VIEW_PROPERTY(displayDesc, BOOL);
RCT_EXPORT_VIEW_PROPERTY(nextUpDisplay, BOOL);
RCT_EXPORT_VIEW_PROPERTY(playlistItem, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(playlist, NSArray);
RCT_EXPORT_VIEW_PROPERTY(playerStyle, NSString);
RCT_EXPORT_VIEW_PROPERTY(colors, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(fullScreenOnLandscape, BOOL);
RCT_EXPORT_VIEW_PROPERTY(nativeFullScreen, BOOL);
RCT_EXPORT_VIEW_PROPERTY(landscapeOnFullScreen, BOOL);
RCT_EXPORT_VIEW_PROPERTY(portraitOnExitFullScreen, BOOL);
RCT_EXPORT_VIEW_PROPERTY(exitFullScreenOnPortrait, BOOL);
RCT_EXPORT_VIEW_PROPERTY(nativeControls, BOOL);

RCT_REMAP_METHOD(state,
                 tag:(nonnull NSNumber *)reactTag
                 stateWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
            
            NSError *error = [[NSError alloc] init];
            reject(@"no_player", @"There is no player", error);
        } else {
            if (view.player) {
                resolve([NSNumber numberWithInt:[view.player state]]);
            } else {
                NSError *error = [[NSError alloc] init];
                reject(@"no_player", @"There is no player", error);
            };
        }
    }];
}

RCT_EXPORT_METHOD(pause:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            view.userPaused = YES;
            [view.player pause];
        }
    }];
}

RCT_EXPORT_METHOD(play:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            view.player.config.controls = [view.player controls];
            [view.player play];
        }
    }];
    
}

RCT_EXPORT_METHOD(stop:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            view.userPaused = YES;
            [view.player stop];
        }
    }];
    
}

RCT_REMAP_METHOD(position,
                 tag:(nonnull NSNumber *)reactTag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
            
            NSError *error = [[NSError alloc] init];
            reject(@"no_player", @"There is no player", error);
        } else {
            resolve([NSNumber numberWithInt:[view.player position]]);
        }
    }];
    
}

RCT_EXPORT_METHOD(toggleSpeed:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            if ([view.player playbackRate] < 2.0) {
                view.player.playbackRate = [view.player playbackRate] + 0.5;
            } else {
                view.player.playbackRate = 0.5;
            }
        }
    }];
    
}

RCT_EXPORT_METHOD(setSpeed: (nonnull NSNumber *)reactTag: (double)speed) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            view.player.playbackRate = speed;
        }
    }];
}

RCT_EXPORT_METHOD(setPlaylistIndex: (nonnull NSNumber *)reactTag: (nonnull NSNumber *)index) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            view.player.playlistIndex = [index integerValue];
        }
    }];
}

RCT_EXPORT_METHOD(setControls: (nonnull NSNumber *)reactTag: (BOOL)show) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            view.player.controls = show;
            view.player.config.controls = show;
        }
    }];
}

RCT_EXPORT_METHOD(loadPlaylistItem :(nonnull NSNumber *)reactTag: (nonnull NSDictionary *)playlistItem) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            [view setPlaylistItem:playlistItem];
        }
    }];
}

RCT_EXPORT_METHOD(loadPlaylist :(nonnull NSNumber *)reactTag: (nonnull NSArray *)playlist) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            [view setPlaylist:playlist];
        }
    }];
}

RCT_EXPORT_METHOD(seekTo :(nonnull NSNumber *)reactTag: (nonnull NSNumber *)time) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            [view.player seek:[time integerValue] ];
        }
    }];
}

RCT_EXPORT_METHOD(setFullscreen: (nonnull NSNumber *)reactTag: (BOOL)fs) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            [view.player setFullscreen:fs];
        }
    }];
}

RCT_EXPORT_METHOD(setVolume: (nonnull NSNumber *)reactTag :(nonnull NSNumber *)volume) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            [view.player setVolume:[volume floatValue]];
        }
    }];
}

RCT_REMAP_METHOD(getAudioTracks,
                 tag:(nonnull NSNumber *)reactTag
                 resolve:(RCTPromiseResolveBlock)resolve
                 eject:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);

            NSError *error = [[NSError alloc] init];
            reject(@"no_player", @"There is no player", error);
        } else {
            NSArray *audioTracks = [view.player audioTracks];
            NSMutableArray *results = [[NSMutableArray alloc] init];
            for (int i = 0; i < audioTracks.count; i++) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                id audioTrack = [audioTracks objectAtIndex:i];
                [dict setObject:audioTrack[@"language"] forKey:@"language"];
                [dict setObject:audioTrack[@"autoselect"] forKey:@"autoSelect"];
                [dict setObject:audioTrack[@"defaulttrack"] forKey:@"defaultTrack"];
                [dict setObject:audioTrack[@"name"] forKey:@"name"];
                [dict setObject:audioTrack[@"groupid"] forKey:@"groupId"];
                [results addObject:dict];
            }
            resolve(results);
        }
    }];
}

RCT_REMAP_METHOD(getCurrentAudioTrack,
                 tag:(nonnull NSNumber *)reactTag
                 resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);

            NSError *error = [[NSError alloc] init];
            reject(@"no_player", @"There is no player", error);
        } else {
            if (view.player) {
                resolve([NSNumber numberWithInt:[view.player currentAudioTrack]]);
            } else {
                NSError *error = [[NSError alloc] init];
                reject(@"no_player", @"There is no player", error);
            };
        }
    }];
}

RCT_EXPORT_METHOD(setCurrentAudioTrack: (nonnull NSNumber *)reactTag: (nonnull NSNumber *)index) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            [view.player setCurrentAudioTrack:[index integerValue]];
        }
    }];
}

RCT_EXPORT_METHOD(showAirPlayButton: (nonnull NSNumber *)reactTag: (double)x: (double)y: (double)width: (double)height: (BOOL)autoHide) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            [view showAirPlayButton:x :y :width :height :autoHide];
        }
    }];
}

RCT_EXPORT_METHOD(hideAirPlayButton: (nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            [view hideAirPlayButton];
        }
    }];
}

RCT_EXPORT_METHOD(showCastButton: (nonnull NSNumber *)reactTag: (double)x: (double)y: (double)width: (double)height: (BOOL)autoHide: (BOOL)customButton) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            [view showCastButton:x :y :width :height :autoHide :customButton];
        }
    }];
}

RCT_EXPORT_METHOD(hideCastButton: (nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            [view hideCastButton];
        }
    }];
}

RCT_EXPORT_METHOD(setUpCastController: (nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            [view setUpCastController];
        }
    }];
}

RCT_EXPORT_METHOD(presentCastDialog: (nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            [view presentCastDialog];
        }
    }];
}

RCT_REMAP_METHOD(connectedDevice,
                 tag:(nonnull NSNumber *)reactTag
                 resolve:(RCTPromiseResolveBlock)resolve
                 rejecte:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
            
            NSError *error = [[NSError alloc] init];
            reject(@"no_player", @"There is no player", error);
        } else {
            JWCastingDevice *device = view.connectedDevice;
            
            if (device != nil) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    
                [dict setObject:device.name forKey:@"name"];
                [dict setObject:device.identifier forKey:@"identifier"];

                NSError *error;
                NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error: &error];
                
                resolve([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            } else {
                NSError *error = [[NSError alloc] init];
                reject(@"no_connected_device", @"There is no connected device", error);
            }
        }
    }];
}

RCT_REMAP_METHOD(availableDevices,
                 tag:(nonnull NSNumber *)reactTag
                 solve:(RCTPromiseResolveBlock)resolve
                 eject:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
            
            NSError *error = [[NSError alloc] init];
            reject(@"no_player", @"There is no player", error);
        } else {
            if (view.availableDevices != nil) {
                NSMutableArray *devicesInfo = [[NSMutableArray alloc] init];

                for (JWCastingDevice *device in view.availableDevices) {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                        
                    [dict setObject:device.name forKey:@"name"];
                    [dict setObject:device.identifier forKey:@"identifier"];

                    [devicesInfo addObject:dict];
                }

                NSError *error;
                NSData *data = [NSJSONSerialization dataWithJSONObject:devicesInfo options:NSJSONWritingPrettyPrinted error: &error];
                
                resolve([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            } else {
                NSError *error = [[NSError alloc] init];
                               reject(@"no_available_device", @"There are no available devices", error);
            }
        }
    }];
}

RCT_REMAP_METHOD(castState,
                 tag:(nonnull NSNumber *)reactTag
                 solver:(RCTPromiseResolveBlock)resolve
                 ejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
            
            NSError *error = [[NSError alloc] init];
            reject(@"no_player", @"There is no player", error);
        } else {
            resolve([NSNumber numberWithInt:[view castState]]);
        }
    }];
}

@end
