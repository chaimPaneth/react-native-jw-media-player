#import "RNJWPlayerDelegateProxy.h"

@implementation RNJWPlayerDelegateProxy
#pragma mark - RNJWPlayer Delegate

-(void)onBeforePlay {
    [self.delegate onRNJWPlayerBeforePlay];
}

-(void)onPlay {
    [self.delegate onRNJWPlayerPlay];
}

-(void)onBuffer {
    [self.delegate onRNJWPlayerBuffer];
}

-(void)onError:(NSError *)error {
    [self.delegate onRNJWPlayerError:error];
}

-(void)onTime:(double)position ofDuration:(double)duration {
    [self.delegate onRNJWPlayerTime:position ofDuration:duration];
}
@end
