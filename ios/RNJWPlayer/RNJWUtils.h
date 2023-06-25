//  RNJWUtils.h
#import <Foundation/Foundation.h>

@interface RNJWUtils : NSObject

+ (void)delayWithSeconds:(int)seconds completion:(void (^)(void))completion;

@end
