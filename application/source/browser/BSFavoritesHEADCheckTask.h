/**
  * $Id: BSFavoritesHEADCheckTask.h,v 1.2 2006/01/21 10:13:32 tsawada2 Exp $
  * BathyScaphe
  *
  * ���[�J�[�X���b�h��Ŏ��s�����
  * ���C�ɓ���̍X�V�`�F�b�N�iHEAD �����j
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
