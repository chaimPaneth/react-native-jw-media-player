//
//  RNJWPlayerAds.m
//  RNJWPlayer
//
//  Created by Chaim Paneth on 10/29/21.
//

#import <UIKit/UIKit.h>
#import <JWPlayerKit/JWPlayerKit-swift.h>

@interface RNJWPlayerAds: NSObject

+ (JWAdvertisingConfig *)configureVASTWithAds:(NSDictionary *)ads error:(JWError **)error;

+ (JWAdvertisingConfig *)configureIMAWithAds:(NSDictionary *)ads error:(JWError **)error;

+ (JWAdvertisingConfig *)configureIMADAIWithAds:(NSDictionary *)ads error:(JWError **)error;

+ (NSArray *)getAdSchedule:(NSDictionary *)ads error:(JWError **)error;

+ (JWAdRules *)getAdRules:(NSDictionary *)adRulesDict error:(JWError **)error;

+ (JWAdShownOnSeek)mapStringToJWAdShownOnSeek:(NSString *)seekString;

+ (JWImaSettings *)getIMASettings:(NSDictionary *)imaSettingsDict;

+ (JWGoogleDAIStream *)getGoogleDAIStream:(NSDictionary *)googleDAIStreamDict error:(JWError **)error;

@end
