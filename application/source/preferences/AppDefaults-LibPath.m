//:AppDefaults-LibPath.m
/**
  *
  * ライブラリや設定ファイルのパスの取得
  *
  * @version 1.0.0d2 (01/11/29  6:02:35 PM)
  *
  */
#import "AppDefaults_p.h"


#define COCOMONAR_PATH_MAX    (1024 - 40)  /* max bytes in pathname */



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