//:SGLinkCommand.h
#import <Cocoa/Cocoa.h>
#import "SGFunctor.h"



@interface SGLinkCommand : SGFunctor
- (id) link;
- (NSURL *) URLValue;
- (NSString *) stringValue;
@end



@interface SGCopyLinkCommand : SGLinkCommand
@end



@interface SGOpenLinkCommand : SGLinkCommand
@end