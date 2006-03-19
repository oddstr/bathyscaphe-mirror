//:AppDefaults-ThreadsList.m
/**
  *
  * スレッド一覧に関する設定をまとめたカテゴリ。
  *
  * @version 1.0.0d6 (02/01/14  6:53:29 PM)
  *
  */

#import "AppDefaults_p.h"


static NSString *const AppDefaultsThreadsListSettingsKey = @"Preferences - ThreadsListSettings";
static NSString *const AppDefaultsThreadsListAutoscrollMaskKey = @"Selection Holding Mask";
static NSString *const AppDefaultsTLIgnoreTitleCharactersKey = @"Ignore Characters";

static NSString *const AppDefaultsTLAutoReloadWhenWakeKey = @"Reload When Wake";

static NSString *const AppDefaultsTLLastHEADCheckedDateKey = @"Last HEADCheck";
static NSString *const AppDefaultsTLHEADCheckIntervalKey = @"HEADCheck Interval";

// 以下は User Defaults 直下に作成される key
static NSString *const AppDefaultsUseIncrementalSearchKey = @"UseIncrementalSearch";
static NSString *const AppDefaultsTRViewTextUsesBlackColorKey = @"ThreadTitleBarTextUsesBlackColor";
static NSString *const AppDefaultsTLTableColumnStateKey = @"ThreadsListTable Columns Manualsave";



@implementation AppDefaults(ThreadsListSettings)
- (NSMutableDictionary *) threadsListSettingsDictionary
{
	if(nil == m_threadsListDictionary){
		NSDictionary	*dict_;
		
		dict_ = [[self defaults] 
					dictionaryForKey : AppDefaultsThreadsListSettingsKey];
		m_threadsListDictionary = [dict_ mutableCopy];
	}
	
	if(nil == m_threadsListDictionary)
		m_threadsListDictionary = [[NSMutableDictionary alloc] init];
	
	return m_threadsListDictionary;
}

- (int) threadsListAutoscrollMask
{
	return [[self threadsListSettingsDictionary]
				 integerForKey : AppDefaultsThreadsListAutoscrollMaskKey
				  defaultValue : DEFAULT_TLSEL_HOLDING_MASK];
}
- (void) setThreadsListAutoscrollMask : (int) mask
{
	[[self threadsListSettingsDictionary]
		setInteger : mask
			forKey : AppDefaultsThreadsListAutoscrollMaskKey];
}
/*
- (NSString *) ignoreTitleCharacters
{
	NSString	*ignoreTitleCharacters_;
	
	ignoreTitleCharacters_ = 
		[[self threadsListSettingsDictionary] 
			objectForKey : AppDefaultsTLIgnoreTitleCharactersKey];
	
	if(nil == ignoreTitleCharacters_ || 
		NO == [ignoreTitleCharacters_ isKindOfClass : [NSString class]]){
		
		return  DEFAULT_IGNORING_TITLE_CHARACTERS;
	}
	
	return ignoreTitleCharacters_;
}
- (void) setIgnoreTitleCharacters : (NSString *) chars
{
	if(nil == chars){
		[[self threadsListSettingsDictionary]
			 removeObjectForKey : AppDefaultsTLIgnoreTitleCharactersKey];
		return;
	}
	
	[[self threadsListSettingsDictionary]
		 setObject : chars
			forKey : AppDefaultsTLIgnoreTitleCharactersKey];
}
*/
- (BOOL) useIncrementalSearch
{
	return [[self defaults]
					boolForKey : AppDefaultsUseIncrementalSearchKey
				  defaultValue : YES];
}
- (void) setUseIncrementalSearch : (BOOL) TorF
{
	[[self defaults]
			setBool : TorF
			 forKey : AppDefaultsUseIncrementalSearchKey];
}
#pragma mark PrincessBride Additions
- (BOOL) titleRulerViewTextUsesBlackColor
{
	return [[self defaults] boolForKey : AppDefaultsTRViewTextUsesBlackColorKey
						  defaultValue : NO];
}
- (void) setTitleRulerViewTextUsesBlackColor : (BOOL) usesBlackColor
{
	[[self defaults] setBool : usesBlackColor
					  forKey : AppDefaultsTRViewTextUsesBlackColorKey];
}

#pragma mark ShortCircuit Additions

- (id) threadsListTableColumnState
{
	return [[self defaults] objectForKey : AppDefaultsTLTableColumnStateKey];
}
- (void) setThreadsListTableColumnState : (id) aColumnState
{
	[[self defaults] setObject : aColumnState
						forKey : AppDefaultsTLTableColumnStateKey];
}

#pragma mark InnocentStarter Additions
- (BOOL) autoReloadListWhenWake
{
	return [[self threadsListSettingsDictionary] boolForKey : AppDefaultsTLAutoReloadWhenWakeKey
											   defaultValue : NO];
}
- (void) setAutoReloadListWhenWake : (BOOL) doReload
{
	[[self threadsListSettingsDictionary] setBool : doReload
										   forKey : AppDefaultsTLAutoReloadWhenWakeKey];
}

#pragma mark RainbowJerk Additions
- (NSDate *) lastHEADCheckedDate
{
	return [[self threadsListSettingsDictionary] objectForKey : AppDefaultsTLLastHEADCheckedDateKey];
}
- (void) setLastHEADCheckedDate : (NSDate *) date
{
	[[self threadsListSettingsDictionary] setObject : date
											 forKey : AppDefaultsTLLastHEADCheckedDateKey];
}

- (BOOL) canHEADCheck
{
	NSDate *baseDate_ = [self lastHEADCheckedDate];
	if (!baseDate_) return YES;
	
	NSTimeInterval interval_ = [[NSDate date] timeIntervalSinceDate : baseDate_];
	return (interval_ > [self HEADCheckTimeInterval]);
}

#pragma mark GrafEisen Addition
- (NSTimeInterval) HEADCheckTimeInterval
{
	return [[self threadsListSettingsDictionary] doubleForKey : AppDefaultsTLHEADCheckIntervalKey
												 defaultValue : 300.0];
}

- (void) setHEADCheckTimeInterval : (NSTimeInterval) interval
{
	[[self threadsListSettingsDictionary] setDouble : interval
											 forKey : AppDefaultsTLHEADCheckIntervalKey];
}

- (NSDate *) nextHEADCheckAvailableDate
{
	NSDate *baseDate_ = [self lastHEADCheckedDate];
	if (!baseDate_)
		return [NSDate date];
	else
		return [baseDate_ addTimeInterval : [self HEADCheckTimeInterval]];
}

#pragma mark -

- (void) _loadThreadsListSettings
{
}

- (BOOL) _saveThreadsListSettings
{
	NSDictionary			*dict_;
	
	dict_ = [self threadsListSettingsDictionary];
	
	UTILAssertNotNil(dict_);
	[[self defaults] setObject : dict_
						forKey : AppDefaultsThreadsListSettingsKey];
	return YES;
}
@end
