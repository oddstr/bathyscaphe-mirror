// BoardManager-SettingTxt.m

#import "BoardManager.h"
#import "BSSettingTxtDetector.h"
#import "AppDefaults.h"
#import "BoardList.h"

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

- (BOOL) startDownloadSettingTxtForBoard: (NSString *) boardName
{
	const char *hs;
	NSURL	*boardURL = [self URLForBoardName: boardName];
	
	hs = [[boardURL host] UTF8String];
	
	if (NULL == hs) return NO;
	if (!is_2channel(hs)) return NO;	

	return ([CMRPref isOnlineMode]) ? [self doDownloadSettingTxtForBoard: boardName] : [self askDownloadAndDetectNowForBoard: boardName];
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

//	[self setDefaultNoName: [infoDict_ objectForKey: kBSSTDNoNameValueKey] forBoard: board];
	[self addNoName: [infoDict_ objectForKey: kBSSTDNoNameValueKey] forBoard: board];
	[self setTypeOfBeLoginPolicy: [infoDict_ unsignedIntForKey: kBSSTDBeLoginPolicyTypeValueKey] forBoard: board];

	NSLog(@"BoardManager - Successfully set properties detected by BSSTD.");

	[detector_ release];
}
@end

@implementation BoardManager(UserListEditorCore)
- (BOOL) addCategoryOfName: (NSString *) name
{
	NSMutableDictionary *newItem_;

	if (!name) {
		NSBeep();
		return NO;
	}

	if ([[self userList] containsItemWithName: name ofType: (BoardListFavoritesItem | BoardListCategoryItem)]) {
		NSBeep();
		/*NSBeginInformationalAlertSheet(
			[self localizedString : @"Same Name Exists"],
			[self localizedString : @"OK"], nil, nil, [self window], self, NULL, NULL, nil,
			[self localizedString : @"So cannot add category."]
		);*/
		NSLog(@"Same Name Exists");
		return NO;
	}

	newItem_ = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				name, BoardPlistNameKey, [NSMutableArray array], BoardPlistContentsKey, nil];

	[[[self userList] boardItems] addObject: newItem_];
	[[self userList] postBoardListDidChangeNotification];
	return YES;
}

- (BOOL) editBoardOfName: (NSString *) boardName newURLString: (NSString *) newURLString
{
	NSMutableDictionary *newItem_;

	if (!newURLString || !boardName) {
		NSBeep();
		return NO;
	}

	newItem_ = [[self userList] itemForName: boardName ofType: BoardListBoardItem];
	UTILAssertKindOfClass(newItem_, NSMutableDictionary);

	[[self userList] item: newItem_ setName: boardName setURL: newURLString];
	return YES;
}

- (BOOL) editCategoryOfName: (NSString *) oldName newName: (NSString *) newName
{
	NSMutableDictionary *newItem_;

	if (!newName || !oldName) {
		NSBeep();
		return NO;
	}

	newItem_ = [[self userList] itemForName: oldName ofType: BoardListCategoryItem];
	UTILAssertKindOfClass(newItem_, NSMutableDictionary);

	if ([[self userList] containsItemWithName : newName ofType : (BoardListFavoritesItem | BoardListCategoryItem)] &&
		(NO == [oldName isEqualToString : newName]))
	{
/*		NSBeginInformationalAlertSheet(
			[self localizedString : @"Same Name Exists"],
			[self localizedString : @"OK"], nil, nil, [self window], self, NULL, NULL, nil,
			[self localizedString : @"So cannot change name."]
		);*/
		NSLog(@"Same Name Exists");
		return NO;
	}

	[[self userList] item: newItem_ setName: newName setURL: nil];
	return YES;
}

- (BOOL) removeItemOfIndexes: (NSIndexSet *) indexes{return NO;}
@end
