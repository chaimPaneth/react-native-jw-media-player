#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>

#import <React/RCTLinkingManager.h>

#import "Orientation.h"
#import "RNFSManager.h"
#import "RNBootSplash.h"

#if USE_GOOGLE_CAST
  #import <GoogleCast/GoogleCast.h>

  static NSString *const kReceiverAppID = @"RNJWPlayer";
#endif

@implementation AppDelegate

-(void)initApis:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions
{
  #if USE_GOOGLE_CAST
    GCKDiscoveryCriteria *criteria = [[GCKDiscoveryCriteria alloc]
                                      initWithApplicationID:kReceiverAppID];
    GCKCastOptions *options = [[GCKCastOptions alloc] initWithDiscoveryCriteria:criteria];
    [GCKCastContext setSharedInstanceWithOptions:options];
  #endif
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"RNJWPlayer";

  [self initApis:application launchOptions:launchOptions];

  // You can add your custom initial props in the dictionary below.
  // They will be passed down to the ViewController used by React Native.
  self.initialProps = @{};

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (UIView *)createRootViewWithBridge:(RCTBridge *)bridge
                          moduleName:(NSString *)moduleName
                           initProps:(NSDictionary *)initProps {
  UIView *rootView = [super createRootViewWithBridge:bridge
                                          moduleName:moduleName
                                           initProps:initProps];

  [RNBootSplash initWithStoryboard:@"LaunchScreen" rootView:rootView]; // ⬅️ initialize the splash screen

  return rootView;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
  return [self getBundleURL];
}

- (NSURL *)getBundleURL
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
  return [RCTLinkingManager application:app openURL:url options:options];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity
 restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
 return [RCTLinkingManager application:application
                  continueUserActivity:userActivity
                    restorationHandler:restorationHandler];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
  [RNFSManager setCompletionHandlerForIdentifier:identifier completionHandler:completionHandler];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
  return [Orientation getOrientation];
}

@end
