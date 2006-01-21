/**
  * $Id: BSFavoritesHEADCheckTask.h,v 1.1 2006/01/21 07:17:02 tsawada2 Exp $
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
}

+ (id) taskWithFavItemsArray : (NSMutableArray *) loadedList;
- (id) initWithFavItemsArray : (NSMutableArray *) loadedList;

- (NSString *) boardName;
- (void) setBoardName : (NSString *) aBoardName;

- (NSMutableArray *) threadsArray;
- (void) setThreadsArray : (NSMutableArray *) aThreadsArray;

- (void) setProgress : (unsigned) newValue;

- (void) checkEachItemOfFavItemsArray;
@end


#define kBSUserInfoThreadsArrayKey		@"threadsArray"

extern NSString *const BSFavoritesHEADCheckTaskDidFinishNotification;
