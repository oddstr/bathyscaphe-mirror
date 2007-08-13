//
//  SmartBoardListItemEditor.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/12/27.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BoardListItem.h"

#import "SmartBLIEditorHelper.h"

@interface SmartBoardListItemEditor : NSObject
{
	IBOutlet NSWindow *editorWindow;
	IBOutlet SmartBLIEditorHelper *helper;
	IBOutlet NSTextField *nameField;
	
	NSInvocation *mInvocation;

}

+ (id) editor;

// settingSelector  
//- (void) settingSelector : (BoardListItem *)item userInfo : (void *)userInfo;
- (void)cretateFromUIWindow : (NSWindow *)modalForWindow
				   delegate : (id)delegate
			settingSelector : (SEL)settingSelector
				   userInfo : (void *)userInfo;

- (void)editWithUIWindow : (NSWindow *)modalForWindow
		  smartBoardItem : (BoardListItem *)smartBoardItem;

- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;

@end

// スマート掲示板の名前や条件を変更した際に通知される
extern NSString *const SBLIEditorDidEditSmartBoardListItemNotification;
