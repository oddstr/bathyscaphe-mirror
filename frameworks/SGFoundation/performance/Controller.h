/* Controller */

#import <Cocoa/Cocoa.h>

@interface Controller : NSObject
{
	IBOutlet NSWindow		*_window;
}
- (IBAction) doSGBaseObjectSample : (id) sender;

- (NSWindow *) window;
@end
