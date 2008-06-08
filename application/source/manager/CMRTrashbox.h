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
   performWithFiles:fetchAfterDeletion: メソッド自体が、削除したファイルの再取得を行う訳ではない。
   呼び出し側が「再取得を行おうとしているかどうか」という情報を、CMRTrashboxDidPerformNotification に入れて、観察者達に伝えるための
   ものである。よって、実際の再取得は、観察者または呼び出し側自身が行う必要がある。念のため。
*/
- (BOOL) performWithFiles: (NSArray *) filenames fetchAfterDeletion: (BOOL) shouldFetch; // Available in MeteorSweeper.
@end

//extern NSString *const CMRTrashboxWillPerformNotification;
extern NSString *const CMRTrashboxDidPerformNotification;

extern NSString *const kAppTrashUserInfoFilesKey;
extern NSString *const kAppTrashUserInfoStatusKey;

// NSNumber(as BOOL value).
extern NSString *const kAppTrashUserInfoAfterFetchKey; // Availavle in MeteorSweeper.