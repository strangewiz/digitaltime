#import "InterfaceController.h"

@interface InterfaceController ()

@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
}

- (void)willActivate {
  [super willActivate];
  id server = [CLKComplicationServer sharedInstance];
  for (id complication in [server activeComplications]) {
    [server reloadTimelineForComplication:complication];
  }
}

- (void)didDeactivate {
  [super didDeactivate];
}

@end
