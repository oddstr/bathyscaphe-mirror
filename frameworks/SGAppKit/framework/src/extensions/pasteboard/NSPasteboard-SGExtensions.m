//: NSPasteboard-SGExtensions.m
/**
  * $Id: NSPasteboard-SGExtensions.m,v 1.1 2005/05/11 17:51:27 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSPasteboard-SGExtensions.h"
#import "SGAppKitFrameworkDefines.h"

@implementation NSPasteboard(SGExtensionsObjectValue)
- (id) unarchivedObjectForType : (NSString *) dataType
{
	NSData *data_;
	
	data_ = [self dataForType : dataType];
	return (data_ != nil) ? [NSUnarchiver unarchiveObjectWithData : data_] : nil;
}
- (BOOL) setObjectByArchived : (id		  ) obj
					 forType : (NSString *) dataType
{
	return [self setData : [NSArchiver archivedDataWithRootObject : obj]
				 forType : dataType];
}
- (void *) pointerForType : (NSString *) dataType;
{
	NSData *data_;
	
	data_ = [self dataForType : dataType];
	return (data_ != nil) 
				? (*((void **)[[self dataForType : dataType] bytes])) 
				: NULL;
}
- (BOOL) setPointer : (const void *) aPointer
			forType : (NSString   *) dataType;
{
	return [self setData : [NSData dataWithBytes:&aPointer length:sizeof(void *)] 
				 forType : dataType];
}
@end



@implementation NSAttributedString(CMXAdditions)
- (void) writeToPasteboard : (NSPasteboard *) pboard
{
	BOOL		succeed_;
#if PATCH
	NSData * data_t;
#endif

#if PATCH & DEBUG_LOG
		NSLog(@"writeToPasteboard: %@", pboard);
#endif
	
#if 0 // debug
		{
			NSString *t_str;
			t_str = [self string];
			NSLog (@"%d, %d", [t_str length], [[t_str componentsSeparatedByString: @"Å_n"] count]);
		}
#endif


	// Text
#if 1
	succeed_ = [pboard setString:[self string] forType:NSStringPboardType];
	UTILRequireCondition(succeed_, ErrNotWritable);
	
#if DEBUG_LOG
	NSLog(@"pboard NSStringPboardType: %d", succeed_);
#endif
#endif
	
	// RTF
#if 1
#if 1
	{
#if 1
		NSMutableAttributedString * str_attr = [[NSTextStorage alloc] initWithAttributedString: self];
#else
		NSMutableAttributedString * str_attr = self;
#endif
#if 1
// êFçÌèú
		[str_attr removeAttribute: NSForegroundColorAttributeName range: NSMakeRange(0, [str_attr length])];
#else
// êFÇí«â¡
		{ 
			NSDictionary *dic;
			
			dic = [[NSDictionary alloc] init];
			[dic setObject: [NSColor blackColor] forKey: NSForegroundColorAttributeName];
			[str_attr addAttributes: dic range: NSMakeRange(0, [str_attr length])];
		}
#endif

#if 0
		[str_attr fixParagraphStyleAttributeInRange: NSMakeRange(0, [self length])];
		[str_attr fixAttachmentAttributeInRange: NSMakeRange(0, [self length])];
		[str_attr fixFontAttributeInRange: NSMakeRange(0, [self length])];
		[str_attr fixAttributesInRange: NSMakeRange(0, [self length])];
#endif
		
#if 1
		data_t = [str_attr RTFFromRange: NSMakeRange(0, [str_attr length]) documentAttributes: nil];
#else
		data_t = [str_attr RTFFromRange: NSMakeRange(0, [str_attr length]) documentAttributes: [NSDictionary dictionaryWithObjectsAndKeys: NSRTFTextDocumentType, @"DocumentType", nil]];
#endif
		[str_attr release];
	}
	succeed_ = [pboard setData : data_t
					   forType : NSRTFPboardType];

#else
	succeed_ = [pboard setData : 
				[self RTFFromRange : NSMakeRange(0, [self length])
					documentAttributes : nil] 
					 forType : NSRTFPboardType];
#endif
	UTILRequireCondition(succeed_, ErrNotWritable);
	
#if DEBUG_LOG
	NSLog(@"pboard NSRTFPboardType: %d", succeed_);
#endif

#endif	

#if 0
	// RTFD
	succeed_ = [pboard setData : 
				[self RTFDFromRange : NSMakeRange(0, [self length])
					documentAttributes : nil]
					 forType : NSRTFDPboardType];
	UTILRequireCondition(succeed_, ErrNotWritable);

#if DEBUG_LOG
	NSLog(@"pboard NSRTFDPboardType: %d", succeed_);
#endif
#endif

ErrNotWritable:
	return;
}
@end

