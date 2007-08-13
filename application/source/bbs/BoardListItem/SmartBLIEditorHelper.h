//
//  SmartBLIEditorHelper.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/01/03.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SmartCondition.h"

@class ColorBackgroundView;

@interface SmartBLIEditorHelper : NSObject
{
    IBOutlet NSPopUpButton *allOrAnyPopUp;
    IBOutlet NSScrollView *container;
    IBOutlet NSButton *includeFallInDATCheck;
	IBOutlet NSButton *excludeAdThreadCheck;
    IBOutlet NSTextField *nameField;
	
	IBOutlet id expressionView;
    IBOutlet id numberView;
	IBOutlet id dateView;
	
	SmartBLIEditorHelper *previousHelper;
	SmartBLIEditorHelper *nextHelper;
}
- (IBAction)addCriterion:(id)sender;
- (IBAction)changeCriterionPop:(id)sender;
- (IBAction)removeCriterion:(id)sender;
@end

@interface SmartBLIEditorHelper(SmartConditionAccesor)
- (BOOL)isValid;
- (id<SmartCondition>)condition;
- (BOOL)buildHelperFromCondition:(id<SmartCondition>)condition;
@end