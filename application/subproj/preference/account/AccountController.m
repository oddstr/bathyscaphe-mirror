//
//  AccountController.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/11/21.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "AccountController.h"

#import "AppDefaults.h"
#import "PreferencePanes_Prefix.h"

@implementation AccountController
- (NSString *)mainNibName
{
	return @"AccountPane";
}
@end


@implementation AccountController(Toolbar)
- (NSString *)identifier
{
	return PPAccountSettingsIdentifier;
}

- (NSString *)helpKeyword
{
	return PPLocalizedString(@"Help_Account");
}

- (NSString *)label
{
	return PPLocalizedString(@"Account Label");
}

- (NSString *)paletteLabel
{
	return PPLocalizedString(@"Account Label");
}

- (NSString *)toolTip
{
	return PPLocalizedString(@"Account ToolTip");
}

- (NSString *)imageName
{
	return @"Account";
}
@end
