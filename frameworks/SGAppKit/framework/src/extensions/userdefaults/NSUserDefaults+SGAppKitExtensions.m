//: NSUserDefaults+SGAppKitExtensions.m
/**
  * $Id: NSUserDefaults+SGAppKitExtensions.m,v 1.1.1.1.8.1 2006/11/11 19:03:08 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "NSUserDefaults+SGAppKitExtensions.h"
#import "SGAppKitFrameworkDefines.h"

#import <SGAppKit/NSUserDefaults+SGAppKitExtensions.h>
#import <SGAppKit/NSColor-SGExtensions.h>



static NSColor *ColorForKeyImp(id me, id aKey)
{
	id		archived_	= nil;
	NSColor	*color_		= nil;
	
	UTILRequireCondition(aKey, ErrConvertion);
	archived_ = [me objectForKey : aKey];
	UTILRequireCondition(archived_, ErrConvertion);
	
	if([archived_ isKindOfClass : [NSData class]]){
		color_ = [NSUnarchiver unarchiveObjectWithData : archived_];
	}/*else if([archived_ isKindOfClass : [NSString class]]){
		color_ = SGColorFromString(archived_);
	}*/
	UTILRequireCondition(color_, ErrConvertion);
	UTILRequireCondition(
		[color_ isKindOfClass : [NSColor class]], ErrConvertion);
	
	return color_;
	
ErrConvertion:
	return nil;
}
/*
static void SetColorForKeyImp(id me, NSColor *aValue, id aKey)
{
	id		object_;
	
	if(nil == aValue || nil == aKey)
		return;
	
	object_ = SGStringFromColor(aValue);
	[me setObject:object_ forKey:aKey];
}
*/
enum {
	FRWK_NSUSERDEFAULTS_FONTNAME_INDEX = 0,
	FRWK_NSUSERDEFAULTS_FONTSIZE_INDEX,
	FRWK_NSUSERDEFAULTS_ARRAY_LENGTH
};
static NSFont *FontForKeyImp(id me, id aKey)
{
	NSString		*fname;
	NSNumber		*fsize;
	NSArray			*farray;
	
	UTILRequireCondition(aKey, ErrConvertion);
	farray = [me objectForKey : aKey];
	UTILRequireCondition(farray, ErrConvertion);
	UTILRequireCondition(
		[farray isKindOfClass : [NSArray class]], ErrConvertion);
	UTILRequireCondition(
		(FRWK_NSUSERDEFAULTS_ARRAY_LENGTH == [farray count]),
		ErrConvertion);
	
	fname = [farray objectAtIndex : FRWK_NSUSERDEFAULTS_FONTNAME_INDEX];
	fsize = [farray objectAtIndex : FRWK_NSUSERDEFAULTS_FONTSIZE_INDEX];
	UTILRequireCondition(
		[fname isKindOfClass : [NSString class]], ErrConvertion);
	UTILRequireCondition(
		[fsize respondsToSelector : @selector(floatValue)], ErrConvertion);
	
	return [NSFont fontWithName:fname size:[fsize floatValue]];
	
ErrConvertion:
	return nil;
}
static void SetFontForKeyImp(id me, NSFont *aValue, id aKey)
{
	NSString	*fname;		// フォントの名前
	NSNumber	*fsize;		// フォントサイズ(ポイント)
	NSArray		*farray;		// 登録する配列オブジェクト
	
	if(nil == aValue || nil == aKey)
		return;
	
	// 作成した配列オブジェクトにフォント名、サイズを格納し、
	// 初期設定に保存。あとで決められたインデックスから取り出すことで復元。
	fname = [aValue fontName];
	fsize = [NSNumber numberWithFloat : [aValue pointSize]];
	farray = [NSArray arrayWithObjects : fname, fsize, nil];
	
	[me setObject:farray forKey:aKey];
}

@implementation NSUserDefaults(SGAppKitExtensions)
- (NSColor *) colorForKey : (NSString *) key
{
	return ColorForKeyImp(self, key);
}
- (NSFont *) fontForKey : (NSString *) key
{
	return FontForKeyImp(self, key);
}
- (void) setColor : (NSColor  *) color
           forKey : (NSString *) key
{
	NSData *theData=[NSArchiver archivedDataWithRootObject: color];
    [self setObject: theData forKey: key];
}
- (void) setFont : (NSFont   *) aFont
          forKey : (NSString *) key
{
	SetFontForKeyImp(self, aFont, key);
}
@end



@implementation NSDictionary(SGAppKitExtensions)
- (NSColor *) colorForKey : (id) key
{
	return ColorForKeyImp(self, key);
}
- (NSFont *) fontForKey : (id) key
{
	return FontForKeyImp(self, key);
}
@end



@implementation NSMutableDictionary(SGAppKitExtensions)
- (void) setColor : (NSColor *) color
           forKey : (id       ) key
{
	//SetColorForKeyImp(self, color, key);
	NSData *theData=[NSArchiver archivedDataWithRootObject:color];
    [self setObject:theData forKey:key];
}
- (void) setFont : (NSFont *) aFont
          forKey : (id      ) key
{
	SetFontForKeyImp(self, aFont, key);
}
@end
