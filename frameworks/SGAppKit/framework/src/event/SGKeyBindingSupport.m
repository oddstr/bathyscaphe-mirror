//: SGKeyBindingSupport.m
/**
  * $Id: SGKeyBindingSupport.m,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGKeyBindingSupport.h"
#import "SGAppKitFrameworkDefines.h"

#import <SGFoundation/SGFoundation.h>

// 辞書のキーになるときはこの順番の並びになる
#define kControlCharacter			@"^"
#define kCommandCharacter			@"@"
#define kAltCharacter				@"~"
#define kShiftCharacter				@"$"
#define kNumericKeypadCharacter		@"#"



static NSString *dictKeyCharacterWithCharacter(NSString *str);

@implementation SGKeyBindingSupport
+ (id) keyBindingSupportWithContentsOfFile : (NSString *) dictFilepath
{
	return [[[self alloc] initWithContentsOfFile : dictFilepath]  autorelease];
}
+ (id) keyBindingSupportWithDictionary : (NSDictionary *) dict
{
	return [[[self alloc] initWithDictionary : dict]  autorelease];
}

- (id) initWithContentsOfFile : (NSString *) dictFilepath
{
	return [self initWithDictionary : 
				[NSDictionary dictionaryWithContentsOfFile : dictFilepath]];
}
- (id) initWithDictionary : (NSDictionary *) dict
{
	if(self = [super init]){
		[self setKeyBindingDict : dict];
	}
	return self;
}

- (void) dealloc
{
	[_keyBindingDict release];
	[super dealloc];
}

- (NSDictionary *) keyBindingDict
{
	return _keyBindingDict;
}

+ (NSDictionary *) keybindingMacrosDictionary
{
	NSString	*filepath;
	
	filepath = [[NSBundle bundleForClass : self] pathForResource:@"SGKeybindingMacros" ofType:@"plist"];
	
	return [NSDictionary dictionaryWithContentsOfFile : filepath];
}

static void expandMacroWithBindingString(NSMutableString *src, NSString *macro, NSNumber *unicharRep)
{
	NSRange		range_ = [src range];
	unsigned	srcLength_ = [src length];
	NSString	*macroValue_ = nil;			// lazy instantiation
	
	if(nil == unicharRep) return;
	if(nil == src || 0 == srcLength_) return;
	if(nil == macro || [macro isEmpty]) return;
	
	while(1){
		NSRange		found;
		unichar		c;
		unsigned	maxRange_;
		
		found = [src rangeOfString:macro options:NSLiteralSearch range:range_];
		if(0 == found.length) break;
		
		// <...> 形式
		
		// prefix: 
		if(0 == found.location) break;
		c = [src characterAtIndex : found.location -1];
		if(c != '<') break;
		
		// suffix:
		maxRange_ = NSMaxRange(found);
		if(srcLength_ == maxRange_) break;
		c = [src characterAtIndex : maxRange_];
		if(c != '>') break;
		
		// 置換範囲を<...>に拡大
		found.location--;
		found.length += 2;
		
		if(nil == macroValue_){
			c = [unicharRep unsignedIntValue];
			macroValue_ = [[NSString alloc] initWithCharacters:&c length:1];
		}
		
		[src replaceCharactersInRange:found withString:macroValue_];
		
		srcLength_ = [src length];
		range_.location = found.location + [macroValue_ length];
		if(srcLength_ == range_.location) break;
		
		range_.length = srcLength_ - range_.location;
	}
	[macroValue_ release];
}
+ (NSDictionary *) convertKeyBindingDictionary : (NSDictionary *) dict
{
	NSDictionary		*macros_;
	NSMutableString		*tmpKey_;
	
	NSMutableDictionary	*dict_;
	NSEnumerator		*iter_;
	NSString			*key_;
	
	if(nil == dict)
		return nil;
	
	macros_ = [self keybindingMacrosDictionary];
	tmpKey_ = [NSMutableString string];
	
	dict_ = [NSMutableDictionary dictionary];
	iter_ = [dict keyEnumerator];
	
	while(key_ = [iter_ nextObject]){
		NSString	*bindingKey_;
		id			value_;
		
		// マクロ展開
		NSEnumerator		*macroKeyIter_;
		NSString			*macroKey_;
		
		[tmpKey_ setString : key_];
		macroKeyIter_ = [macros_ keyEnumerator];
		while(macroKey_ = [macroKeyIter_ nextObject]){
			id	macroValue_;
			
			macroValue_ = [macros_ objectForKey : macroKey_];
			UTILAssertKindOfClass(macroValue_, NSNumber);
			
			expandMacroWithBindingString(
				tmpKey_,
				macroKey_,
				macroValue_);
		}
		
		bindingKey_ = [self keyBindingStringWithKey : tmpKey_];
		if(nil == bindingKey_)
			continue;
		
		value_ = [dict objectForKey : key_];
		if([value_ isKindOfClass : [NSDictionary class]])
			value_ = [self convertKeyBindingDictionary : value_];
		
		[dict_ setObject:value_ forKey:bindingKey_];
	}
	
	return [[dict_ copy] autorelease];
}

- (void) setKeyBindingDict : (NSDictionary *) dict
{
	id		tmp;
	
	if(_keyBindingDict == dict)
		return;
	
	tmp = _keyBindingDict;
	_keyBindingDict = [[self class] convertKeyBindingDictionary : dict];
	[_keyBindingDict retain];
	[tmp release];
}

- (SEL) selecterFromkeyBindingString : (NSString *) str
{
	NSString	*SELStr;
	
	if(nil == str) return NULL;
	SELStr = [[self keyBindingDict] stringForKey : str];
	if(SELStr != nil) return NSSelectorFromString(SELStr);
	
	// Numeric Keypad Maskが含まれていて、辞書から見つからなければ、
	// それを削除して検索
	if(str && [str length] >= 2 && [str containsString : kNumericKeypadCharacter]){
		str = [str stringByReplaceCharacters:kNumericKeypadCharacter toString:@""];
		return [self selecterFromkeyBindingString: str];
	}
	return NULL;
}


- (BOOL) interpretKeyBindingWithEvent : (NSEvent *) theEvent
							   target : (id       ) theTarget
{
	NSString	*keyBinding_ = nil;
	SEL			selector_    = NULL;
	
	UTILAssertKindOfClass(theEvent, NSEvent);
	keyBinding_ = [[self class] keyBindingStringWithEvent : theEvent];
	selector_ = [self selecterFromkeyBindingString : keyBinding_];
	if(NULL == selector_) return NO;
	
	[theTarget doCommandBySelector:selector_];
	return YES;
}
- (BOOL) interpretKeyBindings : (NSArray *) eventArray
					   target : (id       ) theTarget;
{
	NSEnumerator	*iter_;
	NSEvent			*event_;
	BOOL			isInterpreted_ = NO;
	
	iter_ = [eventArray objectEnumerator];
	while(event_ = [iter_ nextObject]){
		if(nil == [self interpretKeyBindingWithEvent:event_ target:theTarget])
			continue;
		
		isInterpreted_ = YES;
	}
	return isInterpreted_;
}

@end



@implementation SGKeyBindingSupport(Convert)
+ (unsigned) keyModifierMaskWithString : (NSString *) str
{
	if([kControlCharacter isEqualToString : str])
		return NSControlKeyMask;
	if([kCommandCharacter isEqualToString : str])
		return NSCommandKeyMask;
	if([kAltCharacter isEqualToString : str])
		return NSAlternateKeyMask;
	if([kShiftCharacter isEqualToString : str])
		return NSShiftKeyMask;
	if([kNumericKeypadCharacter isEqualToString : str])
		return NSNumericPadKeyMask;
	
	return 0;
}
+ (unsigned) modifierFlagsWithKeyBindingString : (NSString *) str
{
	NSArray			*ucElems_;
	NSEnumerator	*iter_;
	NSString		*text_;
	
	unsigned		modifierFlags_;
	
	modifierFlags_ = 0;
	
	ucElems_ = [str componentsSeparatedByTextBreak];
	iter_ = [ucElems_ objectEnumerator];
	
	while(text_ = [iter_ nextObject]){
		unsigned	mask_;
		
		mask_ = [self keyModifierMaskWithString : text_];
		
		if(0 == mask_){
			// メタ文字以外は無視
			continue;
		}
		modifierFlags_ = (modifierFlags_ | mask_);
	}
	
	return modifierFlags_;
}
/* dictionary Key Normalize */
+ (NSString *) keyBindingStringWithKey : (NSString *) aKey
{
	NSArray			*ucElems_;
	NSEnumerator	*iter_;
	NSString		*text_;
	
	NSString		*character_;
	unsigned		modifierFlags_;
	
	modifierFlags_ = 0;
	
	ucElems_ = [aKey componentsSeparatedByTextBreak];
	iter_ = [ucElems_ reverseObjectEnumerator];
	
	// まず、キー入力のcharacterを読み、
	// それからmodifierFlags
	character_ = [iter_ nextObject];
	if(nil == character_)
		return nil;
	
	while(text_ = [iter_ nextObject]){
		unsigned	mask_;
		
		mask_ = [self keyModifierMaskWithString : text_];
		
		if(0 == mask_){
			// メタ文字以外は無視
			continue;
		}
		modifierFlags_ = (modifierFlags_ | mask_);
	}
	
	return [self keyBindingStringWithCharacters : character_
								  modifierFlags : modifierFlags_];
}

+ (NSString *) keyBindingStringWithEvent : (NSEvent *) anEvent
{
	NSString		*character_;
	
	UTILRequireCondition(anEvent, ErrConvertString);
	UTILRequireCondition(NSKeyDown == [anEvent type], ErrConvertString);
	
	character_ = [anEvent charactersIgnoringModifiers];
	UTILRequireCondition(character_ && [character_ length], ErrConvertString);
	
	return [self keyBindingStringWithCharacters : character_
					modifierFlags : [anEvent modifierFlags]];
	
	ErrConvertString:
		return nil;
}
+ (NSString *) keyBindingStringWithModifierFlags : (unsigned) flags
{
	NSMutableString		*string_;
	
	string_ = [NSMutableString string];
	
	if(NSControlKeyMask	& flags)
		[string_ appendString : kControlCharacter];
	if(NSCommandKeyMask & flags)
		[string_ appendString : kCommandCharacter];
	if(NSAlternateKeyMask & flags)
		[string_ appendString : kAltCharacter];
	if(NSShiftKeyMask & flags)
		[string_ appendString : kShiftCharacter];
	if(NSNumericPadKeyMask & flags)
		[string_ appendString : kNumericKeypadCharacter];
	
	return string_;
}
+ (NSString *) keyBindingStringWithCharacters : (NSString *) characters
								modifierFlags : (unsigned  ) modifierFlags
{
	NSString		*keyBindingString_;
	NSString		*characters_;
	
	if(nil == characters)
		return nil;
	
	keyBindingString_ = 
		[self keyBindingStringWithModifierFlags : modifierFlags];
	
	characters_ = dictKeyCharacterWithCharacter(characters);
	keyBindingString_ = [keyBindingString_ stringByAppendingString : characters_];
	
	return keyBindingString_;
}
@end



static NSString *dictKeyCharacterWithCharacter(NSString *str)
{
	// 小文字で統一してしまう
	return [str lowercaseString];
}