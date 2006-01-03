//
//  SmartBoardListItemEditor.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/12/27.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BoardListItem.h"

#import "SmartBLIEditorHelper.h"

@interface SmartBoardListItemEditor : NSObject
{
	IBOutlet NSWindow *editorWindow;
	IBOutlet SmartBLIEditorHelper *helper;
	
	NSInvocation *mInvocation;

}

+ (id) editor;

// settingSelector  
//- (void) settingSelector : (BoardListItem *)item userInfo : (void *)userInfo;
- (void)cretateFromUIWindow : (NSWindow *)modalForWindow
				   delegate : (id)delegate
			settingSelector : (SEL)settingSelector
				   userInfo : (void *)userInfo;

- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;

@end
