#import <WatchKit/WatchKit.h>

#import "ComplicationController.h"
#import "ExtensionDelegate.h"

@interface ComplicationController ()
@end

@implementation ComplicationController

#pragma mark - Timeline Configuration

- (void)
    getSupportedTimeTravelDirectionsForComplication:
        (CLKComplication*)complication
                                        withHandler:
                                            (void (^)(
                                                CLKComplicationTimeTravelDirections
                                                    directions))handler {
  // Only look forward.
  handler(CLKComplicationTimeTravelDirectionForward);
}

- (void)getTimelineStartDateForComplication:(CLKComplication*)complication
                                withHandler:
                                    (void (^)(NSDate* __nullable date))handler {
  ExtensionDelegate* delegate = WKExtension.sharedExtension.delegate;
  [delegate log:@"getTimelineStartDateForComplication"];
  // TODO: Is this necessary?
  handler(nil);
}

- (void)getTimelineEndDateForComplication:(CLKComplication*)complication
                              withHandler:
                                  (void (^)(NSDate* __nullable date))handler {
  ExtensionDelegate* delegate = WKExtension.sharedExtension.delegate;
  [delegate log:@"getTimelineEndDateForComplication"];

  // TODO: I've tried various entries here (hour, distantTime, etc).  For now
  // TODO: just doing nil.
  handler(nil);
  // Tell the system we are good for a day, even though we can't give back 1440
  // repeating timeline entries for eva.
//  if (delegate.lastTime) {
//    handler(delegate.lastTime);
//  } else {
//    handler([[NSDate date] dateByAddingTimeInterval:3600]);
//  }
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication*)complication
                              withHandler:
                                  (void (^)(CLKComplicationPrivacyBehavior
                                                privacyBehavior))handler {
  handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication*)complication
                                   withHandler:
                                       (void (^)(CLKComplicationTimelineEntry*
                                                     __nullable))handler {
  NSDate* date = [NSDate date];

  NSDateFormatter* log_formatter = [[NSDateFormatter alloc] init];
  [log_formatter setDateFormat:@"h:mm:ss"];
  NSString* log =
      [NSString stringWithFormat:@"getCurrentTimelineEntryForComplication,%@",
                                 [log_formatter stringFromDate:date]];
  ExtensionDelegate* delegate = WKExtension.sharedExtension.delegate;
  [delegate log:log];
  
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"h:mm a"];
  CLKComplicationTemplateUtilitarianSmallFlat* template =
      [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];

  [delegate scheduleBackgroundTask];
//  int refresh_count = delegate.refreshCount;
//  NSString* st_2 =
//      [NSString stringWithFormat:@"%@ %d", [formatter stringFromDate:date],
//                                 refresh_count];

  template.textProvider = [CLKSimpleTextProvider textProviderWithText:
                              [formatter stringFromDate:date]];
  handler([CLKComplicationTimelineEntry entryWithDate:date
                                 complicationTemplate:template]);
}

- (void)
    getTimelineEntriesForComplication:(CLKComplication*)complication
                            afterDate:(NSDate*)date
                                limit:(NSUInteger)limit
                          withHandler:
                              (void (^)(NSArray<CLKComplicationTimelineEntry*>*
                                            __nullable entries))handler {
  ExtensionDelegate* delegate = WKExtension.sharedExtension.delegate;
  NSDateFormatter* log_formatter = [[NSDateFormatter alloc] init];
  [log_formatter setDateFormat:@"h:mm:ss"];
  NSString* log =
      [NSString stringWithFormat:@"getTimelineEntriesForComplication,%d,%@",
                                 limit, [log_formatter stringFromDate:date]];
  [delegate log:log];
  
  NSDate* original_date = [date copy];

  if ([date compare:[NSDate now]] == NSOrderedDescending) {
    // SKip the first call for subsequent calls to handler to avoid duplicating.
    date = [date dateByAddingTimeInterval:60];
  }

  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"h:mm a"];

  // Round up to 59 second mark.  This is a little strange, but when the watch
  // is in 'always on'/'dimmed' the time always seems to be off by a minute. By
  // setting the timeline entry time down to 59 seconds and the formatted string
  // to the 'next' minute, we can try to get things in sync.
  NSInteger seconds =
      [[[NSCalendar currentCalendar] components:NSCalendarUnitSecond
                                       fromDate:date] second];
  seconds += 1;
  date = [date dateByAddingTimeInterval:-seconds];
  
  int count = limit;// < 99 ? limit : 99;

  //int refresh_count = delegate.refreshCount;

  // Load the next hour's worth of minutes, or limit's worth if it's less
  // then 60.
  NSMutableArray* array = [NSMutableArray arrayWithCapacity:100];
  for (int minute = 0; minute < count; minute++) {
    date = [date dateByAddingTimeInterval:60];

//    // bail if over 95 minutes, for science.  This is dumb.
//    NSTimeInterval diff = [date timeIntervalSinceDate:[NSDate now]];
//    if (floor(diff/60) >= 95) {
//      handler(array);
//      return;
//    }
    
    CLKComplicationTemplateUtilitarianSmallFlat* template =
        [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];

    // Date here is set back to 58 seconds, so add 2 to format a string for the
    // current (next) minute.
    NSString* st = [formatter stringFromDate:[date dateByAddingTimeInterval:1]];
    // hack
//    NSString* st_2 = [NSString stringWithFormat:@"%@ %d", st, refresh_count];
    NSDate* date_to_use;
    if ([date compare:original_date] == NSOrderedDescending) {
      date_to_use = date;
    } else {
      // Oops, this usually happens for the first date. Just return the original
      // date here plus 1 second.
      date_to_use = [original_date dateByAddingTimeInterval:1];
    }
    NSLog(@"setting %@ for %@", st, date_to_use);
    delegate.lastTime = date_to_use;
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:st];
    [array addObject:[CLKComplicationTimelineEntry entryWithDate:date_to_use
                                            complicationTemplate:template]];
  }
  handler(array);
}

#pragma mark - Placeholder Templates

- (void)
    getLocalizableSampleTemplateForComplication:(CLKComplication*)complication
                                    withHandler:
                                        (void (^)(
                                            CLKComplicationTemplate* __nullable
                                                complicationTemplate))handler {
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"h:mm a"];
  NSDate* date = [NSDate date];
  CLKComplicationTemplateUtilitarianSmallFlat* template =
      [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
  template.textProvider = [CLKSimpleTextProvider
      textProviderWithText:[formatter stringFromDate:date]];
  handler(template);
}

@end
