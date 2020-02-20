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
RCT_EXPORT_VIEW_PROPERTY(onPlayerReady, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onControlBarVisible, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBeforeComplete, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onComplete, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onAdPlay, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(file, NSString);
RCT_EXPORT_VIEW_PROPERTY(mediaId, NSString);
RCT_EXPORT_VIEW_PROPERTY(title, NSString);
RCT_EXPORT_VIEW_PROPERTY(image, NSString);
RCT_EXPORT_VIEW_PROPERTY(desc, NSString);
RCT_EXPORT_VIEW_PROPERTY(autostart, BOOL);
RCT_EXPORT_VIEW_PROPERTY(controls, BOOL);
RCT_EXPORT_VIEW_PROPERTY(repeat, BOOL);
RCT_EXPORT_VIEW_PROPERTY(displayTitle, BOOL);
RCT_EXPORT_VIEW_PROPERTY(displayDesc, BOOL);
RCT_EXPORT_VIEW_PROPERTY(nextUpDisplay, BOOL);
RCT_EXPORT_VIEW_PROPERTY(playlistItem, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(playlist, NSArray);
RCT_EXPORT_VIEW_PROPERTY(playerStyle, NSString);
RCT_EXPORT_VIEW_PROPERTY(colors, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(nativeFullScreen, BOOL);
RCT_EXPORT_VIEW_PROPERTY(fullScreenOnLandscape, BOOL);
RCT_EXPORT_VIEW_PROPERTY(landscapeOnFullScreen, BOOL);

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

RCT_EXPORT_METHOD(setFullscreen: (nonnull NSNumber *)reactTag: (bool)fs) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNJWPlayerNativeView *> *viewRegistry) {
        RNJWPlayerNativeView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNJWPlayerNativeView class]] || view.player == nil) {
            RCTLogError(@"Invalid view returned from registry, expecting RNJWPlayerNativeView, got: %@", view);
        } else {
            [view.player setFullscreen:fs];
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

@end
