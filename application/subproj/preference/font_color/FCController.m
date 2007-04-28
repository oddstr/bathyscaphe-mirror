#import "FCController.h"
#import "PreferencePanes_Prefix.h"
#import <SGAppKit/NSEvent-SGExtensions.h>
#import "BSThemeEditor.h"

#define kLabelKey		@"Appearance Label"
#define kToolTipKey		@"Appearance ToolTip"
#define kImageName		@"AppearancePreferences"

@implementation FCController
- (NSString *) mainNibName
{
	return @"ViewPane";
}

- (void) dealloc
{
	[m_themeEditor release];
	m_themeEditor = nil;
	[super dealloc];
}

#pragma mark Accessors
- (BSThemeEditor *) themeEditor
{
	if (m_themeEditor == nil) {
		m_themeEditor = [[BSThemeEditor alloc] init];
		[m_themeEditor setDelegate: self];
	}
	return m_themeEditor;
}

- (NSPopUpButton *) themesChooser
{
	return m_themesChooser;
}

#pragma mark IBActions
- (IBAction) fixRowHeightToFont : (id) sender
{
	[[self preferences] fixRowHeightToFontSize];
}

- (IBAction) fixRowHeightToFontOfBoardList : (id) sender
{
	[[self preferences] fixBoardListRowHeightToFontSize];
}

- (IBAction) editCustomTheme: (id) sender
{
	BSThreadViewTheme *content = [[[self preferences] threadViewTheme] copy];
	BSThemeEditor *editor = [self themeEditor];

	[[editor themeGreenCube] setContent: content];
	[editor beginSheetModalForWindow: [self window] modalDelegate: self contextInfo: NULL];
}

- (IBAction) chooseTheme: (id) sender
{
	if ([NSEvent currentCarbonModifierFlags] & NSCommandKeyMask) {
		[self tryDeleteTheme: sender];
	} else {
		[[self preferences] setUsesCustomTheme: NO];
		[[self preferences] setThemeFileName: [sender representedObject]];
	}
}

- (IBAction) chooseDefaultTheme: (id) sender
{
	[[self preferences] setUsesCustomTheme: NO];
	[[self preferences] setThemeFileName: nil];
}

#pragma mark Delegate Methods
- (void) themeEditSheetDidEnd: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo
{
	NSObjectController *cube = [[self themeEditor] themeGreenCube];
	[sheet close];

	if (returnCode == NSOKButton) {
		BSThreadViewTheme *newObj = [cube content];
		NSString *themeFilePath = [[self preferences] customThemeFilePath];
		[newObj setIdentifier: kThreadViewThemeCustomThemeIdentifier];

		if (NO == [newObj writeToFile: themeFilePath atomically: YES]) {
			NSLog(@"Fail to save file.");
		} else {
			[[self preferences] setUsesCustomTheme: YES];
			[[self preferences] setThemeFileName: nil];
		}
	}
	[cube setContent: nil];
	[[self themeEditor] setSaveThemeIdentifier: nil];
	[self updateUIComponents];
}

- (void) deleteThemeAlertDidEnd: (NSAlert *) alert returnCode: (int) code contextInfo: (void *) contextInfo
{
	if (code == NSAlertFirstButtonReturn) {
		[self deleteTheme: (NSString *)contextInfo];
	}
	[(NSString *)contextInfo release];
	[self updateUIComponents];
}

- (unsigned int) validModesForFontPanel : (NSFontPanel *) fontPanel
{
	return (NSFontPanelFaceModeMask|NSFontPanelSizeModeMask|NSFontPanelCollectionModeMask);
}

- (void) addAndSelectSavedThemeOfTitle: (NSString *) title fileName: (NSString *) fileName
{
	[[self preferences] setUsesCustomTheme: NO];
	[[self preferences] setThemeFileName: fileName];
	[self addMenuItemOfTitle: title representedObject: fileName atIndex: 1];
}

#pragma mark Utilities
- (void) deleteTheme: (NSString *) fileName
{
	if (!fileName) return;
	BOOL	serious = [[[self preferences] themeFileName] isEqualToString: fileName];
	NSString *fullPath = [[self preferences] createFullPathFromThemeFileName: fileName];
	NSFileManager *fm_ = [NSFileManager defaultManager];
	if (NO == [fm_ fileExistsAtPath: fullPath]) return;

	if ([fm_ removeFileAtPath: fullPath handler: nil]) {
		int	i = [[self themesChooser] indexOfItemWithRepresentedObject: fileName];
		if (i != -1) {
			[[self themesChooser] removeItemAtIndex: i];
		}
		if (serious) {
			[self chooseDefaultTheme: nil];
		}
	}
}

- (void) tryDeleteTheme: (id) sender
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	NSString *fileName = [sender representedObject];
	BOOL	serious = [[[self preferences] themeFileName] isEqualToString: fileName];
	NSString *titleBase = serious ? PPLocalizedString(@"deleteThemeAlertSeriousTitle") : PPLocalizedString(@"deleteThemeAlertTitle");
	[alert setAlertStyle: serious ? NSCriticalAlertStyle : NSWarningAlertStyle];
	[alert setMessageText: [NSString stringWithFormat: titleBase, [sender title]]];
	[alert setInformativeText: serious ? PPLocalizedString(@"deleteThemeAlertSeriousMsg") : PPLocalizedString(@"deleteThemeAlertMsg")];
	[alert addButtonWithTitle: PPLocalizedString(@"deleteThemeBtnDelete")];
	[alert addButtonWithTitle: PPLocalizedString(@"deleteThemeBtnCancel")];
	[alert beginSheetModalForWindow: [self window]
					  modalDelegate: self
					 didEndSelector: @selector(deleteThemeAlertDidEnd:returnCode:contextInfo:)
						contextInfo: [fileName retain]];
}

- (void) addMenuItemOfTitle: (NSString *) identifier representedObject: (NSString *) filepath atIndex: (unsigned int) index
{
	NSMenu *menu_ = [[self themesChooser] menu];
	NSMenuItem *item_;

	item_ = [[NSMenuItem alloc] initWithTitle: identifier action: @selector(chooseTheme:) keyEquivalent: @""];
	[item_ setRepresentedObject: filepath];
	[item_ setTarget: self];
	[menu_ insertItem: item_ atIndex: 1];
	[item_ release];
}

- (void) setUpMenu
{
	NSEnumerator *iter;
	NSArray *array = [[self preferences] installedThemes];
	NSDictionary *eachItem;

	iter = [array objectEnumerator];
	while (eachItem = [iter nextObject]) {
		[self addMenuItemOfTitle: [eachItem objectForKey: @"Identifier"] representedObject: [eachItem objectForKey: @"FileName"] atIndex: 1];
	}
}

- (void) setupUIComponents
{
	if (nil == _contentView)
		return;

	[self setUpMenu];
	[self updateUIComponents];
}

- (void) updateUIComponents
{
	NSPopUpButton *chooser_ = [self themesChooser];
	NSString *tmp_;

	tmp_ = [[self preferences] themeFileName];
	if(!tmp_ || [tmp_ isEqualToString : @""]) {
		BOOL useCustom = [[self preferences] usesCustomTheme];
		if (useCustom && [[NSFileManager defaultManager] fileExistsAtPath: [[self preferences] customThemeFilePath]]) {
			[chooser_ selectItemAtIndex: [chooser_ indexOfItemWithTag: -1]];
		} else {
			[chooser_ selectItemAtIndex: [chooser_ indexOfItemWithTag: 1]];
		}
	} else {
		NSString *filePath = [[self preferences] createFullPathFromThemeFileName: tmp_];
		if([[NSFileManager defaultManager] fileExistsAtPath: filePath]) {
			[chooser_ selectItemAtIndex: [chooser_ indexOfItemWithRepresentedObject: tmp_]];
		} else {
			[chooser_ selectItemAtIndex: [chooser_ indexOfItemWithTag: 1]];
		}
	}

	[chooser_ synchronizeTitleAndSelectedItem];
}
@end

@implementation FCController(Toolbar)
- (NSString *) identifier
{
	return PPFontsAndColorsIdentifier;
}
- (NSString *) helpKeyword
{
	return PPLocalizedString(@"Help_View");
}
- (NSString *) label
{
	return PPLocalizedString(kLabelKey);
}
- (NSString *) paletteLabel
{
	return PPLocalizedString(kLabelKey);
}
- (NSString *) toolTip
{
	return PPLocalizedString(kToolTipKey);
}
- (NSString *) imageName
{
	return kImageName;
}
@end
