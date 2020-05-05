#import "ComplicationController.h"

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

- (void)getTimelineEndDateForComplication:(CLKComplication*)complication
                              withHandler:
                                  (void (^)(NSDate* __nullable date))handler {
  // Tell the system we are good for a day, even though we can't give back 1440
  // repeating timeline entries for eva.
  handler([[NSDate date] dateByAddingTimeInterval:86400]);
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
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"h:mm a"];
  NSDate* date = [NSDate date];
  CLKComplicationTemplateUtilitarianSmallFlat* template =
      [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
  template.textProvider = [CLKSimpleTextProvider
      textProviderWithText:[formatter stringFromDate:date]];
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
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"h:mm a"];

  // Round down to 58 second mark.  This is a little strange, but when the watch
  // is in 'always on'/'dimmed' the time always seems to be off by a minute. By
  // setting the timeline entry time down to 58 seconds and the formatted string
  // to the 'next' minute, we can try to get things in sync.
  NSInteger seconds =
      [[[NSCalendar currentCalendar] components:NSCalendarUnitSecond
                                       fromDate:date] second];
  seconds += 2;
  date = [date dateByAddingTimeInterval:-seconds];

  int count = limit < 60 ? limit : 60;
  // Load the next hour's worth of minutes, or limit's worth if it's less
  // then 60.
  NSMutableArray* array = [NSMutableArray arrayWithCapacity:60];
  for (int minute = 0; minute < count; minute++) {
    date = [date dateByAddingTimeInterval:60];
    CLKComplicationTemplateUtilitarianSmallFlat* template =
        [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];

    // Date here is set back to 58 seconds, so add 2 to format a string for the
    // current (next) minute.
    NSString* st = [formatter stringFromDate:[date dateByAddingTimeInterval:2]];
//    NSLog(@"setting %@ for %@", st, date);
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:st];
    [array addObject:[CLKComplicationTimelineEntry entryWithDate:date
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