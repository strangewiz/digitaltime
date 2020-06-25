#import "ExtensionDelegate.h"

@interface ExtensionDelegate () <NSURLSessionTaskDelegate>

@property(nonatomic) NSDate* lastRefresh;

@property(nonatomic, strong) NSURLSession* session;

@end

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
  [self log:@"applicationDidFinishLaunching"];
  [self scheduleBackgroundTask];
  [self reloadTimelineForComplication];
}

- (void)scheduleBackgroundTask {
  [self log:@"scheduleBackgroundTask"];
  [[WKExtension sharedExtension]
      scheduleBackgroundRefreshWithPreferredDate:
          [[NSDate now] dateByAddingTimeInterval:1800]
                                        userInfo:nil
                             scheduledCompletion:^(NSError* err) {
                               if (err != nil) {
                                 NSLog(@"Error! %@", err);
                                 [self log:@"scheduleBackgroundTask_fail"];
                               } else {
                                 [self log:@"scheduleBackgroundTask_pass"];
                               }
                             }];
}

- (void)reloadTimelineForComplication {
  if ([[self.lastRefresh dateByAddingTimeInterval:10] compare:[NSDate now]] ==
      NSOrderedDescending) {
        [self log:@"reloadTimelineForComplication_SKIP"];
    return;
  }
  id server = [CLKComplicationServer sharedInstance];
//  #pragma clang diagnostic push
//  #pragma clang diagnostic ignored "-Wundeclared-selector"
//  [server performSelector:@selector(_checkinWithServer)];
//  [server performSelector:@selector(_checkinWithServer)];
//  [server performSelector:@selector(_checkinWithServer)];
//  [server performSelector:@selector(_checkinWithServer)];
//  #pragma clang diagnostic pop
  for (id complication in [server activeComplications]) {
    if (self.lastTime) {
      NSDateFormatter* log_formatter = [[NSDateFormatter alloc] init];
      [log_formatter setDateFormat:@"h:mm"];
      NSString* log =
          [NSString stringWithFormat:@"reloadTimelineForComplication,lasttime:%@",
           [log_formatter stringFromDate:self.lastTime]];
      [self log:log];
    } else {
      [self log:@"reloadTimelineForComplication,nolasttime"];
    }
    [server reloadTimelineForComplication:complication];
  }
  self.refreshCount++;
  self.lastRefresh = [NSDate now];
}

- (void)extendTimelineForComplication {
  if ([[self.lastRefresh dateByAddingTimeInterval:10] compare:[NSDate now]] ==
      NSOrderedDescending) {
        [self log:@"extendTimelineForComplication_SKIP"];
    return;
  }
  [self log:@"extendTimelineForComplication"];
  id server = [CLKComplicationServer sharedInstance];
  for (id complication in [server activeComplications]) {
    [server extendTimelineForComplication:complication];
  }
  self.refreshCount++;
  self.lastRefresh = [NSDate now];
}

- (void)log:(NSString*)msg {
  // Hack, ping home.
  NSLog(@"%@", msg);
  //good:
//  NSString* url = [NSString
//      stringWithFormat:@"https://justinsc.com/watch/ping.php?msg=%@", msg];
//  NSMutableURLRequest* urlRequest =
//      [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
//  [urlRequest setHTTPMethod:@"GET"];

  
  
  // bad.
  //  if (!self.session) {
  //    self.session =
  //    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration
  //        backgroundSessionConfigurationWithIdentifier:
  //            [NSString
  //                stringWithFormat:@"com.justinc.%@", [NSUUID
  //                UUID].UUIDString]];
  //    configuration.allowsCellularAccess = YES;
  //    configuration.sessionSendsLaunchEvents = NO;
  //    configuration.discretionary = NO;
  //    self.session = [NSURLSession sessionWithConfiguration:configuration
  //                                                          delegate:self
  //                                                     delegateQueue:nil];
  //  }
  //good:
//  NSURLSession* session = [NSURLSession sharedSession];
//  NSURLSessionDataTask* dataTask =
//      [session dataTaskWithRequest:urlRequest
//                 completionHandler:^(NSData* data, NSURLResponse* response,
//                                     NSError* error){
//                 }];
//  [dataTask resume];
}

- (void)applicationDidBecomeActive {
  [self log:@"applicationDidBecomeActive"];
  [self scheduleBackgroundTask];
  [self reloadTimelineForComplication];
}

- (void)applicationWillResignActive {
  // Sent when the application is about to move from active to inactive state.
  // This can occur for certain types of temporary interruptions (such as an
  // incoming phone call or SMS message) or when the user quits the application
  // and it begins the transition to the background state. Use this method to
  // pause ongoing tasks, disable timers, etc.
}

//- (void)handleBackgroundTasks:
//    (NSSet<WKRefreshBackgroundTask*>*)backgroundTasks {
//  [self log:@"handleBackgroundTasks"];
//  for (WKRefreshBackgroundTask* task in backgroundTasks) {
//    NSString* msg =
//        [NSString stringWithFormat:@"handleBackgroundTasks,%@", task.class];
//    [self log:msg];
//    //    if ([task isKindOfClass:[WKApplicationRefreshBackgroundTask class]])
//    {
//      [self reloadTimelineForComplication];
//      [self scheduleBackgroundTask];
//      //    }
//      dispatch_after(
//          dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
//          dispatch_get_main_queue(), ^{
//            // Give background task 2 seconds before calling completed.
//            [task setTaskCompletedWithSnapshot:NO];
//          });
//    }
//  }

- (void)handleBackgroundTasks:
    (NSSet<WKRefreshBackgroundTask*>*)backgroundTasks {
  for (WKRefreshBackgroundTask* task in backgroundTasks) {
    // Reload the timeline any chance we get!
    NSString* msg =
        [NSString stringWithFormat:@"handleBackgroundTasks,%@", task.class];
    [self log:msg];
    if ([task isKindOfClass:[WKApplicationRefreshBackgroundTask class]]) {
      [self reloadTimelineForComplication];
      [self scheduleBackgroundTask];
    }
    // Give background task 2 seconds before calling completed, because
    // insanity.
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
          [self completeTask:task];
        });
  }
}

- (void)completeTask:(WKRefreshBackgroundTask*)task {
  if ([task isKindOfClass:[WKApplicationRefreshBackgroundTask class]]) {
    WKApplicationRefreshBackgroundTask* backgroundTask =
        (WKApplicationRefreshBackgroundTask*)task;
    [backgroundTask setTaskCompletedWithSnapshot:NO];
  } else if ([task isKindOfClass:[WKSnapshotRefreshBackgroundTask class]]) {
    WKSnapshotRefreshBackgroundTask* snapshotTask =
        (WKSnapshotRefreshBackgroundTask*)task;
    [snapshotTask setTaskCompletedWithDefaultStateRestored:YES
                               estimatedSnapshotExpiration:
                                   [[NSDate now] dateByAddingTimeInterval:3600]
                                                  userInfo:nil];
  } else if ([task isKindOfClass:[WKWatchConnectivityRefreshBackgroundTask
                                     class]]) {
    WKWatchConnectivityRefreshBackgroundTask* backgroundTask =
        (WKWatchConnectivityRefreshBackgroundTask*)task;
    [backgroundTask setTaskCompletedWithSnapshot:NO];
  } else if ([task isKindOfClass:[WKURLSessionRefreshBackgroundTask class]]) {
    // Be sure to complete the background task once you’re done.
    WKURLSessionRefreshBackgroundTask* backgroundTask =
        (WKURLSessionRefreshBackgroundTask*)task;
    [backgroundTask setTaskCompletedWithSnapshot:NO];
  } else if ([task isKindOfClass:[WKRelevantShortcutRefreshBackgroundTask
                                     class]]) {
    WKRelevantShortcutRefreshBackgroundTask* relevantShortcutTask =
        (WKRelevantShortcutRefreshBackgroundTask*)task;
    [relevantShortcutTask setTaskCompletedWithSnapshot:NO];
  } else if ([task isKindOfClass:[WKIntentDidRunRefreshBackgroundTask class]]) {
    WKIntentDidRunRefreshBackgroundTask* intentDidRunTask =
        (WKIntentDidRunRefreshBackgroundTask*)task;
    [intentDidRunTask setTaskCompletedWithSnapshot:NO];
  } else {
    [task setTaskCompletedWithSnapshot:NO];
  }
}

@end
