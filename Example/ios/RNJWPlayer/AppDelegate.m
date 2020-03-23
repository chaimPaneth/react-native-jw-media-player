/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "AppDelegate.h"

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>

#import <AVFoundation/AVFoundation.h>

NSString* const AudioInterruptionsDidStart = @"AudioInterruptionsStarted";
NSString* const AudioInterruptionsDidEnd = @"AudioInterruptionsEnded";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
   
  [[NSNotificationCenter defaultCenter] addObserver: self
                                          selector: @selector(audioSessionInterrupted:)
                                              name: AVAudioSessionInterruptionNotification
                                            object: audioSession];
 
  NSError *setCategoryError = nil;
  BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
 
  NSError *activationError = nil;
  success = [audioSession setActive:YES error:&activationError];
  
  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
                                                   moduleName:@"RNJWPlayer"
                                            initialProperties:nil];

  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

-(void)audioSessionInterrupted:(NSNotification*)note
{
  if ([note.name isEqualToString:AVAudioSessionInterruptionNotification]) {
    NSLog(@"Interruption notification");

    if ([[note.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AudioInterruptionsDidStart object:self userInfo:nil];
    } else {
      [[NSNotificationCenter defaultCenter] postNotificationName:AudioInterruptionsDidEnd object:self userInfo:nil];
    }
  }
}

@end
