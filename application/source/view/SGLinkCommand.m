//:SGLinkCommand.m
#import "SGLinkCommand.h"
#import "CocoMonar_Prefix.h"
#import <SGAppKit/NSWorkspace-SGExtensions.h>
#import "AppDefaults.h"


@implementation SGLinkCommand : SGFunctor
- (id) link
{
	id		obj_;
	
	obj_ = [self objectValue];
	UTILAssertNotNil(obj_);
	
	return obj_;
}
- (NSURL *) URLValue
{
	if([[self link] isKindOfClass : [NSURL class]]) return [self link];
	return [NSURL URLWithString : [self stringValue]];
}
- (NSString *) stringValue
{
	return [[self link] respondsToSelector : @selector(absoluteString)]
				? [[self link] absoluteString]
				: [[self link] description];
}
@end



@implementation SGCopyLinkCommand : SGLinkCommand
- (void) execute : (id) sender
{
	NSPasteboard	*pboard_;
	NSArray			*types_;
	
	pboard_ = [NSPasteboard generalPasteboard];
	if(nil == pboard_) return;
	types_ = [NSArray arrayWithObjects : 
				NSURLPboardType,
				NSStringPboardType,
				nil];
	
	[pboard_ declareTypes:types_ owner:nil];
	
	
	[[self URLValue] writeToPasteboard : pboard_];
	[pboard_ setString:[self stringValue] forType:NSStringPboardType];
}
@end



@implementation SGOpenLinkCommand : SGLinkCommand
- (void) execute : (id) sender
{
	[[NSWorkspace sharedWorkspace] openURL : [self URLValue] inBackGround : [CMRPref openInBg]];
}
@end

@implementation SGPreviewLinkCommand : SGLinkCommand
- (void) execute : (id) sender
{
	[[CMRPref sharedImagePreviewer] showImageWithURL : [self URLValue]];
}
@end