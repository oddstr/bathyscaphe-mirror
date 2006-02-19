/**
  * $Id: BSFavoritesHEADCheckTask.h,v 1.3 2006/02/19 08:49:19 tsawada2 Exp $
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

- (void) checkEachItemOfThreadsArray;
@end


#define kBSUserInfoThreadsArrayKey		@"threadsArray"

extern NSString *const BSFavoritesHEADCheckTaskDidFinishNotification;
