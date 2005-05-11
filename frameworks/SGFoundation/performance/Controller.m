#import "Controller.h"
#import "PTest.h"
#import "UTILKit.h"
#import <ObjcUnit/TestSuite.h>

#import "SGBaseObjectPTest.h"


static TestSuite *kSharedTestSuite;
static void InitSharedTestSuite(Class TestClass)
{
	[kSharedTestSuite release];
	kSharedTestSuite = [TestSuite suiteWithName : @"All Performance Tests"];
	[kSharedTestSuite addTest : [TestSuite suiteWithClass : TestClass]];
	[kSharedTestSuite retain];
}



@implementation Controller
- (void) awakeFromNib
{

}

+ (TestSuite *) suite
{
	return kSharedTestSuite;
}
- (IBAction) doSGBaseObjectSample : (id) sender;
{
	InitSharedTestSuite([SGBaseObjectPTest class]);
	TestRunnerMain([self class]);
}

- (NSWindow *) window
{
	return _window;
}
@end
