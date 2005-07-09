//:AppDefaults-ThreadsList.m
/**
  *
  * �X���b�h�ꗗ�Ɋւ���ݒ���܂Ƃ߂��J�e�S���B
  *
  * @version 1.0.0d6 (02/01/14  6:53:29 PM)
  *
  */

#import "AppDefaults_p.h"
#import "CMRNSSearchField.h"


static NSString *const AppDefaultsThreadsListSettingsKey = @"Preferences - ThreadsListSettings";
static NSString *const AppDefaultsThreadsListAutoscrollMaskKey = @"Selection Holding Mask";
static NSString *const AppDefaultsTLIgnoreTitleCharactersKey = @"Ignore Characters";
static NSString *const AppDefaultsStatusLinePositionKey = @"StatusLine Position";
static NSString *const AppDefaultsStatusLineToolbarAlignmentKey = @"StatusLine Toolbar Alignment";

// ����� User Defaults �����ɍ쐬����� key
static NSString *const AppDefaultsUseIncrementalSearchKey = @"UseIncrementalSearch";



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
