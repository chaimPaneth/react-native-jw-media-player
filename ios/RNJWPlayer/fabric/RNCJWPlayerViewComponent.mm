//
//  RNCJWPlayerViewComponent.m
//  RNJWPlayer
//
//  Created by Chaim Paneth on 07/03/2024.
//  Copyright © 2024 Facebook. All rights reserved.
//

#import "RNCJWPlayerViewComponent.h"

#import <react/renderer/components/rnjwplayer/EventEmitters.h>
#import <react/renderer/components/rnjwplayer/Props.h>
#import <react/renderer/components/rnjwplayer/RCTComponentViewHelpers.h>
#import <react/renderer/components/rnjwplayer/ComponentDescriptors.h>
#import <react/renderer/components/rnjwplayer/ShadowNodes.h>

#import <React/RCTConversions.h>
#import <React/RCTFabricComponentsPlugins.h>

#import "RNCJWPlayerViewComponent.h"
#import <React/RCTView.h>
#import "RNJWPlayerView.h"
// import helpers here

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
        
        _view = [RNJWPlayerView new];
        
        self.contentView = _view;
    }
    
    return self;
}

#pragma mark - RCTComponentViewProtocol

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<RNJWPlayerComponentDescriptor>();
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps {
    const auto &oldPlayerProps = *std::static_pointer_cast<const RNJWPlayerProps>(_props);
        const auto &newPlayerProps = *std::static_pointer_cast<const RNJWPlayerProps>(props);
    
    [super updateProps:props oldProps:oldProps];
}

@end

Class<RCTComponentViewProtocol> RNJWPlayerViewCls(void)
{
    return RNCJWPlayerViewComponent.class;
}
