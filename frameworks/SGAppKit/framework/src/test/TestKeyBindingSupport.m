//: TestKeyBindingSupport.m
/**
  * $Id: TestKeyBindingSupport.m,v 1.1.1.1 2005/05/11 17:51:27 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "TestKeyBindingSupport.h"


@implementation TestKeyBindingSupport
- (void) setUp
{
	;
}
- (void) tearDown
{
	;
}


- (void) test_keyBindingStringWithCharacters
{
	SGKeyBindingSupport		*support_;
	NSString				*keyBinding_;
	
	support_ = [[SGKeyBindingSupport alloc] init];
	[self assertNotNil:support_ message:@"instance"];
	
	keyBinding_ = [[support_ class]
			keyBindingStringWithCharacters : @"s"
			modifierFlags : NSControlKeyMask];
	
	[self assertString:keyBinding_ equals:@"^s"];
	
	keyBinding_ = [[support_ class]
			keyBindingStringWithCharacters : @"s"
			modifierFlags : (unsigned)~0];
	
	[self assertString:keyBinding_ equals:@"^@~$#s"];
}
- (void) test_keyBindingStringWithCharacters_upper
{
	SGKeyBindingSupport		*support_;
	NSString				*keyBinding_;
	
	support_ = [[SGKeyBindingSupport alloc] init];
	keyBinding_ = [[support_ class]
			keyBindingStringWithCharacters : @"S"
			modifierFlags : NSControlKeyMask];
	
	[self assertString:keyBinding_ equals:@"^s"];
	
	keyBinding_ = [[support_ class]
			keyBindingStringWithCharacters : @"S"
			modifierFlags : (unsigned)~0];
	
	[self assertString:keyBinding_ equals:@"^@~$#s"];
}

- (void) test_duplicate
{
	SGKeyBindingSupport		*support_;
	NSString				*keyBinding_;
	
	support_ = [[SGKeyBindingSupport alloc] init];
	
	keyBinding_ = [[support_ class]
			keyBindingStringWithCharacters : @"^"
			modifierFlags : NSControlKeyMask];
	
	[self assertString:keyBinding_ equals:@"^^"];
	
	keyBinding_ = [[support_ class]
			keyBindingStringWithKey : @"^^"];
	[self assertString:keyBinding_ equals:@"^^"];
	
}

- (void) test_keyBindingStringWithKey
{
	SGKeyBindingSupport		*support_;
	NSString				*keyBinding_;
	
	support_ = [[SGKeyBindingSupport alloc] init];
	
	keyBinding_ = [[support_ class]
			keyBindingStringWithKey : @"^s"];
	[self assertString:keyBinding_ equals:@"^s"];
	
	keyBinding_ = [[support_ class]
			keyBindingStringWithKey : @"~^#$s"];
	[self assertString : keyBinding_
			equals : @"^~$#s"
			message : @"003"];
}

- (void) test_keyBindingDict
{
	SGKeyBindingSupport	*support_;
	NSDictionary		*dict_;
	NSDictionary		*expect_;
	
	dict_ = [NSDictionary dictionaryWithObjectsAndKeys :
				@"foo:",	@"~^#$s",
				@"bar",		@"^S",
				nil];
	expect_ = [NSDictionary dictionaryWithObjectsAndKeys :
				@"foo:",	@"^~$#s",
				@"bar",		@"^s",
				nil];
	support_ = [[SGKeyBindingSupport alloc] initWithDictionary : dict_];
	[self assert : [support_ keyBindingDict]
		equals : expect_];
}
- (void) test_keyBindingDict2
{
	SGKeyBindingSupport	*support_;
	NSDictionary		*dict_;
	NSDictionary		*expect_;
	
	dict_ = [NSDictionary dictionaryWithObjectsAndKeys :
				@"foo:",	@"~^#$s",
				@"bar",		@"^S",
					[NSDictionary dictionaryWithObjectsAndKeys : 
					@"foo:",	@"~^#$s",
					@"bar",		@"^S",
					nil],
					@"^^",
				nil];
	expect_ = [NSDictionary dictionaryWithObjectsAndKeys :
				@"foo:",	@"^~$#s",
				@"bar",		@"^s",
					[NSDictionary dictionaryWithObjectsAndKeys : 
					@"foo:",	@"^~$#s",
					@"bar",		@"^s",
					nil],
					@"^^",
				nil];
	support_ = [[SGKeyBindingSupport alloc] initWithDictionary : dict_];
	[self assert : [support_ keyBindingDict]
		equals : expect_];
}
@end
