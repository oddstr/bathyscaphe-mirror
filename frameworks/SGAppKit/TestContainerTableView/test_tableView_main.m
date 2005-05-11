//:main.m
/**
  *
  * 
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/06/17  6:52:28 PM)
  *
  */

#define		CMRAPP_REQUIRE_APPKIT_VERSION	577.1

#import <Cocoa/Cocoa.h>

int main(int argc, const char *argv[])
{
	if(NSAppKitVersionNumber < CMRAPP_REQUIRE_APPKIT_VERSION){
		NSLog(@"Unsupported Version.");
		return -1;
	}
	return NSApplicationMain(argc, argv);
}
