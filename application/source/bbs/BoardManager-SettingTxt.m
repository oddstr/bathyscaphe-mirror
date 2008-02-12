// BoardManager-SettingTxt.m

#import "BoardManager.h"
#import "BSSettingTxtDetector.h"
#import "AppDefaults.h"
#import "SmartBoardList.h"
#import "BSBoardInfoInspector.h"
#import "DatabaseManager.h"
#import "BSLocalRulesCollector.h"
#import "BSLocalRulesPanelController.h"

NSString *const BoardManagerDidFinishDetectingSettingTxtNotification = @"BoardManagerDidFinishDetectingSettingTxtNotification";

@implementation BoardManager(SettingTxtDetector)
- (BOOL) doDownloadSettingTxtForBoard: (NSString *) boardName
{
	NSURL	*boardURL = [self URLForBoardName: boardName];
	NSString	*URLStr_ = [boardURL absoluteString];
	NSURL	*settingTxtURL = [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", URLStr_, @"SETTING.TXT"]];

	//NSLog(@"%@",[settingTxtURL absoluteString]);
	BSSettingTxtDetector	*detector_ = [[BSSettingTxtDetector alloc] initWithBoardName: boardName settingTxtURL: settingTxtURL];

	[[NSNotificationCenter defaultCenter]
	  addObserver : self
	     selector : @selector(detectorDidFinish:)
	         name : BSSettingTxtDetectorDidFinishNotification
	       object : detector_];
	[[NSNotificationCenter defaultCenter]
	  addObserver : self
	     selector : @selector(detectorDidFail:)
	         name : BSSettingTxtDetectorDidFailNotification
	       object : detector_];

	[detector_ startDownloadingSettingTxt];
	
	return YES;
}

- (BOOL) askDownloadAndDetectNowForBoard: (NSString *) boardName
{
    int ret;
	
	NSAlert *alert_ = [[NSAlert alloc] init];
	[alert_ setAlertStyle: NSInformationalAlertStyle];
	[alert_ setMessageText: [NSString stringWithFormat: NSLocalizedString(@"DetectorTitle", nil), boardName]];
	[alert_ setInformativeText : NSLocalizedString(@"DetectorMessage", nil)];
	[alert_ addButtonWithTitle : NSLocalizedString(@"DetectOK", nil)];
	[alert_ addButtonWithTitle : NSLocalizedString(@"DetectCancel", nil)];
	[alert_ addButtonWithTitle : NSLocalizedString(@"DetectManually", nil)];
	[alert_ setHelpAnchor : NSLocalizedString(@"DetectNoNameHelpAnchor", nil)];
	[alert_ setShowsHelp : YES];
	
    ret = [alert_ runModal];
	[alert_ release];

	if (ret == NSAlertFirstButtonReturn) {
        return [self doDownloadSettingTxtForBoard: boardName];
    } else if (ret == NSAlertSecondButtonReturn) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)startDownloadSettingTxtForBoard:(NSString *)boardName askIfOffline:(BOOL)flag
{
	const char *hs;
	NSURL	*boardURL = [self URLForBoardName:boardName];
	
	hs = [[boardURL host] UTF8String];
	
	if (NULL == hs) return NO;
	if (!is_2channel(hs)) return NO;	

	if (![CMRPref isOnlineMode] && flag) {
		return [self askDownloadAndDetectNowForBoard:boardName];
	}
	return [self doDownloadSettingTxtForBoard:boardName];
}

#pragma mark BSSettingTxtDetector Notifications
- (void) detectorDidFail: (NSNotification *) aNotification
{
	//NSLog(@"BoardManager: Received BSSettingTxtDetectorDidFailNotification");
	id	detector_ = [aNotification object];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: BSSettingTxtDetectorDidFailNotification
												  object: detector_];

	[detector_ release];
	UTILNotifyName(BoardManagerDidFinishDetectingSettingTxtNotification);
}

- (void) detectorDidFinish: (NSNotification *) aNotification
{
	//NSLog(@"BoardManager: Received BSSettingTxtDetectorDidFinishNotification");
	NSDictionary	*infoDict_ = [aNotification userInfo];
	id				detector_ = [aNotification object];

	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: BSSettingTxtDetectorDidFinishNotification
												  object: detector_];

	NSString *board = [infoDict_ objectForKey: kBSSTDBoardNameKey];

	[self addNoName: [infoDict_ objectForKey: kBSSTDNoNameValueKey] forBoard: board];
	[self setTypeOfBeLoginPolicy: [infoDict_ unsignedIntForKey: kBSSTDBeLoginPolicyTypeValueKey] forBoard: board];
	[self setAllowsNanashi: [infoDict_ boolForKey: kBSSTDAllowsNanashiBoolValueKey] atBoard: board];

	NSLog(@"BoardManager - Successfully set properties detected by BSSTD.");

	[detector_ release];
	UTILNotifyName(BoardManagerDidFinishDetectingSettingTxtNotification);
}
@end

@implementation BoardManager(UserListEditorCore)
- (int) showSameNameExistsAlert: (NSString *) messageString
{
	int returnValue;
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setAlertStyle: NSWarningAlertStyle];
	[alert setInformativeText: messageString];
	[alert setMessageText: NSLocalizedString(@"Same Name Exists", @"Same Name Exists")];
	[alert addButtonWithTitle: NSLocalizedString(@"Cancel", @"Cancel")];

	NSBeep();
	returnValue = [alert runModal];
	[alert release];
	
	return returnValue;
}

- (BOOL) addCategoryOfName: (NSString *) name
{
	BoardListItem *newItem_;

	if (!name) {
		NSBeep();
		return NO;
	}

	if ([[self userList] containsItemWithName: name ofType: (BoardListFavoritesItem | BoardListCategoryItem)]) {
		[self showSameNameExistsAlert: NSLocalizedString(@"So cannot add category.", @"So cannot add category.")];
		return NO;
	}

	newItem_ = [BoardListItem boardListItemWithFolderName:name];

	[[self userList] addItem: newItem_ afterObject: nil];
//	[[self userList] postBoardListDidChangeNotification];
	return YES;
}

- (BOOL)editBoardItem:(id)item newURLString:(NSString *)newURLString
{
	if (!newURLString || !item) {
		NSBeep();
		return NO;
	}

	[[BSBoardInfoInspector sharedInstance] willChangeValueForKey:@"boardURLAsString"];
	[[self defaultList] setURL:newURLString toItem:item];
	[[self userList] setURL:newURLString toItem:item];
	[[BSBoardInfoInspector sharedInstance] didChangeValueForKey:@"boardURLAsString"];
	return YES;
}

- (BOOL)editCategoryItem:(id)item newName:(NSString *)newName
{
	UTILAssertNotNil(item);
	UTILAssertNotNil(newName);

	UTILAssertKindOfClass(item, BoardListItem);

	if ([[item representName] isEqualToString:newName]) {
		// Nothing to do.
		return YES;
	}

	if ([[self userList] containsItemWithName:newName ofType:(BoardListFavoritesItem | BoardListCategoryItem)]) {
		[self showSameNameExistsAlert:NSLocalizedString(@"So cannot change name.", @"So cannot change name.")];
		return NO;
	}

	[[self userList] item:item setName:newName setURL:nil];
	return YES;
}

- (BOOL)removeBoardItems:(NSArray *)boardItemsForRemoval
{		
	if (!boardItemsForRemoval || [boardItemsForRemoval count] == 0) return NO;
	
	NSEnumerator	*iter_ = [boardItemsForRemoval objectEnumerator];
	id				eachItem;

	while (eachItem = [iter_ nextObject]) {
		if (![BoardListItem isFavoriteItem:eachItem]) {
			[[self userList] removeItem:eachItem];
		}
	}

	return YES;
}
@end


@implementation BoardManager(LocalRules)
- (NSMutableArray *)localRulesPanelControllers
{
	if (!m_localRulesPanelControllers) {
		CFArrayCallBacks arrayCallBacks = kCFTypeArrayCallBacks;
		arrayCallBacks.retain = NULL;
		arrayCallBacks.release = NULL;
		m_localRulesPanelControllers = (NSMutableArray *)CFArrayCreateMutable(NULL, 0, &arrayCallBacks);
	}
	return m_localRulesPanelControllers;
}

- (BSLocalRulesPanelController *)makeLocalRulesPanelControllerForBoardName:(NSString *)boardName
{
	BSLocalRulesPanelController *controller;
	controller = [[BSLocalRulesPanelController alloc] init]; // Do not release!
	
	if (controller) {
		BSLocalRulesCollector	*collector;

		[[controller window] setDelegate:self];

		collector = [[BSLocalRulesCollector alloc] initWithBoardName:boardName];
		[[controller objectController] setContent:collector];
		[collector release];

		[[self localRulesPanelControllers] addObject:controller];
	}

	return controller;
}

- (BSLocalRulesPanelController *)localRulesPanelControllerForBoardName:(NSString *)boardName
{
	NSEnumerator	*iter;
	BSLocalRulesPanelController *controller;

	iter = [[self localRulesPanelControllers] objectEnumerator];
	while (controller = [iter nextObject]) {
		id collector = [[controller objectController] content];
		if ([[collector boardName] isEqualToString:boardName]) {
			return controller;
		}
	}

	return [self makeLocalRulesPanelControllerForBoardName:boardName];
}

- (BOOL)isKeyWindowForBoardName:(NSString *)boardName
{
	NSEnumerator	*iter;
	BSLocalRulesPanelController *controller;

	iter = [[self localRulesPanelControllers] objectEnumerator];
	while (controller = [iter nextObject]) {
		id collector = [[controller objectController] content];
		if ([[collector boardName] isEqualToString:boardName]) {
			return [[controller window] isKeyWindow];
		}
	}
	return NO;
}

- (void)windowWillClose:(NSNotification *)notification
{
	NSWindow *window = [notification object];
	id windowController = [window windowController];

	[[self localRulesPanelControllers] removeObjectIdenticalTo:windowController];
	[windowController autorelease];
}
@end
