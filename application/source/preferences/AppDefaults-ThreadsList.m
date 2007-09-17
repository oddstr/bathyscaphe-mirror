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

static NSString *const AppDefaultsTLViewModeKey = @"View Mode";

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

- (BOOL) useIncrementalSearch
{
	return [[self defaults]
					boolForKey : AppDefaultsUseIncrementalSearchKey
				  defaultValue : DEFAULT_TL_INCREMENTAL_SEARCH];
}
- (void) setUseIncrementalSearch : (BOOL) TorF
{
	[[self defaults]
			setBool : TorF
			 forKey : AppDefaultsUseIncrementalSearchKey];
}
/*#pragma mark PrincessBride Additions
- (BOOL) titleRulerViewTextUsesBlackColor
{
	return [[self defaults] boolForKey : AppDefaultsTRViewTextUsesBlackColorKey
						  defaultValue : DEFAULT_TITLERULER_TEXT_BLACK];
}
- (void) setTitleRulerViewTextUsesBlackColor : (BOOL) usesBlackColor
{
	[[self defaults] setBool : usesBlackColor
					  forKey : AppDefaultsTRViewTextUsesBlackColorKey];
}*/

#pragma mark ShortCircuit Additions
static id AppDefaults_defaultBrowserListColumns(void)
{
	static NSArray *cachedDefaultArray = nil;
	if (!cachedDefaultArray) {
		cachedDefaultArray = [[NSArray alloc] initWithObjects:
			[NSDictionary dictionaryWithObjectsAndKeys:@"Status",@"Identifier",[NSNumber numberWithFloat:18.0],@"Width",nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"Number",@"Identifier",[NSNumber numberWithFloat:40.0],@"Width",nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"Title",@"Identifier",[NSNumber numberWithFloat:251.0],@"Width",nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"Count",@"Identifier",[NSNumber numberWithFloat:60.0],@"Width",nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"NewCount",@"Identifier",[NSNumber numberWithFloat:60.0],@"Width",nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"Updated Count",@"Identifier",[NSNumber numberWithFloat:60.0],@"Width",nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"ModifiedDate",@"Identifier",[NSNumber numberWithFloat:100.0],@"Width",nil],
			nil];
	}
	return cachedDefaultArray;
}

- (id) threadsListTableColumnState
{
	id storedValue = [[self defaults] objectForKey:AppDefaultsTLTableColumnStateKey];
	if (storedValue) {
		return storedValue;
	} else {
		return AppDefaults_defaultBrowserListColumns();
	}
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
											   defaultValue : DEFAULT_TL_AUTORELOAD_WHEN_WAKE];
}
- (void) setAutoReloadListWhenWake : (BOOL) doReload
{
	[[self threadsListSettingsDictionary] setBool : doReload
										   forKey : AppDefaultsTLAutoReloadWhenWakeKey];
}

#pragma mark RainbowJerk Additions
- (NSDate *) lastHEADCheckedDate
{
	id tmp_ = [[self threadsListSettingsDictionary] objectForKey : AppDefaultsTLLastHEADCheckedDateKey];
	if (!tmp_ || NO == [tmp_ isKindOfClass: [NSDate class]]) return nil;
	return tmp_;
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

	NSDate *curDate_ = [NSDate date];
	NSDate *nextDate_ = [[[NSDate alloc] initWithTimeInterval: DEFAULT_HEADCHECK_INTERVAL sinceDate: baseDate_] autorelease];
	return ([curDate_ compare: nextDate_] != NSOrderedAscending);
/*	
	NSTimeInterval interval_ = [[NSDate date] timeIntervalSinceDate : baseDate_];
	return (interval_ > [self HEADCheckTimeInterval]);*/
}

#pragma mark GrafEisen Addition
- (NSTimeInterval) HEADCheckTimeInterval
{
	return [[self threadsListSettingsDictionary] doubleForKey : AppDefaultsTLHEADCheckIntervalKey
												 defaultValue : DEFAULT_HEADCHECK_INTERVAL];
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

#pragma mark Twincam Angel Additions
- (BSThreadsListViewModeType)threadsListViewMode
{
	return [[self threadsListSettingsDictionary] integerForKey:AppDefaultsTLViewModeKey defaultValue:DEFAULT_TL_VIEW_MODE];
}

- (void)setThreadsListViewMode:(BSThreadsListViewModeType)type
{
	[[self threadsListSettingsDictionary] setInteger:type forKey:AppDefaultsTLViewModeKey];
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
