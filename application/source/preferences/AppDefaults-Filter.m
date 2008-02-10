//
// AppDefaults-Filter.m
// BathyScaphe
//
// Updated by Tsutomu Sawada on 08/02/08.
// Copyright 2006-2008 BathyScaphe Project. All rights reserved.
// encoding="UTF-8"
//

#import "AppDefaults_p.h"
#import "CMRSpamFilter.h"

static NSString *const kPrefFilterDictKey = @"Preferences - Filter";
static NSString *const kPrefSpamFilterEnabledKey = @"Spam Filter Enabled";
static NSString *const kPrefUsesSpamMessageCorpusKey = @"Uses Spam Message Corpus";
static NSString *const kPrefSpamFilterBehaviorKey = @"Spam Filter Behavior";
static NSString	*const kPrefAADEnabledKey = @"AA Detector Enabled";
static NSString *const kPrefOldNGWordsImportedKey = @"Old Format Corpus Imported";
static NSString *const kPrefTreatsAAAsSpamKey = @"Treats AA as Spam";

@implementation AppDefaults(Filter)
- (NSMutableDictionary *)filterPrefs
{
	if (!_dictFilter) {
		NSDictionary	*dict_;
		
		dict_ = [[self defaults] dictionaryForKey:kPrefFilterDictKey];
		_dictFilter = [dict_ mutableCopy];
		if (!_dictFilter) {
			_dictFilter = [[NSMutableDictionary alloc] init];
		}
	}
	
	return _dictFilter;
}

- (BOOL)spamFilterEnabled
{
	return [[self filterPrefs] boolForKey:kPrefSpamFilterEnabledKey defaultValue:DEFAULT_SPAMFILTER_ENABLED];
}

- (void)setSpamFilterEnabled:(BOOL)flag
{
	[[self filterPrefs] setBool:flag forKey:kPrefSpamFilterEnabledKey];
}

- (BOOL)usesSpamMessageCorpus
{
	return [[self filterPrefs] boolForKey:kPrefUsesSpamMessageCorpusKey defaultValue:DEFAULT_SPAMFILTER_USE_MSG_CORPUS];
}

- (void)setUsesSpamMessageCorpus:(BOOL)flag
{
	[[self filterPrefs] setBool:flag forKey:kPrefUsesSpamMessageCorpusKey];
}

- (NSMutableArray *)spamMessageCorpus
{
	return [[CMRSpamFilter sharedInstance] spamCorpus];
}

- (void)setSpamMessageCorpus:(NSMutableArray *)mutableArray
{
	[[CMRSpamFilter sharedInstance] setSpamCorpus:mutableArray];
}

- (BOOL)oldNGWordsImported
{
	return [[self filterPrefs] boolForKey:kPrefOldNGWordsImportedKey defaultValue:DEFAULT_SPAMFILTER_OLD_NG_IMPORTED];
}

- (void)setOldNGWordsImported:(BOOL)imported
{
	[[self filterPrefs] setBool:imported forKey:kPrefOldNGWordsImportedKey];
}

- (int)spamFilterBehavior
{
	return [[self filterPrefs] integerForKey:kPrefSpamFilterBehaviorKey defaultValue:DEFAULT_SPAMFILTER_BEHAVIOR];
}

- (void)setSpamFilterBehavior:(int)mask
{
	[[self filterPrefs] setInteger:mask forKey:kPrefSpamFilterBehaviorKey];
}

- (void)resetSpamFilter
{
	[[CMRSpamFilter sharedInstance] resetSpamFilter];
}

- (void)setSpamFilterNeedsSaveToFiles:(BOOL)flag
{
	[[CMRSpamFilter sharedInstance] setNeedsSaveToFiles:flag];
}

- (BOOL)asciiArtDetectorEnabled
{
	return [[self filterPrefs] boolForKey:kPrefAADEnabledKey defaultValue:DEFAULT_AAD_ENABLED];
}

- (void)setAsciiArtDetectorEnabled:(BOOL)flag
{
	[[self filterPrefs] setBool:flag forKey:kPrefAADEnabledKey];
}

- (BOOL)treatsAsciiArtAsSpam
{
	return [[self filterPrefs] boolForKey:kPrefTreatsAAAsSpamKey defaultValue:DEFAULT_AAD_TRAET_AA_AS_SPAM];
}

- (void)setTreatsAsciiArtAsSpam:(BOOL)flag
{
	[[self filterPrefs] setBool:flag forKey:kPrefTreatsAAAsSpamKey];
}

- (void)_loadFilter
{

}

- (BOOL)_saveFilter
{
	[[self defaults] setObject:[self filterPrefs] forKey:kPrefFilterDictKey];
	return YES;
}
@end
