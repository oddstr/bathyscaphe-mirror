//:TextFinder.m
/**
  *
  * @see CMRSearchOptions.h
  *
  * @author Takanori Ishikawa
  * @author http:
  * @version 1.0.0d1 (02/11/13  0:10:21 AM)
  *
  */
#import "TextFinder_p.h"


@implementation TextFinder
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(standardTextFinder);

- (id) init
{
	if (self = [super initWithWindowNibName : kLoadNibName]) {
		;
	}
	return self;
}

- (void) awakeFromNib
{
	[self setupUIComponents];
}

- (NSCell *) componentCellWithTag : (int) aTag
{ return [[self optionMatrix] cellWithTag : aTag]; }
- (BOOL) checkBoxIsOnStateWithTag : (int) aTag
{ return (NSOnState == [[self componentCellWithTag : aTag] state]); }
- (void) setCheckBoxWithTag:(int)aTag onState:(BOOL) flag
{ [[self componentCellWithTag : aTag] setState : (flag?NSOnState:NSOffState)]; }

- (IBAction) optionChanged : (id) sender
{
	CMRSearchMask		option = [self searchOption];

	[CMRPref setContentsSearchOption : option];
	[self updateComponents : sender];
}
- (CMRSearchMask) searchOption
{
	CMRSearchMask		option = 0;
	
	if (NO == [self checkBoxIsOnStateWithTag : kCaseSencitiveBtnTag]) {
		option |= CMRSearchOptionCaseInsensitive;
	}
	if (NO == [self checkBoxIsOnStateWithTag : kZenkakuHankakuBtnTag]) {
		option |= CMRSearchOptionZenHankakuInsensitive;
	}
	if ([self checkBoxIsOnStateWithTag : kInLinkOptionBtnTag]) {
		option |= CMRSearchOptionLinkOnly;
	}
	return option;
}
- (void) setSearchOption : (CMRSearchMask) aOption
{
	[self setCheckBoxWithTag : kCaseSencitiveBtnTag
			onState : NO == (aOption & CMRSearchOptionCaseInsensitive)];
	[self setCheckBoxWithTag : kZenkakuHankakuBtnTag
			onState : NO == (aOption & CMRSearchOptionZenHankakuInsensitive)];
	[self setCheckBoxWithTag : kInLinkOptionBtnTag
			onState : (aOption & CMRSearchOptionLinkOnly)];
}

- (CMRSearchOptions *) currentOperation
{
	CMRSearchMask option = [self searchOption];
	unsigned int  generalOption = 0;
	
	if (option & CMRSearchOptionCaseInsensitive)
		generalOption |= NSCaseInsensitiveSearch;
	
	return [CMRSearchOptions operationWithFindObject : 
						[[self findTextField] stringValue]
					replace : nil
					userInfo : [NSNumber numberWithUnsignedInt : option]
					option : generalOption];
}


- (IBAction) updateComponents : (id) sender
{
	[self updateButtonEnabled];
}


- (void) showWindow : (id) sender
{
	[[self window] makeKeyAndOrderFront : self];
	[[self findTextField] selectText:sender];
}

- (void) setFindString: (NSString *)aString
{
    if ( aString ) {
	[[self findTextField] setStringValue:aString];
    }
}

@end
