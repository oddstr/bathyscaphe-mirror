/**
  * $Id: AppDefaults-Filter.m,v 1.1.1.1.8.1 2006/09/09 20:35:56 tsawada2 Exp $
  * 
  * AppDefaults-Filter.m
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "AppDefaults_p.h"
#import "CMRSpamFilter.h"



#define kPrefFilterDictKey				@"Preferences - Filter"
#define kPrefSpamFilterEnabledKey		@"Spam Filter Enabled"
#define kPrefUsesSpamMessageCorpusKey	@"Uses Spam Message Corpus"
#define kPrefSpamFilterBehaviorKey		@"Spam Filter Behavior"
#define kPrefAADEnabledKey				@"AA Detector Enabled"


@implementation AppDefaults(Filter)
- (NSMutableDictionary *) filterPrefs
{
	if (nil == _dictFilter) {
		NSDictionary	*dict_;
		
		dict_ = [[self defaults] dictionaryForKey : kPrefFilterDictKey];
		_dictFilter = [dict_ mutableCopy];
		if (nil == _dictFilter)
			_dictFilter = [[NSMutableDictionary alloc] init];
	}
	
	return _dictFilter;
}


/*** 迷惑レスフィルタ***/
- (BOOL) spamFilterEnabled
{
	return [[self filterPrefs] 
					 boolForKey : kPrefSpamFilterEnabledKey
				   defaultValue : NO];
}
- (void) setSpamFilterEnabled : (BOOL) flag
{
	[[self filterPrefs] 
			 setBool : flag
			  forKey : kPrefSpamFilterEnabledKey];
}
// 本文中の語句もチェックする
- (BOOL) usesSpamMessageCorpus
{
	return [[self filterPrefs] 
					 boolForKey : kPrefUsesSpamMessageCorpusKey
				   defaultValue : NO];
}
- (void) setUsesSpamMessageCorpus : (BOOL) flag
{
	[[self filterPrefs] 
			 setBool : flag
			  forKey : kPrefUsesSpamMessageCorpusKey];
}
- (NSString *) spamMessageCorpusStringRepresentation
{
	NSArray		*spamCorpus_;
	
	spamCorpus_ = [[CMRSpamFilter sharedInstance] spamCorpus];
	if (nil == spamCorpus_ || 0 == [spamCorpus_ count])
		return @"";
	
	return [spamCorpus_ componentsJoinedByString : @"\n"];
}
- (void) setUpSpamMessageCorpusWithString : (NSString *) aString
{
	NSArray		*spamCorpus_;
	
	spamCorpus_ = (nil == aString || 0 == [aString length])
			? [NSArray array]
			: [aString componentsSeparatedByNewline];
	
	[[CMRSpamFilter sharedInstance] setSpamCorpus : spamCorpus_];
}

// 迷惑レスを見つけたときの動作：
- (int) spamFilterBehavior
{
	return [[self filterPrefs] 
				  integerForKey : kPrefSpamFilterBehaviorKey
				   defaultValue : kSpamFilterChangeTextColorBehavior];
}
- (void) setSpamFilterBehavior : (int) mask
{
	[[self filterPrefs] 
			 setInteger : mask
			     forKey : kPrefSpamFilterBehaviorKey];
}
// リセット
- (void) resetSpamFilter
{
	[[CMRSpamFilter sharedInstance] resetSpamFilter];
}

- (BOOL) asciiArtDetectorEnabled
{
	return [[self filterPrefs] boolForKey: kPrefAADEnabledKey defaultValue: YES];
}
- (void) setAsciiArtDetectorEnabled: (BOOL) flag
{
	[[self filterPrefs] setBool: flag forKey: kPrefAADEnabledKey];
}

- (void) _loadFilter
{

}
- (BOOL) _saveFilter
{
	[[self defaults] setObject : [self filterPrefs]
						forKey : kPrefFilterDictKey];
	return YES;
}
@end

