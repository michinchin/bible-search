#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
@import GoogleMobileAds;
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
