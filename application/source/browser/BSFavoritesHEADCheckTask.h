/**
  * $Id: BSFavoritesHEADCheckTask.h,v 1.2.2.1 2006/01/29 12:58:10 masakih Exp $
  * BathyScaphe
  *
  * ワーカースレッド上で実行される
  * お気に入りの更新チェック（HEAD 投げ）
  *
  * Copyright 2006 BathyScaphe Project. All rights reserved.
  *
  */
#import <Foundation/Foundation.h>
#import "CMRThreadLayoutTask.h"


@interface BSFavoritesHEADCheckTask : CMRThreadLayoutConcreateTask
{
	@private
	NSString				*_boardName;
	NSMutableArray			*_threadsArray;

	unsigned		_progress;
	NSString		*_amountString;
}

+ (id) taskWithFavItemsArray : (NSMutableArray *) loadedList;
- (id) initWithFavItemsArray : (NSMutableArray *) loadedList;

- (NSString *) boardName;
- (void) setBoardName : (NSString *) aBoardName;

- (NSMutableArray *) threadsArray;
- (void) setThreadsArray : (NSMutableArray *) aThreadsArray;

- (void) setProgress : (unsigned) newValue;

- (NSString *) amountString;
- (void) setAmountString : (NSString *) someString;

- (void) checkEachItemOfFavItemsArray;
@end


#define kBSUserInfoThreadsArrayKey		@"threadsArray"

extern NSString *const BSFavoritesHEADCheckTaskDidFinishNotification;
