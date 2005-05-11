/**
  * $Id: PreferencesPane-ViewAccessor.m,v 1.1.1.1 2005/05/11 17:51:11 tsawada2 Exp $
  * 
  * PreferencesPane-ViewAccessor.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "AppDefaults.h"
#import "PreferencesPane.h"
#import "PreferencesController.h"
#import "PreferencePanes_Prefix.h"



@implementation PreferencesPane(ViewAccessor)
- (void) setupUIComponents
{
	PreferencesController *controller_;
	NSUserDefaults *defaults_;
	NSString       *identifier_;
	
	defaults_ = [NSUserDefaults standardUserDefaults];
	identifier_ = [defaults_ stringForKey : PPLastOpenPaneIdentifier];
	
	controller_ = [self controllerWithIdentifier : identifier_];
	if(nil == controller_)
		identifier_ = PPFontsAndColorsIdentifier;
	controller_ = [self controllerWithIdentifier : identifier_];
	UTILAssertNotNil(controller_);
	
	[self setContentViewWithController : controller_];
	[self setupToolbar];
}

- (void) updateUIComponents
{
	[[self controllerWithIdentifier : 
		[self currentIdentifier]] updateUIComponents];
	[[self window] setTitle : [self displayName]];
}
@end