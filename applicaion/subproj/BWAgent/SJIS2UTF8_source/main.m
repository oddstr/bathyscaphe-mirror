// SJIS2UTF8
#import <Foundation/Foundation.h>

int main () {
NSData *rawData;
NSString *str;
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
rawData = [[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile];
str = [[NSString alloc] initWithData:rawData encoding: NSShiftJISStringEncoding];
       if (str) {
               rawData = [str dataUsingEncoding: NSUTF8StringEncoding];
               [[NSFileHandle fileHandleWithStandardOutput] writeData: rawData ];
               [str release];
       }
[pool release];
}