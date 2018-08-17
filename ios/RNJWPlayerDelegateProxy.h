#import <Foundation/Foundation.h>

#import "RNJWPlayerNativeView.h"

@class RNJWPlayerNativeView;

@interface RNJWPlayerDelegateProxy : NSObject<JWPlayerDelegate>

@property(nonatomic, strong)RNJWPlayerNativeView *delegate;

@end
