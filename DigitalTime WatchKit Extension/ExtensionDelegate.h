#import <WatchKit/WatchKit.h>

@interface ExtensionDelegate : NSObject <WKExtensionDelegate>

@property(nonatomic) int refreshCount;

@property(nonatomic) NSDate* lastTime;

- (void)scheduleBackgroundTask;

- (void)log:(NSString*)msg;

@end
