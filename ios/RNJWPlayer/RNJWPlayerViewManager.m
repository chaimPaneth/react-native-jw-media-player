#import <JWPlayerKit/JWPlayerKit-swift.h>

#import "RNJWPlayerViewManager.h"
#import "RNJWPlayerView.h"

#import "RCTUIManager.h"

@interface RNJWPlayerViewManager ()

@end

@implementation RNJWPlayerViewManager

RCT_EXPORT_MODULE()

- (UIView*)view
{
    return [[RNJWPlayerView alloc] init];
}

/* player state events */
RCT_EXPORT_VIEW_PROPERTY(onTime, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onLoaded, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onSeek, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onSeeked, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlaylist, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlaylistComplete, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBeforeComplete, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onComplete, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVisible, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBeforePlay, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onAttemptPlay, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlay, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPause, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBuffer, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onUpdateBuffer, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onIdle, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlaylistItem, RCTBubblingEventBlock);

/* av events */
RCT_EXPORT_VIEW_PROPERTY(onAudioTracks, RCTBubblingEventBlock);

/* player events */
RCT_EXPORT_VIEW_PROPERTY(onPlayerReady, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onSetupPlayerError, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerError, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerWarning, RCTBubblingEventBlock);

/* ad events */
RCT_EXPORT_VIEW_PROPERTY(onPlayerAdWarning, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerAdError, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onAdEvent, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onAdTime, RCTBubblingEventBlock);

/* jwplayer view controller events */
RCT_EXPORT_VIEW_PROPERTY(onControlBarVisible, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onScreenTapped, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFullScreen, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFullScreenRequested, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFullScreenExit, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFullScreenExitRequested, RCTBubblingEventBlock);

/* jwplayer view events */
RCT_EXPORT_VIEW_PROPERTY(onPlayerSizeChange, RCTBubblingEventBlock);

/* casting events */
RCT_EXPORT_VIEW_PROPERTY(onCastingDevicesAvailable, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onConnectedToCastingDevice, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onDisconnectedFromCastingDevice, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onConnectionTemporarilySuspended, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onConnectionRecovered, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onConnectionFailed, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onCasting, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onCastingEnded, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onCastingFailed, RCTBubblingEventBlock);

/* props */
RCT_EXPORT_VIEW_PROPERTY(config, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(controls, BOOL);

RCT_REMAP_METHOD(state,
                 tag:(nonnull NSNumber*)reactTag
                 stateWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || (view.playerViewController == nil && view.playerView == nil)) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
            
            NSError *error = [[NSError alloc] init];
            reject(@"no_player", @"There is no playerViewController or playerView", error);
        } else {
            if (view.playerViewController) {
                resolve([NSNumber numberWithInt:[view.playerViewController.player getState]]);
            } else if (view.playerView) {
                resolve([NSNumber numberWithInt:[view.playerView.player getState]]);
            } else {
                NSError *error = [[NSError alloc] init];
                reject(@"no_player", @"There is no playerView", error);
            };
        }
    }];
}

RCT_EXPORT_METHOD(pause:(nonnull NSNumber*)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || (view.playerViewController == nil && view.playerView == nil)) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            view.userPaused = YES;
            if (view.playerView) {
                [view.playerView.player pause];
            } else if (view.playerViewController) {
                [view.playerViewController.player pause];
            }
        }
    }];
}

RCT_EXPORT_METHOD(play:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || (view.playerViewController == nil && view.playerView == nil)) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            if (view.playerView) {
                [view.playerView.player play];
            } else if (view.playerViewController) {
                [view.playerViewController.player play];
            }
        }
    }];
    
}

RCT_EXPORT_METHOD(stop:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || (view.playerViewController == nil && view.playerView == nil)) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            view.userPaused = YES;
            if (view.playerView) {
                [view.playerView.player stop];
            } else if (view.playerViewController) {
                [view.playerViewController.player stop];
            }
        }
    }];
    
}

RCT_REMAP_METHOD(position,
                 tag:(nonnull NSNumber *)reactTag
                 positionResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || (view.playerViewController == nil && view.playerView == nil)) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
            
            NSError *error = [[NSError alloc] init];
            reject(@"no_player", @"There is no playerView", error);
        } else {
            if (view.playerView) {
                resolve(@(view.playerView.player.time.position));
            } else if (view.playerViewController) {
                resolve(@(view.playerViewController.player.time.position));
            }
        }
    }];
}

RCT_EXPORT_METHOD(toggleSpeed:(nonnull NSNumber*)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || (view.playerViewController == nil && view.playerView == nil)) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            if (view.playerView) {
                if ([view.playerView.player playbackRate] < 2.0) {
                    view.playerView.player.playbackRate = [view.playerView.player playbackRate] + 0.5;
                } else {
                    view.playerView.player.playbackRate = 0.5;
                }
            } else if (view.playerViewController) {
                if ([view.playerViewController.player playbackRate] < 2.0) {
                    view.playerViewController.player.playbackRate = [view.playerViewController.player playbackRate] + 0.5;
                } else {
                    view.playerViewController.player.playbackRate = 0.5;
                }
            }
        }
    }];
    
}

RCT_EXPORT_METHOD(setSpeed:(nonnull NSNumber*)reactTag: (double)speed) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || (view.playerViewController == nil && view.playerView == nil)) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            if (view.playerView) {
                view.playerView.player.playbackRate = speed;
            } else if (view.playerViewController) {
                view.playerViewController.player.playbackRate = speed;
            }
        }
    }];
}

RCT_EXPORT_METHOD(setPlaylistIndex: (nonnull NSNumber *)reactTag: (nonnull NSNumber *)index) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || (view.playerViewController == nil && view.playerView == nil)) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            if (view.playerView) {
                [view.playerView.player loadPlayerItemAtIndex:[index integerValue]];
            } else if (view.playerViewController) {
                [view.playerViewController.player loadPlayerItemAtIndex:[index integerValue]];
            }
        }
    }];
}

RCT_EXPORT_METHOD(seekTo :(nonnull NSNumber *)reactTag: (nonnull NSNumber *)time) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || (view.playerViewController == nil && view.playerView == nil)) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            if (view.playerView) {
                [view.playerView.player seekTo:[time integerValue]];
            } else if (view.playerViewController) {
                [view.playerViewController.player seekTo:[time integerValue]];
            }
        }
    }];
}

RCT_EXPORT_METHOD(setVolume: (nonnull NSNumber *)reactTag :(nonnull NSNumber *)volume) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || (view.playerViewController == nil && view.playerView == nil)) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            if (view.playerView) {
                [view.playerView.player setVolume:[volume floatValue]];
            } else if (view.playerViewController) {
                [view.playerViewController.player setVolume:[volume floatValue]];
            }
        }
    }];
}

RCT_EXPORT_METHOD(togglePIP: (nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || view.playerView == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            AVPictureInPictureController* pipController = view.playerView.pictureInPictureController;
            if (pipController != nil && pipController.pictureInPicturePossible) {
                if (pipController.pictureInPictureActive) {
                    [pipController stopPictureInPicture];
                } else {
                    [pipController startPictureInPicture];
                }
            }
        }
    }];
}

RCT_EXPORT_METHOD(setUpCastController: (nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || view.playerView == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            [view setUpCastController];
        }
    }];
}

RCT_EXPORT_METHOD(presentCastDialog: (nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || view.playerView == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
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
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || view.playerView == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
            
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
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || view.playerView == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
            
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
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || view.playerView == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
            
            NSError *error = [[NSError alloc] init];
            reject(@"no_player", @"There is no player", error);
        } else {
            resolve([NSNumber numberWithInt:[view castState]]);
        }
    }];
}

RCT_REMAP_METHOD(getAudioTracks,
                 tag:(nonnull NSNumber *)reactTag
                 resolve:(RCTPromiseResolveBlock)resolve
                 eject:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || (view.playerView == nil && view.playerViewController == nil)) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);

            NSError *error = [[NSError alloc] init];
            reject(@"no_player", @"There is no player", error);
        } else {
            NSArray *audioTracks;
            if (view.playerView) {
                audioTracks = [view.playerView.player audioTracks];
            } else if (view.playerViewController) {
                audioTracks = [view.playerViewController.player audioTracks];
            }
            
            if (audioTracks) {
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
            } else {
                NSError *error = [[NSError alloc] init];
                reject(@"no_audio_tracks", @"There are no audio tracks.", error);
            }
        }
    }];
}

RCT_REMAP_METHOD(getCurrentAudioTrack,
                 tag:(nonnull NSNumber *)reactTag
                 resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || (view.playerView == nil && view.playerViewController == nil)) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);

            NSError *error = [[NSError alloc] init];
            reject(@"no_player", @"There is no player", error);
        } else {
            if (view.playerView) {
                resolve([NSNumber numberWithInteger:[view.playerView.player currentAudioTrack]]);
            } else if (view.playerViewController) {
                resolve([NSNumber numberWithInteger:[view.playerViewController.player currentAudioTrack]]);
            } else {
                NSError *error = [[NSError alloc] init];
                reject(@"no_player", @"There is no player", error);
            }
        }
    }];
}

RCT_EXPORT_METHOD(setCurrentAudioTrack: (nonnull NSNumber *)reactTag: (nonnull NSNumber *)index) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || (view.playerView == nil && view.playerViewController == nil)) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            if (view.playerView) {
                [view.playerView.player setCurrentAudioTrack:[index integerValue]];
            } else if (view.playerViewController) {
                [view.playerViewController.player setCurrentAudioTrack:[index integerValue]];
            }
        }
    }];
}

RCT_EXPORT_METHOD(setControls: (nonnull NSNumber *)reactTag: (BOOL)show) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || (view.playerView == nil && view.playerViewController == nil)) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            if (view.playerViewController) {
                [view toggleUIGroup:view.playerViewController.view :@"JWPlayerKit.InterfaceView" :nil :show];
            }
        }
    }];
}

RCT_EXPORT_METHOD(setLockScreenControls: (nonnull NSNumber *)reactTag: (BOOL)show) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || (view.playerView == nil && view.playerViewController == nil)) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            if (view.playerViewController) {
                view.playerViewController.enableLockScreenControls = show;
            }
        }
    }];
}

RCT_EXPORT_METHOD(setCurrentCaptions: (nonnull NSNumber *)reactTag: (nonnull NSNumber *)index) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || (view.playerView == nil && view.playerViewController == nil)) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            if (view.playerView) {
                [view.playerView.player setCurrentCaptionsTrack:[index integerValue] + 1];
            } else if (view.playerViewController) {
                [view.playerViewController.player setCurrentCaptionsTrack:[index integerValue] + 1];
            }
        }
    }];
}

RCT_EXPORT_METHOD(setLicenseKey: (nonnull NSNumber *)reactTag: (nonnull NSString *)license) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            [view setLicense:license];
        }
    }];
}

RCT_EXPORT_METHOD(quite) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        for (id view in viewRegistry) {
            if ([view isKindOfClass:[RNJWPlayerView class]]) {
                RNJWPlayerView *rnjwView = view;
                if (rnjwView.playerView) {
                    [rnjwView.playerView.player pause];
                    [rnjwView.playerView.player stop];
                } else if (rnjwView.playerViewController) {
                    [rnjwView.playerViewController.player pause];
                    [rnjwView.playerViewController.player stop];
                }
            }
        }
    }];
}

RCT_EXPORT_METHOD(reset) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        for (id view in viewRegistry) {
            if ([view isKindOfClass:[RNJWPlayerView class]]) {
                RNJWPlayerView *rnjwView = view;
                if (rnjwView) {
                    [rnjwView startDeinitProcess];
                }
            }
        }
    }];
}

@end
