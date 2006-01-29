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
  * CocoaのファイルまわりはPOSIXライブラリの
  * パス長制限を受けるので、ログファイルの保存場所
  * のパスはここでチェックしておく。
  * 
  * @param    filepath  パス文字列
  * @return             大丈夫そうならYES
  */
- (BOOL) validatePathLength : (NSString *) filepath
{
	NSData   *data_;		//バイト長で判定
	unsigned  length_;		//バイト長
	
	/*
	*/
	
	if(nil == filepath) return NO;
	data_ = [filepath dataUsingEncoding : NSUTF8StringEncoding];
	
	if(nil == data_) return NO;
	length_ = [data_ length];
		
	return (length_ < COCOMONAR_PATH_MAX);
}

//////////////////////////////////////////////////////////////////////
//////////////////// [ インスタンスメソッド ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * 指定されたディレクトリが存在していなければ、
  * 新規に作成する。
  * 
  * @param    path  ディレクトリのパス
  * @return         作成に成功、または既に存在していればYES
  */
- (BOOL) createDirectoryAtPath : (NSString *) path
{
	NSFileManager *fmanager_;
	NSString      *curPath_;		//検証中のパス
	NSEnumerator  *comps_;			//パス要素を順次処理
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
	//ディレクトリを作成
	
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
