#import "FCController.h"
#import "PreferencePanes_Prefix.h"

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
	[m_saveThemeIdentifier release];
	m_saveThemeIdentifier = nil;
	[super dealloc];
}

- (NSString *) saveThemeIdentifier
{
	return m_saveThemeIdentifier;
}

- (void) setSaveThemeIdentifier: (NSString *) aString
{
	[aString retain];
	[m_saveThemeIdentifier release];
	m_saveThemeIdentifier = aString;
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
	BSThreadViewTheme *object_ = [[[self preferences] threadViewTheme] copy];
	[m_themeGreenCube setContent: object_];
	[object_ release];
	[NSApp beginSheet: m_themeEditSheet
	   modalForWindow: [self window]
		modalDelegate: self
	   didEndSelector: @selector(themeEditSheetDidEnd:returnCode:contextInfo:) 
		  contextInfo: NULL];
}

- (void) themeEditSheetDidEnd: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo
{
	[sheet close];

	if (returnCode == NSOKButton) {
		BSThreadViewTheme *newObj = [m_themeGreenCube content];
		NSString *themeFilePath = [[self preferences] customThemeFilePath];
		[newObj setIdentifier: kThreadViewThemeCustomThemeIdentifier];

		if (NO == [newObj writeToFile: themeFilePath atomically: YES]) {
			NSLog(@"Fail to save file.");
		} else {
			[[self preferences] setUsesCustomTheme: YES];
			[[self preferences] setThemeFileName: nil];
		}
	}
	[m_themeGreenCube setContent: nil];
	[self updateUIComponents];
}

- (IBAction) chooseTheme: (id) sender
{
	[[self preferences] setUsesCustomTheme: NO];
	[[self preferences] setThemeFileName: [sender representedObject]];
}

- (IBAction) chooseDefaultTheme: (id) sender
{
	[[self preferences] setUsesCustomTheme: NO];
	[[self preferences] setThemeFileName: nil];
}

- (IBAction) closePanelAndUseTagForReturnCode: (id) sender
{
	if ([sender window] == m_themeEditSheet) {
		[NSApp endSheet: [sender window] returnCode: [sender tag]];
	} else if ([sender window] == m_themeNameSheet) {
		[NSApp stopModalWithCode: [sender tag]];
		[[sender window] close];
	}
}

- (IBAction) saveTheme: (id) sender
{
	int returnCode = [NSApp runModalForWindow: m_themeNameSheet];

	if (returnCode == NSOKButton) {
		int myReturnCode = 3;
		NSString *fileName = [NSString stringWithFormat: @"UserTheme%.0f.plist", [[NSDate date] timeIntervalSince1970]];
		NSString *filePath = [[[[CMRFileManager defaultManager] supportDirectoryWithName: BSThemesDirectory] filepath]
								stringByAppendingPathComponent: fileName];
		[[m_themeGreenCube content] setIdentifier: [self saveThemeIdentifier]];
		if ([[m_themeGreenCube content] writeToFile: filePath atomically: YES]) {
			[[self preferences] setUsesCustomTheme: NO];
			[[self preferences] setThemeFileName: fileName];
			[self addMenuItemOfTitle: [self saveThemeIdentifier] representedObject: fileName atIndex: 1];
		} else {
			NSBeep();
			NSLog(@"Failed to save theme file %@", filePath);
			myReturnCode = NSCancelButton;
		}
		[NSApp endSheet: m_themeEditSheet returnCode: myReturnCode];//NSOKButton];
	}
}

- (unsigned int) validModesForFontPanel : (NSFontPanel *) fontPanel
{
	return (NSFontPanelFaceModeMask|NSFontPanelSizeModeMask|NSFontPanelCollectionModeMask);
}

- (void) addMenuItemOfTitle: (NSString *) identifier representedObject: (NSString *) filepath atIndex: (unsigned int) index
{
	NSMenu *menu_ = [m_themesChooser menu];
	NSMenuItem *item_;

	item_ = [[NSMenuItem alloc] initWithTitle: identifier action: @selector(chooseTheme:) keyEquivalent: @""];
	[item_ setRepresentedObject: filepath];
	[item_ setTarget: self];
	[menu_ insertItem: item_ atIndex: 1];
	[item_ release];
}

- (void) setUpMenu
{
//	NSMenu *menu_ = [m_themesChooser menu];

	NSDirectoryEnumerator	*tmpEnum;
	NSString		*file;
	NSString		*fullpath;
//	NSMenuItem *item;

	NSString *themeDir = [[[CMRFileManager defaultManager] supportDirectoryWithName: BSThemesDirectory] filepath];
    if (themeDir) {
		tmpEnum = [[NSFileManager defaultManager] enumeratorAtPath : themeDir];

		while (file = [tmpEnum nextObject]) {
			if ([[file pathExtension] isEqualToString: @"plist"]) {
				fullpath = [themeDir stringByAppendingPathComponent: file];
				BSThreadViewTheme *theme = [[BSThreadViewTheme alloc] initWithContentsOfFile: fullpath];
				if (!theme) continue;

				NSString *id_ = [theme identifier];
				if ([id_ isEqualToString: kThreadViewThemeCustomThemeIdentifier]) continue;
/*
				item = [[NSMenuItem alloc] initWithTitle: id_ action: @selector(chooseTheme:) keyEquivalent: @""];
				[item setRepresentedObject: file];
				[item setTarget: self];

				[menu_ insertItem: item atIndex: 1];
				[item release];*/
				[self addMenuItemOfTitle: id_ representedObject: file atIndex: 1];

				[theme release];
			}
		}
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
	NSString *tmp_;

	tmp_ = [[self preferences] themeFileName];
	if(!tmp_ || [tmp_ isEqualToString : @""]) {
		BOOL useCustom = [[self preferences] usesCustomTheme];
		if (useCustom && [[NSFileManager defaultManager] fileExistsAtPath: [[self preferences] customThemeFilePath]]) {
			[m_themesChooser selectItemWithTag: -1];
		} else {
			[m_themesChooser selectItemWithTag: 1];
		}
	} else {
		NSString *filePath = [[self preferences] createFullPathFromThemeFileName: tmp_];
		if([[NSFileManager defaultManager] fileExistsAtPath: filePath]) {
			[m_themesChooser selectItemAtIndex: [m_themesChooser indexOfItemWithRepresentedObject: tmp_]];
		} else {
			[m_themesChooser selectItemWithTag: 1];
		}
	}

	[m_themesChooser synchronizeTitleAndSelectedItem];
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
