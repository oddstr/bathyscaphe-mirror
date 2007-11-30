/**
  * $Id: SGTemplatesManager.m,v 1.2 2007/11/30 01:33:12 tsawada2 Exp $
  * 
  * SGTemplatesManager.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "SGTemplatesManager.h"
#import "UTILKit.h"
#import <SGFoundation/SGFoundationAdditions.h>
#import <SGFoundation/SGFile+AppSupport.h>
#import <SGFoundation/NSBundle-SGExtensions.h>



#define kSGATIdentifierBracket		@"%%%"


@interface SGTemplatesManager(Private)
- (NSMutableDictionary *) resourcesTable;

- (NSString *) pathForAttrResource : (NSString *) name
					    fromBundle : (NSBundle *) bundle;
// rtf/rtfd
- (SGBaseRangeArray *) identifierRangesWithString : (NSString *) str;
- (void) addATRResourcesFromContentsOfFile : (NSString *) filepath;
- (void) addPlistResourcesFromContentsOfFile : (NSString *) filepath;
@end



@implementation SGTemplatesManager(Private)
- (NSMutableDictionary *) resourcesTable
{
	if(nil == _resources)
		_resources = [[NSMutableDictionary alloc] init];
	
	return _resources;
}

- (NSString *) pathForAttrResource : (NSString *) name
					    fromBundle : (NSBundle *) bundle
{
	NSString		*filepath_;
	
	filepath_ = [bundle pathForResource:name ofType:@"rtf"];
	if(nil == filepath_)
		filepath_ = [bundle pathForResource:name ofType:@"rtfd"];
	
	return filepath_;
}
- (SGBaseRangeArray *) identifierRangesWithString : (NSString *) str
{
	SGBaseRangeArray	*ranges_ = [SGBaseRangeArray array];
	NSScanner			*scanner_;
	BOOL				scanResult_;
	
	UTILRequireCondition(str != nil, ReturnRanges);
	
	scanner_ = [NSScanner scannerWithString : str];
	
	
	while(1){
		NSRange			mRange_;
		
		[scanner_ scanUpToString:kSGATIdentifierBracket intoString:NULL];
		[scanner_ scanString:kSGATIdentifierBracket intoString:NULL];
		mRange_.location = [scanner_ scanLocation];
		scanResult_ = [scanner_ scanUpToString:kSGATIdentifierBracket intoString:NULL];
		mRange_.length = [scanner_ scanLocation] - mRange_.location;
		[scanner_ scanString:kSGATIdentifierBracket intoString:NULL];
		
		if(NO == scanResult_)
			break;
		
		[ranges_ append : mRange_];
	}
	
ReturnRanges:
	return ranges_;
}

- (void) addATRResourcesFromContentsOfFile : (NSString *) filepath
{
	NSAttributedString		*atStr_;
	SGBaseRangeArray		*ranges_;
	SGBaseRangeEnumerator	*enumerator_;
	NSRange					idRnage_;
	NSMutableDictionary		*mdict_;
	
	atStr_ = [[NSAttributedString alloc] initWithPath : filepath
								   documentAttributes : NULL];
	UTILAssertNotNil(atStr_);
	
	mdict_ = [self resourcesTable];
	ranges_ = [self identifierRangesWithString : [atStr_ string]];
	enumerator_ = [ranges_ enumerator];
	while([enumerator_ hasNext]){
		id			substr;
		
		idRnage_ = [enumerator_ next];
		NSAssert(NSMaxRange(idRnage_) <= [atStr_ length], @"Bad Access");
		
		substr = [atStr_ attributedSubstringFromRange : idRnage_];
		substr = [substr mutableCopyWithZone : nil];
		
		[mdict_ setObject:substr forKey:[substr string]];
		
		// 中身は必要ない
		[[substr mutableString] setString : @" "];
		[substr fixAttachmentAttributeInRange : NSMakeRange(0, [@" " length])];
	}
}
- (void) addPlistResourcesFromContentsOfFile : (NSString *) filepath
{
	NSDictionary		*contents_;
	
	contents_ = [NSDictionary dictionaryWithContentsOfFile : filepath];
	if(nil == contents_)
		return;
	
	[[self resourcesTable] addEntriesFromDictionary : contents_];
}
@end


@implementation SGTemplatesManager
+ (SGTemplatesManager *) sharedInstance
{
	static id instance_;
	
	if(nil == instance_){
		[instance_ release];
		instance_ = [[self alloc] init];
	}
	return instance_;
}

- (id) setup
{
	NSString		*filepath_;
	
	filepath_ = [self pathForAttrResource : kSGAttributesTemplateFile 
							   fromBundle : [NSBundle mainBundle]];
	[self addResourcesFromContentsOfFile : filepath_];
	filepath_ = [self pathForAttrResource : kSGAttributesTemplateFile 
							   fromBundle : [NSBundle applicationSpecificBundle]];
	[self addResourcesFromContentsOfFile : filepath_];
	
	// PropertyList
	filepath_ = [[NSBundle mainBundle] pathForResource : kSGPropertyListTemplateFile 
							  					ofType : @"plist"];
	[self addResourcesFromContentsOfFile : filepath_];
	filepath_ = [[NSBundle applicationSpecificBundle] 
								pathForResource : kSGPropertyListTemplateFile 
							  	ofType : @"plist"];
	[self addResourcesFromContentsOfFile : filepath_];
	
	return self;
}
- (id) init
{
	// mainBundleとApplecation Support
	// のファイルをマージ
	if(self = [super init]){
		[self setup];
		
	}
	return self;
}
- (void) dealloc
{
	[_resources release];
	[super dealloc];
}
- (id) resourceForKey : (id) aKey
{
	return [[self resourcesTable] objectForKey: aKey];
}
- (void) addResourcesFromContentsOfFile : (NSString *) filepath
{
	NSString	*pathExtension_;
	
	if(nil == filepath)
		return;
	
	pathExtension_ = [filepath pathExtension];
	UTILAssertNotNilArgument(pathExtension_, @"pathExtension");
	
	if([pathExtension_ isEqualToString : @"rtf"] ||
	   [pathExtension_ isEqualToString : @"rtfd"]){
		[self addATRResourcesFromContentsOfFile : filepath];
	}else if([pathExtension_ isEqualToString : @"plist"]){
		[self addPlistResourcesFromContentsOfFile : filepath];
	}
}
- (void) resetAllResources
{
	[[self resourcesTable] removeAllObjects];
	[self setup];
}
@end



@implementation NSMutableAttributedString(CMXTemplateResourcesManagerPrivate)
- (id) setStringAndReturnSelf : (NSString *) aString
{
	[[self mutableString] setString : aString];
	return self;
}
@end

