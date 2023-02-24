//
//  RCTConvert+RNJWPlayer.m
//  RNJWPlayer
//
//  Created by Chaim Paneth on 10/29/21.
//

#import "RCTConvert+RNJWPlayer.h"

@implementation RCTConvert (RNJWPlayer)

RCT_ENUM_CONVERTER(JWAdClient, (@{
    @"vast": @(JWAdClientJWPlayer),
    @"ima": @(JWAdClientGoogleIMA),
    @"ima_dai": @(JWAdClientGoogleIMADAI),
}), JWAdClientUnknown, integerValue)

RCT_ENUM_CONVERTER(JWInterfaceBehavior, (@{
    @"normal": @(JWInterfaceBehaviorNormal),
    @"hidden": @(JWInterfaceBehaviorHidden),
    @"onscreen": @(JWInterfaceBehaviorAlwaysOnScreen),
}), JWInterfaceBehaviorNormal, integerValue)

RCT_ENUM_CONVERTER(JWCaptionEdgeStyle, (@{
    @"none": @(JWCaptionEdgeStyleNone),
    @"dropshadow": @(JWCaptionEdgeStyleDropshadow),
    @"raised": @(JWCaptionEdgeStyleRaised),
    @"depressed": @(JWCaptionEdgeStyleDepressed),
    @"uniform": @(JWCaptionEdgeStyleUniform),
}), JWCaptionEdgeStyleUndefined, integerValue)

RCT_ENUM_CONVERTER(JWPreload, (@{
    @"auto": @(JWPreloadAuto),
    @"none": @(JWPreloadNone),
}), JWPreloadNone, integerValue)

RCT_ENUM_CONVERTER(JWRelatedOnClick, (@{
    @"play": @(JWRelatedOnClickPlay),
    @"link": @(JWRelatedOnClickLink),
}), JWRelatedOnClickPlay, integerValue)

RCT_ENUM_CONVERTER(JWRelatedOnComplete, (@{
    @"show": @(JWRelatedOnCompleteShow),
    @"hide": @(JWRelatedOnCompleteHide),
    @"autoplay": @(JWRelatedOnCompleteAutoplay),
}), JWRelatedOnCompleteShow, integerValue)

RCT_ENUM_CONVERTER(JWControlType, (@{
    @"forward": @(JWControlTypeFastForwardButton),
    @"rewind": @(JWControlTypeRewindButton),
    @"pip": @(JWControlTypePictureInPictureButton),
    @"airplay": @(JWControlTypeAirplayButton),
    @"chromecast": @(JWControlTypeChromecastButton),
    @"next": @(JWControlTypeNextButton),
    @"previous": @(JWControlTypePreviousButton),
    @"settings": @(JWControlTypeSettingsButton),
    @"languages": @(JWControlTypeLanguagesButton),
    @"fullscreen": @(JWControlTypeFullscreenButton),
}), JWControlTypeFullscreenButton, integerValue)

@end
