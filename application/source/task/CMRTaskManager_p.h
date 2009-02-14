////  CMRTaskManager_p.h//  BathyScaphe////  Updated by Tsutomu Sawada on 08/03/18.//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.//  encoding="UTF-8"//#import "CMRTaskManager.h"#import "CocoMonar_Prefix.h"#import <SGAppKit/SGContainerTableView.h>#import "CMRTaskItemController.h"#define APP_TASK_MANAGER_NIB_NAME			@"CMRTaskManager"@interface CMRTaskManager(TaskInProgress)- (void)addTaskInProgress:(id<CMRTask>)aTask;- (void)removeTask:(id<CMRTask>)aTask;- (void)taskWillStartProcessing:(NSNotification *)aNotification;- (void)taskDidFinishProcessing:(NSNotification *)aNotification;- (void)registerNotificationWithTask:(id<CMRTask>)aTask;- (void)removeFromNotificationWithTask:(id<CMRTask>)aTask;- (BOOL)shouldRegisterTask:(id<CMRTask>)aTask;@end@interface CMRTaskManager(TaskItemManagement)- (NSMutableArray *)tasksInProgress;- (NSMutableArray *)taskItemControllers;- (NSMutableDictionary *)controllerMapping;- (CMRTaskItemController *)controllerForTask:(id<CMRTask>)aTask;- (void)addTaskItemController:(CMRTaskItemController *)newController;@end@interface CMRTaskManager(ViewAccessor)- (NSScrollView *)scrollView;- (SGContainerTableView *)taskContainerView;//- (NSArrayController *)tasksArrayController;- (void)taskContainerViewScrollLastRowToVisible;- (void)setupTaskContainerView;- (void)setupUIComponents;@end