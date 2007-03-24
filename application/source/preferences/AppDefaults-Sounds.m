//
//  AppDefaults-Sounds.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/03/24.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//


#import "AppDefaults_p.h"

static NSString *const AppDefaultsSoundsSettingsKey = @"Preferences - Sounds";

static NSString *const kHEADCheckNewArrivedSoundKey = @"Sound:HEADCheck New Arrival";
static NSString *const kHEADCheckNoUpdateSoundKey	= @"Sound:HEADCheck No Update";
static NSString *const kReplyDidFinishSoundKey		= @"sound:Reply Sent Successfully";

@implementation AppDefaults(Sounds)
- (NSMutableDictionary *) soundsSettingsDictionary
{
	if(nil == m_soundsDictionary){
		NSDictionary	*dict_;
		
		dict_ = [[self defaults] 
					dictionaryForKey : AppDefaultsSoundsSettingsKey];
		m_soundsDictionary = [dict_ mutableCopy];
	}
	
	if(nil == m_soundsDictionary)
		m_soundsDictionary = [[NSMutableDictionary alloc] init];
	
	return m_soundsDictionary;
}

- (NSString *) HEADCheckNewArrivedSound
{
	return [[self soundsSettingsDictionary] objectForKey : kHEADCheckNewArrivedSoundKey defaultObject : DEFAULT_SOUND_HEADCHECK_NEW];
}
- (void) setHEADCheckNewArrivedSound : (NSString *) soundName
{
	[[self soundsSettingsDictionary] setObject : soundName forKey : kHEADCheckNewArrivedSoundKey];
}
- (NSString *) HEADCheckNoUpdateSound
{
	return [[self soundsSettingsDictionary] objectForKey : kHEADCheckNoUpdateSoundKey defaultObject : DEFAULT_SOUND_HEADCHECK_NONE];
}
- (void) setHEADCheckNoUpdateSound : (NSString *) soundName
{
	[[self soundsSettingsDictionary] setObject : soundName forKey : kHEADCheckNoUpdateSoundKey];
}
- (NSString *) replyDidFinishSound
{
	return [[self soundsSettingsDictionary] objectForKey : kReplyDidFinishSoundKey defaultObject : DEFAULT_SOUND_HEADCHECK_REPLY];
}
- (void) setReplyDidFinishSound : (NSString *) soundName
{
	[[self soundsSettingsDictionary] setObject : soundName forKey : kReplyDidFinishSoundKey];
}


- (void) _loadSoundsSettings
{
}

- (BOOL) _saveSoundsSettings
{
	NSDictionary			*dict_;
	
	dict_ = [self soundsSettingsDictionary];
	
	UTILAssertNotNil(dict_);
	[[self defaults] setObject : dict_
						forKey : AppDefaultsSoundsSettingsKey];
	return YES;
}
@end
