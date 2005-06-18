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
static NSString *const AppDefaultsIsStatusLineUsesSpinningStyleKey = @"Uses Spinning Style";
static NSString *const AppDefaultsStatusLinePositionKey = @"StatusLine Position";
static NSString *const AppDefaultsStatusLineToolbarAlignmentKey = @"StatusLine Toolbar Alignment";



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
/*
- (BOOL) statusLineUsesSpinningStyle
{
	return [[self threadsListSettingsDictionary]
					boolForKey : AppDefaultsIsStatusLineUsesSpinningStyleKey
				  defaultValue : DEFAULT_USES_SPINNINGSTYLE];
}
- (void) setStatusLineUsesSpinningStyle : (BOOL) usesSpinningStyle
{
	[[self threadsListSettingsDictionary]
			setBool : usesSpinningStyle
			 forKey : AppDefaultsIsStatusLineUsesSpinningStyleKey];
	[self postLayoutSettingsUpdateNotification];
}
- (int) statusLinePosition
{
	return [[self threadsListSettingsDictionary]
					integerForKey : AppDefaultsStatusLinePositionKey];
}
- (void) setStatusLinePosition : (int) aStatusLinePosition
{
	[[self threadsListSettingsDictionary]
			setInteger : aStatusLinePosition
				forKey : AppDefaultsStatusLinePositionKey];
	[self postLayoutSettingsUpdateNotification];
}
- (int) statusLineToolbarAlignment
{
	return [[self threadsListSettingsDictionary]
					integerForKey : AppDefaultsStatusLineToolbarAlignmentKey];
}
- (void) setStatusLineToolbarAlignment : (int) aStatusLineToolbarAlignment
{
	[[self threadsListSettingsDictionary]
			setInteger : aStatusLineToolbarAlignment
				forKey : AppDefaultsStatusLineToolbarAlignmentKey];
	[self postLayoutSettingsUpdateNotification];
}
*/
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
