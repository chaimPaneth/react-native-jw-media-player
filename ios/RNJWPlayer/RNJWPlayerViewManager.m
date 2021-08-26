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

/* player events */
RCT_EXPORT_VIEW_PROPERTY(onPlayerReady, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onSetupPlayerError, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerError, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerWarning, RCTBubblingEventBlock);

/* ad events */
RCT_EXPORT_VIEW_PROPERTY(onPlayerAdWarning, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerAdError, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onAdEvent, RCTBubblingEventBlock);

/* jwplayer view controller events */
RCT_EXPORT_VIEW_PROPERTY(onControlBarVisible, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onScreenTapped, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFullScreen, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFullScreenRequested, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFullScreenExit, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFullScreenExitRequested, RCTBubblingEventBlock);

/* jwplayer view events */
RCT_EXPORT_VIEW_PROPERTY(onPlayerSizeChange, RCTBubblingEventBlock);

/* props */
RCT_EXPORT_VIEW_PROPERTY(config, NSDictionary);

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

RCT_REMAP_METHOD(time,
                 tag:(nonnull NSNumber *)reactTag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || (view.playerViewController == nil && view.playerView == nil)) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
            
            NSError *error = [[NSError alloc] init];
            reject(@"no_player", @"There is no playerView", error);
        } else {
            if (view.playerView) {
                resolve(@{@"time": view.playerView.player.time});
            } else if (view.playerViewController) {
                resolve(@{@"time": view.playerViewController.player.time});
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

@end
