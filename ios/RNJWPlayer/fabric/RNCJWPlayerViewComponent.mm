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
#import <react/renderer/components/rnjwplayer/RNCSafeAreaViewComponentDescriptor.h>
#import <react/renderer/components/rnjwplayer/RNCSafeAreaViewShadowNode.h>

#import <React/RCTConversions.h>
#import <React/RCTFabricComponentsPlugins.h>

#import "RNCSafeAreaProviderComponentView.h"
#import "RNCSafeAreaUtils.h"

using namespace facebook::react;

@interface RNCJWPlayerViewComponent () <RCTRNJWPlayerViewProtocol>
@end
