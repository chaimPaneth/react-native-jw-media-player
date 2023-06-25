//  Utils.m
#import "RNJWUtils.h"

@implementation RNJWUtils

+ (void)delayWithSeconds:(int)seconds completion:(void (^)(void))completion {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (completion) {
            completion();
        }
    });
}

@end
