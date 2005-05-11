//: NSTableColumn+CMXAdditions.m
/**
  * $Id: NSTableColumn+CMXAdditions.m,v 1.1.1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSTableColumn+CMXAdditions.h"
#import "UTILKit.h"



static NSString *const SGTableColumnRepIdentifierKey        = @"Identifier";
static NSString *const SGTableColumnRepTitleKey             = @"Title";
static NSString *const SGTableColumnRepWidthKey             = @"Width";
static NSString *const SGTableColumnRepMinWidthKey          = @"Min Width";
static NSString *const SGTableColumnRepMaxWidthKey          = @"Max Width";
static NSString *const SGTableColumnRepResizableKey         = @"Resizable";
static NSString *const SGTableColumnRepEditableKey          = @"Editable";
static NSString *const SGTableColumnRepTitleAlignmentKey    = @"Title Alignment";
static NSString *const SGTableColumnRepContentsAlignmentKey = @"Contents Alignment";


static NSTextAlignment objectValue2NSTextAlignment(id obj);


@implementation NSTableColumn(PropertyListRepresentation)
- (id) propertyListRepresentation
{
	if([(NSCell *)[self dataCell] type] != NSTextCellType) return nil;
	if([(NSCell *)[self headerCell] type] != NSTextCellType) return nil;
	return [NSDictionary dictionaryWithObjectsAndKeys :
					[[self headerCell] stringValue],
					SGTableColumnRepTitleKey,
					[self identifier] ? [self identifier] : @"",
					SGTableColumnRepIdentifierKey,
					[NSNumber numberWithFloat : [self width]],
					SGTableColumnRepWidthKey,
					[NSNumber numberWithFloat : [self minWidth]],
					SGTableColumnRepMinWidthKey,
					[NSNumber numberWithFloat : [self maxWidth]],
					SGTableColumnRepMaxWidthKey,
					[NSNumber numberWithBool : [self isResizable]],
					SGTableColumnRepResizableKey,
					[NSNumber numberWithBool : [self isEditable]],
					SGTableColumnRepEditableKey,
					[NSNumber numberWithUnsignedInt : [[self headerCell] alignment]],
					SGTableColumnRepTitleAlignmentKey,
					[NSNumber numberWithUnsignedInt : [[self dataCell] alignment]],
					SGTableColumnRepContentsAlignmentKey,
					nil];
}
- (id) initWithPropertyListRepresentation : (id) rep
{
	NSArray			*requireKeys_;
	NSEnumerator	*iter_;
	NSString		*key_;
	
	requireKeys_ = [NSArray arrayWithObjects :
			SGTableColumnRepIdentifierKey,
			SGTableColumnRepTitleKey,
			SGTableColumnRepWidthKey,
			SGTableColumnRepMinWidthKey,
			SGTableColumnRepMaxWidthKey,
			SGTableColumnRepResizableKey,
			SGTableColumnRepEditableKey,
			SGTableColumnRepTitleAlignmentKey,
			SGTableColumnRepContentsAlignmentKey,
			nil];
	iter_ = [requireKeys_ objectEnumerator];
	while(key_ = [iter_ nextObject]){
		if(nil == [rep objectForKey : key_]){
			[self release];
			return nil;
		}
	}
	
	if(self = [self initWithIdentifier : [rep objectForKey : SGTableColumnRepIdentifierKey]]){
		id		v = nil;
		
		[[self headerCell] setStringValue : [rep objectForKey : SGTableColumnRepTitleKey]];
		[self setWidth : [rep floatForKey : SGTableColumnRepWidthKey]];
		[self setMinWidth : [rep floatForKey : SGTableColumnRepMinWidthKey]];
		[self setMaxWidth : [rep floatForKey : SGTableColumnRepMaxWidthKey]];
		[self setResizable : [rep boolForKey : SGTableColumnRepResizableKey]];
		[self setEditable : [rep boolForKey : SGTableColumnRepEditableKey]];
		
		// Text/Contents Alignment
		v = [rep objectForKey:SGTableColumnRepTitleAlignmentKey];
		[[self headerCell] setAlignment : objectValue2NSTextAlignment(v)];
		v = [rep objectForKey:SGTableColumnRepContentsAlignmentKey];
		[[self dataCell] setAlignment : objectValue2NSTextAlignment(v)];
		
	}
	return self;
}
@end



static NSTextAlignment objectValue2NSTextAlignment(id obj)
{
	NSString	*keys[] = {
		@"NSLeftTextAlignment",
		@"NSRightTextAlignment",
		@"NSCenterTextAlignment",
		@"NSJustifiedTextAlignment",
		@"NSNaturalTextAlignment"
	};
	NSTextAlignment		values[] = {
		NSLeftTextAlignment,
		NSRightTextAlignment,
		NSCenterTextAlignment,
		NSJustifiedTextAlignment,
		NSNaturalTextAlignment,
	};
	
	int			i, cnt;
	
	if(nil == obj) return NSLeftTextAlignment;
	if([obj isKindOfClass : [NSNumber class]])
		return [obj intValue];
	
	if(NO == [obj isKindOfClass : [NSString class]])
		return NSLeftTextAlignment;
	
	cnt = UTILNumberOfCArray(keys);
	NSCAssert2(cnt == UTILNumberOfCArray(values),
				@"keys count(%u) mismatch values count(%u)",
				cnt, UTILNumberOfCArray(values));
	
	for(i = 0; i < cnt; i++){
		if(NSOrderedSame == [keys[i] caseInsensitiveCompare : obj]){
			return values[i];
		}
	}
	return NSLeftTextAlignment;
}