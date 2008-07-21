//
//  CMRTaskManager.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/18.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

/*!
 * @header     CMRTaskManager
 * @discussion Application Task Manager
 */

#import <Cocoa/Cocoa.h>
#import "CMRTask.h"

/*!
 * @class       CMRTaskManager
 * @abstract    各タスクの進行状況を管理するマネージャ
 * @discussion  
 *
 * アプリケーションの各タスク（更新作業など）はCMRTaskManagerに登録する
 * ことでそれらの進行状況をユーザに視覚的に報告することができます。
 */

@class		SGContainerTableView;

@interface CMRTaskManager : NSWindowController<CMRTask> {
	@private
	NSMutableArray					*_tasksInProgress;
	NSMutableArray					*_taskItemControllers;
	NSMutableDictionary				*_controllerMapping;
	
	IBOutlet SGContainerTableView	*_taskContainerView;
	IBOutlet NSArrayController		*_arrayController;
	
//	NSTimer		*_notificationTimer;
	id<CMRTask>		m_currentTask;
}

+ (id)defaultManager;

- (void)addTask:(id<CMRTask>)aTask;

- (IBAction)cancel:(id)sender;
- (IBAction)scrollLastRowToVisible:(id)sender;

// For KVO
- (id<CMRTask>)currentTask;
- (void)setCurrentTask:(id<CMRTask>)aTask;
@end
