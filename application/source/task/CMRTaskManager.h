//: CMRTaskManager.h
/**
  * $Id: CMRTaskManager.h,v 1.1.1.1 2005/05/11 17:51:07 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     CMRTaskManager
 * @discussion Application Task Manager
 */

#import <Foundation/Foundation.h>
#import <AppKit/NSNibDeclarations.h>
#import <AppKit/NSWindowController.h>


@class		CMRTaskItemController;
@class		SGContainerTableView;
@protocol	CMRTask;


/*!
 * @class       CMRTaskManager
 * @abstract    �e�^�X�N�̐i�s�󋵂��Ǘ�����}�l�[�W��
 * @discussion  
 *
 * �A�v���P�[�V�����̊e�^�X�N�i�X�V��ƂȂǁj��CMRTaskManager�ɓo�^����
 * ���Ƃł����̐i�s�󋵂����[�U�Ɏ��o�I�ɕ񍐂��邱�Ƃ��ł��܂��B
 */
@interface CMRTaskManager : NSWindowController<CMRTask>
{
	@private
	NSMutableArray					*_tasksInProgress;
	NSMutableArray					*_taskItemControllers;
	NSMutableDictionary				*_controllerMapping;
	
	IBOutlet SGContainerTableView	*_taskContainerView;
	
	NSTimer		*_notificationTimer;
}
+ (id) defaultManager;

- (void) addTask : (id<CMRTask>) aTask;

- (IBAction) showWindow : (id) sender;
- (IBAction) cancel : (id) sender;
- (IBAction) scrollLastRowToVisible : (id) sender;
@end
