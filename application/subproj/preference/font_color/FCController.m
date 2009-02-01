#import "FCController.h"
#import "PreferencePanes_Prefix.h"
#import <SGAppKit/NSEvent-SGExtensions.h>
#import "BSThemeEditor.h"
#import "BSThemePreView.h"

#define kLabelKey		@"Appearance Label"
#define kToolTipKey		@"Appearance ToolTip"
#define kImageName		@"AppearancePreferences"

@implementation FCController
- (NSString *)mainNibName
{
	return @"ViewPane";
}

- (void)dealloc
{
	[m_themeEditor release];
	m_themeEditor = nil;
	[super dealloc];
}

#pragma mark Accessors
- (BSThemeEditor *)themeEditor
{
	if (!m_themeEditor) {
		m_themeEditor = [[BSThemeEditor alloc] init];
		[m_themeEditor setDelegate:self];
	}
	return m_themeEditor;
}

- (NSTableView *)themesList
{
	return m_themesList;
}

- (BSThemePreView *)preView
{
	return m_preView;
}

- (NSTextField *)themeNameField
{
	return m_themeNameField;
}

- (NSTextField *)themeStatusField
{
	return m_themeStatusField;
}

- (NSButton *)deleteButton
{
	return m_deleteBtn;
}

#pragma mark IBActions
- (IBAction)fixRowHeightToFont:(id)sender
{
	[[self preferences] fixRowHeightToFontSize];
}

- (IBAction)fixRowHeightToFontOfBoardList:(id)sender
{
	[[self preferences] fixBoardListRowHeightToFontSize];
}

- (IBAction)newTheme:(id)sender
{
	// 現在リストで選択されているテーマを下地にする
	int selectedRow = [[self themesList] selectedRow];
	NSString *filePath;
	NSString *newId;
	if (selectedRow == 0) {
		filePath = [[self preferences] defaultThemeFilePath];
		newId = PPLocalizedString(@"copiedDefaultTheme");
	} else {
		NSMutableArray *array = [NSMutableArray array];
		[[self preferences] getInstalledThemeIds:NULL fileNames:&array];
		NSString *fileName = [array objectAtIndex:selectedRow];
		filePath = [[self preferences] createFullPathFromThemeFileName:fileName];
		newId = PPLocalizedString(@"newThemeId");
	}
	BSThreadViewTheme *content = [[BSThreadViewTheme alloc] initWithContentsOfFile:filePath];
	[content setIdentifier:newId];
	BSThemeEditor *editor = [self themeEditor];

	[[editor themeGreenCube] setContent:content];
	[content release];
	[editor setSaveThemeIdentifier:newId];
	[editor setIsNewTheme:YES];
	[editor setThemeFileName:nil];
	[editor beginSheetModalForWindow:[self window] modalDelegate:self contextInfo:NULL];
}

- (IBAction)editCustomTheme:(id)sender
{
	// 現在使用中のテーマではなく、現在リストで選択されているテーマを編集する
	int selectedRow = [[self themesList] selectedRow];
	if (selectedRow == 0) {
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert setMessageText:PPLocalizedString(@"editThemeAlertTitle")];
		[alert addButtonWithTitle:PPLocalizedString(@"editThemeBtnContinue")];
		[alert addButtonWithTitle:PPLocalizedString(@"editThemeBtnCancel")];
		[alert beginSheetModalForWindow:[self window]
						  modalDelegate:self
						 didEndSelector:@selector(editThemeAlertDidEnd:returnCode:contextInfo:)
							contextInfo:(void *)sender];
		return;
	}

	NSMutableArray *array = [NSMutableArray array];
	[[self preferences] getInstalledThemeIds:NULL fileNames:&array];
	NSString *fileName = [array objectAtIndex:selectedRow];
	BSThreadViewTheme *content = [[BSThreadViewTheme alloc] initWithContentsOfFile:
		[[self preferences] createFullPathFromThemeFileName:fileName]];
	BSThemeEditor *editor = [self themeEditor];

	[[editor themeGreenCube] setContent: content];
	NSString *hoge = [[content identifier] copy];
	[editor setSaveThemeIdentifier:hoge];
	[hoge release];
	[content release];
	[editor setIsNewTheme:NO];
	[editor setThemeFileName:fileName];
	[editor beginSheetModalForWindow: [self window] modalDelegate: self contextInfo: NULL];
}

#pragma mark Delegate Methods
- (void)themeEditSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton) {
		if ([[self themeEditor] isNewTheme]) {
			[[self themesList] reloadData];
			NSMutableArray *array = [NSMutableArray array];
			[[self preferences] getInstalledThemeIds:NULL fileNames:&array];
			int idx = [array indexOfObject:[[self themeEditor] themeFileName]];
			[[self themesList] selectRow:idx byExtendingSelection:NO];
		} else {
			NSString *currentThemeFileName = [[self preferences] themeFileName];
			if (!currentThemeFileName) { // Default Theme
				// よって「使用＝デフォルト、編集したのは＝それ以外のテーマ」なので
				// AppDefaults のテーマを更新する必要は無い
				// プレビューのみ更新
				BSThreadViewTheme *newObj = [[[self themeEditor] themeGreenCube] content];
				[[self preView] setTheme:newObj];
			} else {
				if ([currentThemeFileName isEqualToString:[[self themeEditor] themeFileName]]) {
					// 使用中のテーマを編集した
					BSThreadViewTheme *newObj = [[[self themeEditor] themeGreenCube] content];
					[[self preferences] setThreadViewTheme:newObj];
					[[self preView] setTheme:newObj];
				} else {
					// 使用中ではないテーマを編集した
					BSThreadViewTheme *newObj = [[[self themeEditor] themeGreenCube] content];
					[[self preView] setTheme:newObj];
				}
			}
		}
		[self updateUIComponents];
	}

	[sheet close];
}

- (void)deleteThemeAlertDidEnd:(NSAlert *)alert returnCode:(int)code contextInfo:(void *)contextInfo
{
	if (code == NSAlertFirstButtonReturn) {
		[self deleteTheme:(NSString *)contextInfo];
	}
	[(NSString *)contextInfo release];
	[self updateUIComponents];
}

- (unsigned int)validModesForFontPanel:(NSFontPanel *)fontPanel
{
	return (NSFontPanelFaceModeMask|NSFontPanelSizeModeMask|NSFontPanelCollectionModeMask);
}

- (void)editThemeAlertDidEnd:(NSAlert *)alert returnCode:(int)code contextInfo:(void *)contextInfo
{
	if (code == NSAlertFirstButtonReturn) {
		[[alert window] orderOut:nil];
		[self newTheme:(id)contextInfo];
	}
}

- (void)selectCurrentTheme
{
	unsigned int rowIndex = 0;
	NSString *currentTheme = [[self preferences] themeFileName];
	if (currentTheme) { // Not Default Theme
//		rowIndex = [[[[self preferences] installedThemes] valueForKey:@"FileName"] indexOfObject:currentTheme];
		NSMutableArray *array = [NSMutableArray array];
		[[self preferences] getInstalledThemeIds:NULL fileNames:&array];
		rowIndex = [array indexOfObject:currentTheme];
	}
	[[self themesList] selectRow:rowIndex byExtendingSelection:NO];
}

#pragma mark Utilities
- (IBAction)themeDoubleClicked:(id)sender
{
	int clickedRow = [(NSTableView *)sender clickedRow];
	if (clickedRow == -1) return;

/*	NSString *fileNameForRow = [[[[self preferences] installedThemes] objectAtIndex:clickedRow] valueForKey:@"FileName"];
	if (![fileNameForRow isEqualToString:[[self preferences] themeFileName]]) {
		[[self preferences] setThemeFileName:fileNameForRow];
		[self updateUIComponents];
	} else {*/
		[self editCustomTheme:sender];
//	}
}
		

- (void)deleteTheme:(NSString *)fileName
{
	if (!fileName) return; // You can not delete the default theme
	BOOL serious = [[[self preferences] themeFileName] isEqualToString:fileName];
	NSString *fullPath = [[self preferences] createFullPathFromThemeFileName:fileName];
	NSFileManager *fm_ = [NSFileManager defaultManager];
	if (![fm_ fileExistsAtPath:fullPath]) return;

	if ([fm_ removeFileAtPath:fullPath handler:nil]) {
		[[self themesList] reloadData];
		if (serious) {
			[[self preferences] setThemeFileName:nil];
		}
		[self selectCurrentTheme];
	}
}

- (IBAction)tryDeleteTheme:(id)sender
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];

	NSArray *themes = [[self preferences] installedThemes];
	NSString *fileName = [[themes valueForKey:@"FileName"] objectAtIndex:[[self themesList] selectedRow]];
	NSString *title = [[themes valueForKey:@"Identifier"] objectAtIndex:[[self themesList] selectedRow]];
	BOOL	serious = [[[self preferences] themeFileName] isEqualToString: fileName];
	NSString *titleBase = serious ? PPLocalizedString(@"deleteThemeAlertSeriousTitle") : PPLocalizedString(@"deleteThemeAlertTitle");
	[alert setAlertStyle: serious ? NSCriticalAlertStyle : NSWarningAlertStyle];
	[alert setMessageText: [NSString stringWithFormat: titleBase, title]];
	[alert setInformativeText: serious ? PPLocalizedString(@"deleteThemeAlertSeriousMsg") : PPLocalizedString(@"deleteThemeAlertMsg")];
	[alert addButtonWithTitle: PPLocalizedString(@"deleteThemeBtnDelete")];
	[alert addButtonWithTitle: PPLocalizedString(@"deleteThemeBtnCancel")];
	[alert beginSheetModalForWindow: [self window]
					  modalDelegate: self
					 didEndSelector: @selector(deleteThemeAlertDidEnd:returnCode:contextInfo:)
						contextInfo: [fileName retain]];
}

- (void)setupUIComponents
{
	if (!_contentView) {
		return;
	}

	[[self themesList] setDoubleAction:@selector(themeDoubleClicked:)];
	[self updateUIComponents];
	[self selectCurrentTheme];
}

- (void)updateUIComponents
{
	[[self themesList] reloadData];
}

#pragma mark NSTableView Delegate & DataSource
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	NSMutableArray *array = [[NSMutableArray alloc] init];
	[[self preferences] getInstalledThemeIds:NULL fileNames:&array];
	int count = [array count];
	[array release];
	return count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	if ([[aTableColumn identifier] isEqualToString:@"Identifier"]) {
		NSMutableArray *array1 = [NSMutableArray array];
		[[self preferences] getInstalledThemeIds:&array1 fileNames:NULL];
		return [array1 objectAtIndex:rowIndex];
	}

	if (rowIndex == 0) { // FileName, Default Theme
		return [NSNumber numberWithBool:([[self preferences] themeFileName] == nil)];
	}

	NSMutableArray *array2 = [NSMutableArray array];
	[[self preferences] getInstalledThemeIds:NULL fileNames:&array2];
	NSString *fileNameForRow = [array2 objectAtIndex:rowIndex];
	return [NSNumber numberWithBool:[fileNameForRow isEqualToString:[[self preferences] themeFileName]]];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	if (rowIndex == 0) { // default theme
		[[self preferences] setThemeFileName:nil];
		[self updateUIComponents];
		return;
	}

	NSMutableArray *array = [[NSMutableArray alloc] init];
	[[self preferences] getInstalledThemeIds:NULL fileNames:&array];
	NSString *fileNameForRow = [[array objectAtIndex:rowIndex] retain];
	[array release];

	if (![fileNameForRow isEqualToString:[[self preferences] themeFileName]]) {
		[[self preferences] setThemeFileName:fileNameForRow];
		[fileNameForRow release];
		[self updateUIComponents];
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	int newSelectedRow = [[aNotification object] selectedRow];
	if (newSelectedRow == -1) return;
	
	if (newSelectedRow == 0) {
		[[self deleteButton] setEnabled:NO];
		BSThreadViewTheme *theme0 = [[BSThreadViewTheme alloc] initWithContentsOfFile:
			[[self preferences] defaultThemeFilePath]];
		[[self preView] setTheme:theme0];
		[[self themeNameField] setStringValue:NSLocalizedString(@"Default Theme", @"")];
		[theme0 release];
		if (![[self preferences] themeFileName]) {
			[[self themeStatusField] setStringValue:PPLocalizedString(@"themeStatusYes")];
		} else {
			[[self themeStatusField] setStringValue:PPLocalizedString(@"themeStatusNo")];
		}
	} else {
		[[self deleteButton] setEnabled:YES];

		NSMutableArray *array = [NSMutableArray array];
		[[self preferences] getInstalledThemeIds:NULL fileNames:&array];
		NSString *fileNameForRow = [array objectAtIndex:newSelectedRow];
		BSThreadViewTheme *theme = [[BSThreadViewTheme alloc] initWithContentsOfFile:
			[[self preferences] createFullPathFromThemeFileName:fileNameForRow]];
		[[self preView] setTheme:theme];
		[[self themeNameField] setStringValue:[theme identifier]];
		[theme release];
		if (![fileNameForRow isEqualToString:[[self preferences] themeFileName]]) {
			[[self themeStatusField] setStringValue:PPLocalizedString(@"themeStatusNo")];
		} else {
			[[self themeStatusField] setStringValue:PPLocalizedString(@"themeStatusYes")];
		}
	}
}

- (int) mailFieldOption
{
	BOOL	_mailAddressShown = [[self preferences] mailAddressShown];
	BOOL	_mailIconShown = [[self preferences] mailAttachmentShown];
	
	if (_mailAddressShown && _mailIconShown)
		return 1;
	else if (_mailAddressShown)
		return 0;
	else
		return 2;
}

- (void) setMailFieldOption : (int) selectedTag
{
	
	switch(selectedTag) {
	case 0:
		[[self preferences] setMailAddressShown : YES];
		[[self preferences] setMailAttachmentShown : NO];
		break;
	case 1:
		[[self preferences] setMailAddressShown : YES];
		[[self preferences] setMailAttachmentShown : YES];
		break;
	case 2:
		[[self preferences] setMailAddressShown : NO];
		[[self preferences] setMailAttachmentShown : YES];
		break;
	default:
		break;
	}
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
