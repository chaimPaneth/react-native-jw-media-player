#import <Foundation/Foundation.h>

#import "RNJWPlayerNativeView.h"

@class RNJWPlayerNativeView;

@interface RNJWPlayerDelegateProxy : NSObject<JWPlayerDelegate, JWCastingDelegate>

@property(nonatomic, strong)RNJWPlayerNativeView *delegate;

@end
