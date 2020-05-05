#import "ExtensionDelegate.h"

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
  [self scheduleBackgroundTask];
}

- (void)scheduleBackgroundTask {
  [[WKExtension sharedExtension]
      scheduleBackgroundRefreshWithPreferredDate:
          [[NSDate now] dateByAddingTimeInterval:3600]
                                        userInfo:nil
                             scheduledCompletion:^(NSError* err) {
                               if (err != nil) {
                                 NSLog(@"Error! %@", err);
                               }
                             }];
}

- (void)applicationDidBecomeActive {
  // Restart any tasks that were paused (or not yet started) while the
  // application was inactive. If the application was previously in the
  // background, optionally refresh the user interface.
}

- (void)applicationWillResignActive {
  // Sent when the application is about to move from active to inactive state.
  // This can occur for certain types of temporary interruptions (such as an
  // incoming phone call or SMS message) or when the user quits the application
  // and it begins the transition to the background state. Use this method to
  // pause ongoing tasks, disable timers, etc.
}

- (void)handleBackgroundTasks:
    (NSSet<WKRefreshBackgroundTask*>*)backgroundTasks {
  for (WKRefreshBackgroundTask* task in backgroundTasks) {
    if ([task isKindOfClass:[WKApplicationRefreshBackgroundTask class]]) {
      // Reload complication.
      id server = [CLKComplicationServer sharedInstance];
      for (id complication in [server activeComplications]) {
        [server reloadTimelineForComplication:complication];
      }
      [self scheduleBackgroundTask];
    }
    [task setTaskCompletedWithSnapshot:NO];
  }
}

@end
