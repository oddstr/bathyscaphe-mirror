//
//  NSTableColumn+CMXAdditions.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/10/10.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "NSTableColumn+CMXAdditions.h"
#import "UTILKit.h"


static NSString *const SGTableColumnRepIdentifierKey        = @"Identifier";
static NSString *const SGTableColumnRepTitleKey             = @"Title";
static NSString *const SGTableColumnRepWidthKey             = @"Width";
static NSString *const SGTableColumnRepMinWidthKey          = @"Min Width";
static NSString *const SGTableColumnRepMaxWidthKey          = @"Max Width";
//static NSString *const SGTableColumnRepResizableKey         = @"Resizable"; // Deprecated.
static NSString *const SGTableColumnRepResizingMaskKey		= @"ResizingMask"; // Available in BathyScaphe 1.6.2 and later.
static NSString *const SGTableColumnRepEditableKey          = @"Editable";
static NSString *const SGTableColumnRepTitleAlignmentKey    = @"Title Alignment";
static NSString *const SGTableColumnRepContentsAlignmentKey = @"Contents Alignment";

// Available in BathyScaphe 1.6.2 and later.
static NSString *const SGTableColumnRepSortDescProtoTypeKey = @"SortDescriptor Prototype";
static NSString *const SGTCRepSortDescProtoTypeKeyPathKey = @"keypath";
static NSString *const SGTCRepSortDescProtoTypeAscendingKey = @"ascending";
static NSString *const SGTCRepSortDescProtoTypeSelectorKey = @"selector";

static NSTextAlignment objectValue2NSTextAlignment(id obj);


@implementation NSTableColumn(PropertyListRepresentation)
- (id)propertyListRepresentation
{
	if([(NSCell *)[self dataCell] type] != NSTextCellType) return nil;
	if([(NSCell *)[self headerCell] type] != NSTextCellType) return nil;
	NSSortDescriptor *descriptor = [self sortDescriptorPrototype];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];

	if (descriptor) {
		NSString *selectorStr = NSStringFromSelector([descriptor selector]);
		NSNumber *boolNum = [NSNumber numberWithBool:[descriptor ascending]];
		NSString *keyPathStr = [descriptor key];
		NSDictionary *descDict = [NSDictionary dictionaryWithObjectsAndKeys:
				keyPathStr, SGTCRepSortDescProtoTypeKeyPathKey,
				boolNum, SGTCRepSortDescProtoTypeAscendingKey,
				selectorStr, SGTCRepSortDescProtoTypeSelectorKey,
				NULL];
		[dict setObject:descDict forKey:SGTableColumnRepSortDescProtoTypeKey];
	}

	[dict setObject:[[self headerCell] stringValue] forKey:SGTableColumnRepTitleKey];
	[dict setObject:[self identifier] forKey:SGTableColumnRepIdentifierKey];
	[dict setObject:[NSNumber numberWithFloat:[self width]] forKey:SGTableColumnRepWidthKey];
	[dict setObject:[NSNumber numberWithFloat:[self minWidth]] forKey:SGTableColumnRepMinWidthKey];
	[dict setObject:[NSNumber numberWithFloat:[self maxWidth]] forKey:SGTableColumnRepMaxWidthKey];
	[dict setObject:[NSNumber numberWithUnsignedInt:[self resizingMask]] forKey:SGTableColumnRepResizingMaskKey];
	[dict setObject:[NSNumber numberWithBool:[self isEditable]] forKey:SGTableColumnRepEditableKey];
	[dict setObject:[NSNumber numberWithUnsignedInt:[[self headerCell] alignment]] forKey:SGTableColumnRepTitleAlignmentKey];
	[dict setObject:[NSNumber numberWithUnsignedInt:[[self dataCell] alignment]] forKey:SGTableColumnRepContentsAlignmentKey];

	return [NSDictionary dictionaryWithDictionary:dict];
}

- (id)initWithPropertyListRepresentation:(id)rep
{
	NSArray			*requireKeys_;
	NSEnumerator	*iter_;
	NSString		*key_;
	
	requireKeys_ = [NSArray arrayWithObjects:
			SGTableColumnRepIdentifierKey,
			SGTableColumnRepTitleKey,
			SGTableColumnRepWidthKey,
			SGTableColumnRepMinWidthKey,
			SGTableColumnRepMaxWidthKey,
//			SGTableColumnRepResizableKey,
			SGTableColumnRepResizingMaskKey,
			SGTableColumnRepEditableKey,
			SGTableColumnRepTitleAlignmentKey,
			SGTableColumnRepContentsAlignmentKey,
			nil];
	iter_ = [requireKeys_ objectEnumerator];
	while (key_ = [iter_ nextObject]) {
		if (![rep objectForKey:key_]) {
			[self release];
			return nil;
		}
	}
	
	if (self = [self initWithIdentifier:[rep objectForKey:SGTableColumnRepIdentifierKey]]) {
		id		v = nil;
		
		[[self headerCell] setStringValue:[rep objectForKey:SGTableColumnRepTitleKey]];
		[self setWidth:[rep floatForKey:SGTableColumnRepWidthKey]];
		[self setMinWidth:[rep floatForKey:SGTableColumnRepMinWidthKey]];
		[self setMaxWidth:[rep floatForKey:SGTableColumnRepMaxWidthKey]];
		[self setResizingMask:[rep unsignedIntForKey:SGTableColumnRepResizingMaskKey]];
		[self setEditable:[rep boolForKey:SGTableColumnRepEditableKey]];
		
		// Text/Contents Alignment
		v = [rep objectForKey:SGTableColumnRepTitleAlignmentKey];
		[[self headerCell] setAlignment:objectValue2NSTextAlignment(v)];
		v = [rep objectForKey:SGTableColumnRepContentsAlignmentKey];
		[[self dataCell] setAlignment:objectValue2NSTextAlignment(v)];

		// SortDescriptor Prototype
		v = [rep objectForKey:SGTableColumnRepSortDescProtoTypeKey];
		if (v) {
			NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:[[v objectForKey:SGTCRepSortDescProtoTypeKeyPathKey] lowercaseString]
											ascending:[v boolForKey:SGTCRepSortDescProtoTypeAscendingKey]
											 selector:NSSelectorFromString([v objectForKey:SGTCRepSortDescProtoTypeSelectorKey])];
			[self setSortDescriptorPrototype:desc];
			[desc release];
		}
	}
	return self;
}
@end



static NSTextAlignment objectValue2NSTextAlignment(id obj)
{
	NSString *keys[] = {
		@"NSLeftTextAlignment",
		@"NSRightTextAlignment",
		@"NSCenterTextAlignment",
		@"NSJustifiedTextAlignment",
		@"NSNaturalTextAlignment"
	};
	NSTextAlignment values[] = {
		NSLeftTextAlignment,
		NSRightTextAlignment,
		NSCenterTextAlignment,
		NSJustifiedTextAlignment,
		NSNaturalTextAlignment,
	};
	
	int			i, cnt;
	
	if (!obj) {
		return NSLeftTextAlignment;
	}

	if ([obj isKindOfClass:[NSNumber class]]) {
		return [obj intValue];
	}

	if (![obj isKindOfClass:[NSString class]]) {
		return NSLeftTextAlignment;
	}

	cnt = UTILNumberOfCArray(keys);
	NSCAssert2(cnt == UTILNumberOfCArray(values),
				@"keys count(%u) mismatch values count(%u)",
				cnt, UTILNumberOfCArray(values));
	
	for (i = 0; i < cnt; i++) {
		if (NSOrderedSame == [keys[i] caseInsensitiveCompare:obj]) {
			return values[i];
		}
	}
	return NSLeftTextAlignment;
}
