/**
  * $Id: AppDefaults-LibPath.m,v 1.2.4.1 2006/01/29 12:58:10 masakih Exp $
  * BathyScaphe
  *
  * Copyright 2005-2006 BathyScpahe Project. All rights reserved.
  *
  */
#import "AppDefaults_p.h"


#define COCOMONAR_PATH_MAX    (1024 - 40)  /* max bytes in pathname */

static NSString *const AppDefaultsSoundsSettingsKey = @"Preferences - Sounds";

static NSString *const kHEADCheckNewArrivedSoundKey = @"Sound:HEADCheck New Arrival";
static NSString *const kHEADCheckNoUpdateSoundKey	= @"Sound:HEADCheck No Update";
static NSString *const kReplyDidFinishSoundKey		= @"sound:Reply Sent Successfully";

@implementation AppDefaults(LibraryPath)
/**
  * Cocoa�̃t�@�C���܂���POSIX���C�u������
  * �p�X���������󂯂�̂ŁA���O�t�@�C���̕ۑ��ꏊ
  * �̃p�X�͂����Ń`�F�b�N���Ă����B
  * 
  * @param    filepath  �p�X������
  * @return             ���v�����Ȃ�YES
  */
- (BOOL) validatePathLength : (NSString *) filepath
{
	NSData   *data_;		//�o�C�g���Ŕ���
	unsigned  length_;		//�o�C�g��
	
	/*
	*/
	
	if(nil == filepath) return NO;
	data_ = [filepath dataUsingEncoding : NSUTF8StringEncoding];
	
	if(nil == data_) return NO;
	length_ = [data_ length];
		
	return (length_ < COCOMONAR_PATH_MAX);
}

//////////////////////////////////////////////////////////////////////
//////////////////// [ �C���X�^���X���\�b�h ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * �w�肳�ꂽ�f�B���N�g�������݂��Ă��Ȃ���΁A
  * �V�K�ɍ쐬����B
  * 
  * @param    path  �f�B���N�g���̃p�X
  * @return         �쐬�ɐ����A�܂��͊��ɑ��݂��Ă����YES
  */
- (BOOL) createDirectoryAtPath : (NSString *) path
{
	NSFileManager *fmanager_;
	NSString      *curPath_;		//���ؒ��̃p�X
	NSEnumerator  *comps_;			//�p�X�v�f����������
	NSString      *dir_;
	
	BOOL isDir_;
	
	if(nil == path || [path length] < 1) return NO;
	
	fmanager_ = [NSFileManager defaultManager];
	isDir_ = NO;
	if([fmanager_ fileExistsAtPath : path isDirectory : &isDir_]){
		if(isDir_){
			return YES;
		}else{
			return NO;
		}
	}
	//�f�B���N�g�����쐬
	
	curPath_ = @"";
	comps_ = [[path pathComponents] objectEnumerator];
	
	while(dir_ = [comps_ nextObject]){
		curPath_ = [curPath_ stringByAppendingPathComponent : dir_];
		if([fmanager_ fileExistsAtPath : curPath_ isDirectory : &isDir_]){
			if(isDir_){
				continue;
			}else{
				return NO;
			}
		}
		if(NO == [fmanager_ createDirectoryAtPath : curPath_ 
									   attributes : nil]){
			return NO;
		}
	}
	return YES;
}
@end

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
	return [[self soundsSettingsDictionary] objectForKey : kHEADCheckNewArrivedSoundKey defaultObject : @"Ping"];
}
- (void) setHEADCheckNewArrivedSound : (NSString *) soundName
{
	[[self soundsSettingsDictionary] setObject : soundName forKey : kHEADCheckNewArrivedSoundKey];
}
- (NSString *) HEADCheckNoUpdateSound
{
	return [[self soundsSettingsDictionary] objectForKey : kHEADCheckNoUpdateSoundKey defaultObject : @"Basso"];
}
- (void) setHEADCheckNoUpdateSound : (NSString *) soundName
{
	[[self soundsSettingsDictionary] setObject : soundName forKey : kHEADCheckNoUpdateSoundKey];
}
- (NSString *) replyDidFinishSound
{
	return [[self soundsSettingsDictionary] objectForKey : kReplyDidFinishSoundKey defaultObject : @""];
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
