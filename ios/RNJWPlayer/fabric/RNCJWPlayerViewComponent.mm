//
//  RNCJWPlayerViewComponent.m
//  RNJWPlayer
//
//  Created by Chaim Paneth on 07/03/2024.
//  Copyright © 2024 Facebook. All rights reserved.
//

#import "RNCJWPlayerViewComponent.h"

#import <React/RCTViewComponentView.h>
#import <react/renderer/components/rnjwplayer/EventEmitters.h>
#import <react/renderer/components/rnjwplayer/Props.h>
#import <react/renderer/components/rnjwplayer/RCTComponentViewHelpers.h>
#import <react/renderer/components/rnjwplayer/ComponentDescriptors.h>
#import <react/renderer/components/rnjwplayer/ShadowNodes.h>

#import <React/RCTConversions.h>
#import <React/RCTFabricComponentsPlugins.h>

#import <React/RCTView.h>
#import "RNJWPlayer-Swift.h"

using namespace facebook::react;

@interface RNCJWPlayerViewComponent () <RCTRNJWPlayerViewProtocol>
@end

@implementation RNCJWPlayerViewComponent {
    RNJWPlayerView *_view;
}

+(void) load {
    [super load];
}

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        static const auto defaultProps = std::make_shared<const RNJWPlayerProps>();
        _props = defaultProps;
        
        _view = [RNJWPlayerView alloc];
        
        self.contentView = _view;
    }
    
    return self;
}

#pragma mark - RCTComponentViewProtocol

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<SharedComponentDescriptor>();
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps {
    const auto &oldPlayerProps = *std::static_pointer_cast<const RNJWPlayerProps>(_props);
    const auto &newPlayerProps = *std::static_pointer_cast<const RNJWPlayerProps>(props);
    
//    if (oldPlayerProps.config != newPlayerProps.config) {
        [_view setConfig:newPlayerProps.config];
//    }
    
    if (oldPlayerProps.controls != newPlayerProps.controls) {
        [_view setControls:newPlayerProps.controls];
    }
    
    [super updateProps:props oldProps:oldProps];
}

#pragma mark - Native Commands

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args
{
    RCTRNJWPlayerHandleCommand(self, commandName, args);
}

- (BOOL)isJSResponder { 
    
}

- (void)mountChildComponentView:(nonnull UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index { 
    
}


- (nullable NSSet<NSString *> *)propKeysManagedByAnimated_DO_NOT_USE_THIS_IS_BROKEN { 
    
}


- (facebook::react::Props::Shared)props { 
    
}


- (void)setIsJSResponder:(BOOL)isJSResponder { 
    
}


- (void)setPropKeysManagedByAnimated_DO_NOT_USE_THIS_IS_BROKEN:(nullable NSSet<NSString *> *)props { 
    
}


+ (std::vector<facebook::react::ComponentDescriptorProvider>)supplementalComponentDescriptorProviders { 
    
}


- (void)unmountChildComponentView:(nonnull UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index { 
    
}


- (void)updateState:(const facebook::react::State::Shared &)state oldState:(const facebook::react::State::Shared &)oldState { 
    
}


- (void)play
{
    if (_view.playerView != nil) {
        [_view.playerView.player play];
    } else if (_view.playerViewController != nil) {
        [_view.playerViewController.player play];
    }
}

- (void)pause { 
    if (_view.playerView != nil) {
        [_view.playerView.player pause];
    } else if (_view.playerViewController != nil) {
        [_view.playerViewController.player pause];
    }
}

- (void)getAudioTracks { 
    
}


- (void)getCurrentAudioTrack { 
    
}


- (void)getCurrentQuality { 
    
}


- (void)getQualityLevels { 
    
}


- (void)loadPlaylist:(nonnull NSString *)playlistItems { 
    
}


- (void)playerState { 
    
}


- (void)position { 
    
}


- (void)quite { 
    
}


- (void)reset { 
    
}


- (void)seekTo:(float)time { 
    
}


- (void)setControls:(BOOL)show { 
    
}


- (void)setCurrentAudioTrack:(NSInteger)index { 
    
}


- (void)setCurrentCaptions:(NSInteger)index { 
    
}


- (void)setCurrentQuality:(float)index { 
    
}


- (void)setFullscreen:(BOOL)fullScreen { 
    
}


- (void)setLockScreenControls:(BOOL)show { 
    
}


- (void)setPlaylistIndex:(float)index { 
    
}


- (void)setSpeed:(float)speed { 
    
}

#if USE_GOOGLE_CAST
- (void)setUpCastController { 
    
}

- (void)presentCastDialog { 
    
}

- (void)availableDevices { 
    
}


- (void)castState { 
    
}


- (void)connectedDevice { 
    
}
#endif

- (void)setVisibility:(BOOL)visibility controls:(nonnull NSString *)controls { 
    if (_view.playerViewController != nil) {
        [_view setVisibilityWithIsVisible:visibility forControls:@[controls]]; // need to parse / change controls arg to [string]
    }
}


- (void)setVolume:(float)volume { 
    if (_view.playerView != nil) {
        _view.playerView.player.volume = volume;
    } else if (_view.playerViewController != nil) {
        _view.playerViewController.player.volume = volume;
    }
}


- (void)stop { 
    _view.userPaused = YES;
    if (_view.playerView != nil) {
        [_view.playerView.player stop];
    } else if (_view.playerViewController != nil) {
        [_view.playerViewController.player stop];
    }
}


- (void)toggleSpeed { 
    if (_view.playerView != nil) {
        if (_view.playerView.player.playbackRate < 2.0) {
            _view.playerView.player.playbackRate += 0.5;
        } else {
            _view.playerView.player.playbackRate = 0.5;
        }
    } else if (_view.playerViewController != nil) {
        if (_view.playerViewController.player.playbackRate < 2.0) {
            _view.playerViewController.player.playbackRate += 0.5;
        } else {
            _view.playerViewController.player.playbackRate = 0.5;
        }
    }
}

#pragma mark - Native Events

- (facebook::react::SharedTouchEventEmitter)touchEventEmitterAtPoint:(CGPoint)point { 
    
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder { 
    
}

+ (nonnull instancetype)appearance { 
    
}

+ (nonnull instancetype)appearanceForTraitCollection:(nonnull UITraitCollection *)trait { 
    
}

+ (nonnull instancetype)appearanceForTraitCollection:(nonnull UITraitCollection *)trait whenContainedIn:(nullable Class<UIAppearanceContainer>)ContainerClass, ... { 
    
}

+ (nonnull instancetype)appearanceForTraitCollection:(nonnull UITraitCollection *)trait whenContainedInInstancesOfClasses:(nonnull NSArray<Class<UIAppearanceContainer>> *)containerTypes { 
    
}

+ (nonnull instancetype)appearanceWhenContainedIn:(nullable Class<UIAppearanceContainer>)ContainerClass, ... { 
    
}

+ (nonnull instancetype)appearanceWhenContainedInInstancesOfClasses:(nonnull NSArray<Class<UIAppearanceContainer>> *)containerTypes { 
    
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection { 
    
}

- (CGPoint)convertPoint:(CGPoint)point fromCoordinateSpace:(nonnull id<UICoordinateSpace>)coordinateSpace { 
    
}

- (CGPoint)convertPoint:(CGPoint)point toCoordinateSpace:(nonnull id<UICoordinateSpace>)coordinateSpace { 
    
}

- (CGRect)convertRect:(CGRect)rect fromCoordinateSpace:(nonnull id<UICoordinateSpace>)coordinateSpace { 
    
}

- (CGRect)convertRect:(CGRect)rect toCoordinateSpace:(nonnull id<UICoordinateSpace>)coordinateSpace { 
    
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator { 
    
}

- (void)setNeedsFocusUpdate { 
    
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context { 
    
}

- (void)updateFocusIfNeeded { 
    
}

- (nonnull NSArray<id<UIFocusItem>> *)focusItemsInRect:(CGRect)rect { 
    
}

@end

Class<RCTComponentViewProtocol> RNJWPlayerViewCls(void)
{
    return RNCJWPlayerViewComponent.class;
}
