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

- (void)extendTimelineForComplication {
  id server = [CLKComplicationServer sharedInstance];
  for (id complication in [server activeComplications]) {
    [server extendTimelineForComplication:complication];
  }
}

- (void)applicationDidBecomeActive {
  [self scheduleBackgroundTask];
  [self extendTimelineForComplication];
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
      [self extendTimelineForComplication];
      [self scheduleBackgroundTask];
    }
    [task setTaskCompletedWithSnapshot:NO];
  }
}

@end
