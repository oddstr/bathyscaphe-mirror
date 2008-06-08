/**
  * $Id: CMRTrashbox.h,v 1.4 2008/06/08 03:51:33 tsawada2 Exp $
  * BathyScaphe
  *
  * Copyright 2005-2006 BathyScaphe Project, all rights reserved.
  * Original from CocoMonar.
  *
  */
#import <Foundation/Foundation.h>


@interface CMRTrashbox : NSObject
+ (id) trash;
//@end

//@interface CMRTrashbox(FileOperation)
//- (BOOL) performWithFiles : (NSArray *) filenames; // Deprecated. Use performWithFiles:fetchAfterDeletion: instead.

/* NOTE
   performWithFiles:fetchAfterDeletion: ���\�b�h���̂��A�폜�����t�@�C���̍Ď擾���s����ł͂Ȃ��B
   �Ăяo�������u�Ď擾���s�����Ƃ��Ă��邩�ǂ����v�Ƃ��������ACMRTrashboxDidPerformNotification �ɓ���āA�ώ@�ҒB�ɓ`���邽�߂�
   ���̂ł���B����āA���ۂ̍Ď擾�́A�ώ@�҂܂��͌Ăяo�������g���s���K�v������B�O�̂��߁B
*/
- (BOOL) performWithFiles: (NSArray *) filenames fetchAfterDeletion: (BOOL) shouldFetch; // Available in MeteorSweeper.
@end

//extern NSString *const CMRTrashboxWillPerformNotification;
extern NSString *const CMRTrashboxDidPerformNotification;

extern NSString *const kAppTrashUserInfoFilesKey;
extern NSString *const kAppTrashUserInfoStatusKey;

// NSNumber(as BOOL value).
extern NSString *const kAppTrashUserInfoAfterFetchKey; // Availavle in MeteorSweeper.