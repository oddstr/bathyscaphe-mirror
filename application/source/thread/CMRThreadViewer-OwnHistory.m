/*
 * $Id: CMRThreadViewer-OwnHistory.m,v 1.15 2007/12/11 17:09:37 tsawada2 Exp $
 *
 * それぞれのスレッドビューア内での履歴（グローバルな履歴と一致するとは限らない）の管理と移動アクションのサポート
 * CMRThreadViewer.m から分割
 *
 */

#import "CMRThreadViewer_p.h"
#import "CMRHistoryManager.h"
#import "DatabaseManager.h"
@class BSSegmentedControlTbItem;

@implementation CMRThreadViewer(History)
- (id) threadIdentifierFromHistoryWithRelativeIndex : (int) relativeIndex
{
	NSArray		*historyItems_ = [self threadHistoryArray];
	unsigned	historyIndex_  = [self historyIndex];
	unsigned	historyCount_  = [historyItems_ count];
	int			newIndex_;
	
	if (NSNotFound == historyIndex_ || 0 == historyCount_)
		return nil;
	
	newIndex_ = historyIndex_;
	newIndex_ += relativeIndex;
	
	if (newIndex_ >= 0 && newIndex_ < historyCount_)
		return [historyItems_ objectAtIndex : newIndex_];
	
	return nil;
}

- (BOOL) performHistoryWithRelativeIndex : (int) relativeIndex
{
	id		threadIdentifier_;
	
	threadIdentifier_ = [self threadIdentifierFromHistoryWithRelativeIndex : relativeIndex];
	if (nil == threadIdentifier_)
		return NO;
	
	// 「戻る／進む」では自身の履歴リストに登録せず、
	// 代わりに履歴を移動
	[self setThreadContentWithThreadIdentifier:threadIdentifier_ noteHistoryList:relativeIndex];
	return YES;
}

// 連続したエントリを削除
- (void) compactThreadHistoryItems
{
	NSMutableArray	*items_;
	int				i;
	id				prev_ = nil;
	
	items_ = [self threadHistoryArray];
	for (i = [items_ count] -1; i >= 0; i--) {
		id	object_;
		
		object_ = [items_ objectAtIndex : i];
		// 連続
		if ([object_ isEqual : prev_]) {
			[items_ removeObjectAtIndex : i];
			continue;
		}
		prev_ = object_;
	}
}
- (void) noteHistoryThreadChanged : (int) relativeIndex
{
	NSMutableArray	*items_;
	unsigned		historyIndex_;
	unsigned		historyCount_;
	int				newIndex_;
	
	items_ = [self threadHistoryArray];
	historyIndex_ = [self historyIndex];
	historyCount_ = [items_ count];
	if (0 == relativeIndex) {
		id				identifier_;
		
		// 登録
		identifier_ = [self threadIdentifier];
		if (nil == identifier_)
			return;
		
		if (NSNotFound == historyIndex_ || historyIndex_ == (historyCount_ -1)) {
			[items_ addObject : identifier_];
			historyCount_ = [items_ count];
			newIndex_ = historyCount_ -1;
		} else {
			newIndex_ = historyIndex_ +1;
			
			[items_ insertObject:identifier_ atIndex:newIndex_];
			historyCount_ = [items_ count];
		}
		
		// 連続したエントリは削除し、インデックスを修正
		[self compactThreadHistoryItems];
		newIndex_ = [items_ indexOfObject : identifier_];
		
		
	} else {
		// 移動
		if (NSNotFound == historyIndex_) return;
		
		newIndex_ = historyIndex_ + relativeIndex;
		if (newIndex_ < 0) newIndex_ = 0;
		if (newIndex_ >= historyCount_) newIndex_ = historyCount_ -1;
	}
	
	[self setHistoryIndex : newIndex_];
}
- (void) clearThreadHistories
{
	[self setHistoryIndex : NSNotFound];
	[[self threadHistoryArray] removeAllObjects];
	
}

#pragma mark Accessors
// No History --> NSNotFound
- (unsigned) historyIndex
{
	return _historyIndex;
}
- (void) setHistoryIndex : (unsigned) aHistoryIndex
{
	_historyIndex = aHistoryIndex;
}

// History: ThreadSignature...
- (NSMutableArray *) threadHistoryArray
{
	if (nil == _history) {
		_history = [[NSMutableArray alloc] init];
		[self setHistoryIndex : NSNotFound];
	}
	
	return _history;
}

#pragma mark App Reset Notification
/*- (void) applicationWillReset : (NSNotification *) theNotification
{
	;
}*/
- (void) applicationDidReset : (NSNotification *) theNotification
{
	// 履歴を一旦消去し、現在表示中のスレッドを追加。
	[self clearThreadHistories];
	[self noteHistoryThreadChanged : 0];
}

#pragma mark IBAction
- (IBAction) historyMenuPerformForward : (id) sender
{
	[self performHistoryWithRelativeIndex : 1];
}
- (IBAction) historyMenuPerformBack : (id) sender
{
	[self performHistoryWithRelativeIndex : -1];
}
- (IBAction) historyMenuPerformGo:(id)sender
{
	NSNumber *foo = [sender representedObject];
	NSLog(@"Go to %i",[foo intValue]);
	[self performHistoryWithRelativeIndex:[foo intValue]];
}

- (IBAction) historySegmentedControlPushed : (id) sender
{
	int	i;
	i = [sender selectedSegment];

	if (i == -1) {
		NSLog(@"No selection?");
	} else if (i == 1) {
		[self historyMenuPerformForward : nil];
	} else {
		[self historyMenuPerformBack : nil];
	}
}

#pragma mark BSSegmentedControlTbItem delegate
- (BOOL) segCtrlTbItem: (BSSegmentedControlTbItem *) item
	   validateSegment: (int) segment
{
//	if (![[self window] isKeyWindow]) return NO;
	if ([[item itemIdentifier] isEqualToString: @"scaleSC"]) return [self validateUserInterfaceItem: item];

	if (![self shouldShowContents])
		return NO;

	int relativeIdx;

	if (segment == 0)
		relativeIdx = -1;
	else if (segment == 1)
		relativeIdx = 1;
	else
		return NO;

	return ([self threadIdentifierFromHistoryWithRelativeIndex: relativeIdx] != nil);
}

- (void)removeAllItemsInMenu:(NSMenu *)menu
{
	int		i, cnt;
	
	cnt = [menu numberOfItems];
	for(i = (cnt -1); i >= 0; i--){
		[menu removeItemAtIndex:i];
	}
}

- (void)menuNeedsUpdate:(NSMenu *)menu
{
	if ([menu delegate] != self) return;

	NSString *menuTitle = [menu title];

	if ([menuTitle isEqualToString:@"Back"]) {
//		[menu removeAllItems];
		[self removeAllItemsInMenu:menu];

		int currentIndex = [self historyIndex];
		int i;
		NSRange range = NSMakeRange(0, currentIndex);
		NSArray *hoge = [[self threadHistoryArray] subarrayWithRange:range];
//		NSEnumerator *iter = [hoge reverseObjectEnumerator];
		id foo;
		NSMenuItem *item;
		DatabaseManager *dbManager = [DatabaseManager defaultManager];
//		while (foo = [iter nextObject]) {
		for (i=currentIndex; i>0; i--) {
			foo = [hoge objectAtIndex:i-1];
			NSString *bar = [dbManager threadTitleFromBoardName:[foo boardName] threadIdentifier:[foo identifier]];
//			[menu addItemWithTitle:bar action:@selector(historyMenuPerformBack:)keyEquivalent:@""];
			item = [[NSMenuItem alloc] initWithTitle:bar action:@selector(historyMenuPerformGo:) keyEquivalent:@""];
			[item setRepresentedObject:[NSNumber numberWithInt:(i-currentIndex-1)]];
			[menu addItem:item];
			[item release];
		}
	} else if ([menuTitle isEqualToString:@"Forward"]) {
//		[menu removeAllItems];
		[self removeAllItemsInMenu:menu];

		int currentIndex = [self historyIndex];
		int	i;
		NSRange range = NSMakeRange(currentIndex+1, [[self threadHistoryArray] count]-currentIndex-1);
		NSArray *hoge = [[self threadHistoryArray] subarrayWithRange:range];
//		NSEnumerator *iter = [hoge objectEnumerator];
		id foo;
		NSMenuItem *aho;
		DatabaseManager *dbManager = [DatabaseManager defaultManager];
//		while (foo = [iter nextObject]) {
		for (i=0; i<range.length; i++) {
			foo = [hoge objectAtIndex:i];
			NSString *bar = [dbManager threadTitleFromBoardName:[foo boardName] threadIdentifier:[foo identifier]];
			aho = [[NSMenuItem alloc] initWithTitle:bar action:@selector(historyMenuPerformGo:) keyEquivalent:@""];
			[aho setRepresentedObject:[NSNumber numberWithInt:(i+1)]];
//			[menu addItemWithTitle:bar action:@selector(historyMenuPerformForward:)keyEquivalent:@""];
			[menu addItem:aho];
			[aho release];
		}
	}
}
@end
