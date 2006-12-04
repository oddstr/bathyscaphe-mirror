//: CMRTaskItemController_p.h/**  * $Id: CMRTaskItemController_p.h,v 1.1.1.1.8.1 2006/12/04 21:54:46 tsawada2 Exp $  *   * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.  * See the file LICENSE for copying permission.  */#import "CMRTaskItemController.h"#import <Foundation/Foundation.h>#import <Cocoa/Cocoa.h>#import <SGFoundation/SGFoundation.h>#import <SGAppKit/SGAppKit.h>#import <CocoMonar/CocoMonar.h>#import "UTILKit.h"#import "CMRTask.h"#import "BSDateFormatter.h"#define APP_TASK_ITEM_CONTROLLER_NIB_NAME	@"CMRTaskItem"#define kLocalizableFileName				@"CMRTaskDescription"@interface CMRTaskItemController(Private)/* Accessor for m_task */- (void) setTask : (id<CMRTask>) aTask;/* Accessor for m_finishedDate */- (NSDate *) finishedDate;- (void) setFinishedDate : (NSDate *) aFinishedDate;@end@interface CMRTaskItemController(ViewSetting)- (void) updateUIComponents;- (void) disposeUnnecessaryViews;- (void) sizeOfTextFieldsToFit : (NSTextField *) textField;@end@interface CMRTaskItemController (CMRTaskNotification)- (void) taskWillStartProcessing : (id<CMRTask>) aTask;- (void) taskDidFinishProcessing : (id<CMRTask>) aTask;- (void) taskWillProgressProcessing : (id<CMRTask>) aTask;@end@interface CMRTaskItemController(ViewAccessor)/* Accessor for m_titleField */- (NSTextField *) titleField;/* Accessor for m_messageField */- (NSTextField *) messageField;/* Accessor for m_indicator */- (NSProgressIndicator *) indicator;/* Accessor for m_stopButton */- (NSButton *) stopButton;@end