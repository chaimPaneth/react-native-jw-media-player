//
//  RCTConvert+RNJWPlayer.m
//  RNJWPlayer
//
//  Created by Chaim Paneth on 10/29/21.
//

#import <JWPlayerKit/JWPlayerKit-swift.h>
#import <React/RCTConvert.h>

@interface RCTConvert (RNJWPlayer)

+ (JWAdClient)JWAdClient:(id)json;

+ (JWInterfaceBehavior)JWInterfaceBehavior:(id)json;

+ (JWCaptionEdgeStyle)JWCaptionEdgeStyle:(id)json;

+ (JWPreload)JWPreload:(id)json;

+ (JWRelatedOnClick)JWRelatedOnClick:(id)json;

+ (JWRelatedOnComplete)JWRelatedOnComplete:(id)json;

+ (JWControlType)JWControlType:(id)json;

@end
