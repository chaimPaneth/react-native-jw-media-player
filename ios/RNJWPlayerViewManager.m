#import <JWPlayerKit/JWPlayerKit-swift.h>

#import "RNJWPlayerViewManager.h"
#import "RNJWPlayerView.h"

#import "RCTUIManager.h"

@interface RNJWPlayerViewManager ()

@end

@implementation RNJWPlayerViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
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
        if (![view isKindOfClass:[RNJWPlayerView class]] || view.playerView == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
            
            NSError *error = [[NSError alloc] init];
            reject(@"no_player", @"There is no playerView", error);
        } else {
            if (view.playerView) {
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
        if (![view isKindOfClass:[RNJWPlayerView class]] || view.playerView == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            view.userPaused = YES;
            [view.playerView.player pause];
        }
    }];
}

RCT_EXPORT_METHOD(play:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || view.playerView == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
//            view.playerView.config.controls = [view.playerView.player controls];
            [view.playerView.player play];
        }
    }];
    
}

RCT_EXPORT_METHOD(stop:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || view.playerView == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            view.userPaused = YES;
            [view.playerView.player stop];
        }
    }];
    
}

RCT_REMAP_METHOD(time,
                 tag:(nonnull NSNumber *)reactTag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || view.playerView.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
            
            NSError *error = [[NSError alloc] init];
            reject(@"no_player", @"There is no playerView", error);
        } else {
            resolve(@{@"time": view.playerView.player.time});
        }
    }];
}

RCT_EXPORT_METHOD(toggleSpeed:(nonnull NSNumber*)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || view.playerView == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            if ([view.playerView.player playbackRate] < 2.0) {
                view.playerView.player.playbackRate = [view.playerView.player playbackRate] + 0.5;
            } else {
                view.playerView.player.playbackRate = 0.5;
            }
        }
    }];
    
}

RCT_EXPORT_METHOD(setSpeed:(nonnull NSNumber*)reactTag: (double)speed) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || view.playerView == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            view.playerView.player.playbackRate = speed;
        }
    }];
}

RCT_EXPORT_METHOD(setPlaylistIndex: (nonnull NSNumber *)reactTag: (nonnull NSNumber *)index) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || view.playerView == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            [view.playerView.player loadPlayerItemAtIndex:[index integerValue]];
        }
    }];
}

RCT_EXPORT_METHOD(seekTo :(nonnull NSNumber *)reactTag: (nonnull NSNumber *)time) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || view.playerView == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            [view.playerView.player seekTo:[time integerValue]];
        }
    }];
}

RCT_EXPORT_METHOD(setFullscreen: (nonnull NSNumber *)reactTag: (BOOL)fs) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || view.playerView == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
//            [view.playerView.player setFullscreen:fs];
        }
    }];
}

RCT_EXPORT_METHOD(setVolume: (nonnull NSNumber *)reactTag :(nonnull NSNumber *)volume) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerView *> *viewRegistry) {
        RNJWPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerView class]] || view.playerView == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerView, got: %@", view);
        } else {
            [view.playerView.player setVolume:[volume floatValue]];
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
