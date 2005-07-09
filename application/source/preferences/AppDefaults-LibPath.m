//:AppDefaults-LibPath.m
/**
  *
  * ���C�u������ݒ�t�@�C���̃p�X�̎擾
  *
  * @version 1.0.0d2 (01/11/29  6:02:35 PM)
  *
  */
#import "AppDefaults_p.h"


#define COCOMONAR_PATH_MAX    (1024 - 40)  /* max bytes in pathname */



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