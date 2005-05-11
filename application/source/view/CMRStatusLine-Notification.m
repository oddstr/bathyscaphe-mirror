/**
  * $Id: CMRStatusLine-Notification.m,v 1.1.1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * CMRStatusLine-Notification.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRStatusLine_p.h"

#import "missing.h"
#import "CMRHistoryManager.h"
#import "CMRMainMenuManager.h" 



@interface NSObject(CMRStatusLineDelegationStub)
- (id) boardIdentifier;
- (id) threadIdentifier;
- (IBAction) focus : (id) sender;
@end



@implementation CMRStatusLine(Notification)
- (void) registerToNotificationCenter
{
    [[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(taskWillStartNotification:)
                name : CMRTaskWillStartNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(taskWillProgressNotification:)
                name : CMRTaskWillProgressNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(taskDidFinishNotification:)
                name : CMRTaskDidFinishNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(appDefaultsLayoutSettingsUpdated:)
                name : AppDefaultsLayoutSettingsUpdatedNotification
              object : CMRPref];
    [[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(applicationWillReset:)
                name : CMRApplicationWillResetNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(applicationDidReset:)
                name : CMRApplicationDidResetNotification
              object : nil];
    
    [super registerToNotificationCenter];
}
- (void) removeFromNotificationCenter
{
    [[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : CMRTaskWillStartNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : CMRTaskWillProgressNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : CMRTaskDidFinishNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : AppDefaultsLayoutSettingsUpdatedNotification
              object : CMRPref];
    [[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : CMRApplicationWillResetNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : CMRApplicationDidResetNotification
              object : nil];

    [super removeFromNotificationCenter];
}

- (void) appDefaultsLayoutSettingsUpdated : (NSNotification *) theNotification
{
    UTILAssertNotificationName(
        theNotification,
        AppDefaultsLayoutSettingsUpdatedNotification);
    UTILAssertNotificationObject(
        theNotification,
        CMRPref);
    
    [self setupProgressIndicator];
    [self updateToolbarUIComponents];
    [self updateStatusLinePosition];
    [self setupStatusLineView];
    
    [self synchronizeHistoryTitleAndSelectedItem];
    [[self statusLineView] setNeedsDisplay : YES];
}


- (void) taskWillStartNotification : (NSNotification *) theNotification
{
    UTILAssertNotificationName(
        theNotification,
        CMRTaskWillStartNotification);
    [[self progressIndicator] startAnimation : self];
    [self updateStatusLineWithTask : [theNotification object]];
}
- (void) taskWillProgressNotification : (NSNotification *) theNotification
{
    UTILAssertNotificationName(
        theNotification,
        CMRTaskWillProgressNotification);
    
    [self updateStatusLineWithTask : [theNotification object]];
}

- (void) taskDidFinishNotification : (NSNotification *) theNotification
{
    UTILAssertNotificationName(
        theNotification,
        CMRTaskDidFinishNotification);
    UTILAssertConformsTo(
        [[theNotification object] class],
        @protocol(CMRTask));
    
    [self updateStatusLineWithTask : [theNotification object]];
}
@end



@implementation CMRStatusLine(History)
// アプリケーションのリセット
- (void) applicationWillReset : (NSNotification *) theNotification
{
    [[CMRHistoryManager defaultManager] removeClient : self];
}
- (void) applicationDidReset : (NSNotification *) theNotification
{
    NSMenuItem    *boadItem, *threadItem;
    id            wc;
    
    wc = [[self window] windowController];
    [[CMRHistoryManager defaultManager] addClient : self];
    
    boadItem = [[[self boardHistoryPopUp] selectedItem] retain];
    threadItem = [[[self threadHistoryPopUp] selectedItem] retain];
    
    [self synchronizeHistoryItemsWithManager];
    if ([wc boardIdentifier]) {
        [[[self boardHistoryPopUp] menu] addItem : boadItem];
    }
    
    if ([wc threadIdentifier])
        [[[self threadHistoryPopUp] menu] addItem : threadItem];
    
    [self synchronizeHistoryTitleAndSelectedItem];
    [boadItem release];
    [threadItem release];
}

// 履歴
- (BOOL ) boardHistoryEnabled
{
    return [[self boardHistoryPopUp] isEnabled];
}
- (BOOL ) threadHistoryEnabled
{
    if (NO == [[self threadHistoryPopUp] isEnabled])
        return NO;
        
    return [[self forwardBackMatrix] isEnabled];
}
- (void) setBoardHistoryEnabled : (BOOL) flag
{
    [[self boardHistoryPopUp] setEnabled : flag];
}
- (void) setThreadHistoryEnabled : (BOOL) flag
{
    [[self threadHistoryPopUp] setEnabled : flag];
    [[self forwardBackMatrix] setEnabled : flag];
}


- (CMRHistoryItem *) historyItemFromPopUp : (NSPopUpButton *) aPopUp
                            historyObject : (id             ) anObject
                                    index : (unsigned      *) pIndex
{
    unsigned    i, cnt;
    NSArray        *itemArray_;
    
    itemArray_ = [[aPopUp menu] itemArray];
    cnt = [itemArray_ count];
    for (i = 0; i < cnt; i++) {
        id        item_;
        
        item_ = [itemArray_ objectAtIndex : i];
        item_ = [item_ representedObject];
        if ([item_ hasRepresentedObject : anObject]) {
            if (pIndex != NULL) *pIndex = i;
            return item_;
        }
    }
    if (pIndex != NULL) *pIndex = -1;
    return nil;
}
- (void) synchronizeHistoryPopUp : (NSPopUpButton *) aPopUp
             selectionWithObject : (id             ) anObject
{
    int                index_ = -1;
    
    if (nil == anObject)
        index_ = -1;
    else if (NO == [anObject isKindOfClass : [CMRHistoryItem class]])
        [self historyItemFromPopUp:aPopUp historyObject:anObject index:&index_];
    else
        index_ = [[aPopUp menu] indexOfItemWithRepresentedObject : anObject];
    
    if (index_ < 0) {
        [self selectNotSelectionPopUpItem : aPopUp];
        return;
    } else {
        [aPopUp selectItemAtIndex : index_];
        [self removeNotSelectionPopUpItem : aPopUp];
    }
}



- (void) updateForwardBackButtons
{
    [[self forwardButtonCell] setEnabled : 
        (_Flags.delegateRespondsShouldForward != 0)
            ? [[self delegate] statusLineShouldPerformForward : self]
            : NO];
    
    [[self backButtonCell] setEnabled : 
        (_Flags.delegateRespondsShouldBackward != 0)
            ? [[self delegate] statusLineShouldPerformBackward : self]
            : NO];
}



// History PopUp
- (IBAction) historyForward : (id) sender
{
    if (_Flags.delegateRespondsForward != 0) {
        if([[self delegate] statusLinePerformForward : self]) {
            [[self delegate] focus : sender];
        }
    }
}
- (IBAction) historyBackward : (id) sender;
{
    if (_Flags.delegateRespondsBackward != 0) {
        if([[self delegate] statusLinePerformBackward : self]) {
            [[self delegate] focus : sender];
        }
    }
}

- (void) synchronizeHistoryTitleAndSelectedItem
{
    id wc;
    
    wc = [[self window] windowController];
    UTILAssertRespondsTo(wc, @selector(boardIdentifier));
    [self synchronizeHistoryPopUp : [self boardHistoryPopUp]
              selectionWithObject : [wc boardIdentifier]];
    [self synchronizeHistoryPopUp : [self threadHistoryPopUp]
              selectionWithObject : [wc threadIdentifier]];
    [self updateForwardBackButtons];
    [self historyPopUpSizeToFit];
}


// ----------------------------------------
// History Menu/PopUp
// ----------------------------------------
/* History Menu */
- (NSMenu *) menuForHistoryType : (int) aType
{
    id mm = [CMRMainMenuManager defaultManager];
    NSMenu *menu = nil;
    
    if (aType == CMRHistoryBoardEntryType) {
        menu = [[mm BBSMenuItem] submenu];
    } else if (aType == CMRHistoryBoardEntryType) {
        menu = [[mm threadMenuItem] submenu];
    }
    return menu;
}
- (void) synchronizeHistoryMenusWithManagerForType : (int) aType
{
    if (aType != CMRHistoryBoardEntryType &&
        aType != CMRHistoryThreadEntryType)
    { return; }
}

/* History PopUp */
- (void) synchronizeHistoryItemsWithManagerForType : (int) aType
{
    NSPopUpButton    *popUp_;
    NSArray            *itemArray_;
    unsigned        i, cnt;
    
    //[self synchronizeHistoryMenusWithManagerForType : aType];
    if (aType != CMRHistoryBoardEntryType &&
        aType != CMRHistoryThreadEntryType)
    { return; }
    
    
    popUp_ = (CMRHistoryBoardEntryType == aType)
                ? [self boardHistoryPopUp]
                : [self threadHistoryPopUp];
    
    // 2004-04-10 Takanori Ishikawa <takanori@gd5.so-net.ne.jp>
    // ----------------------------------------
    // - [NSPopUpButton removeAllItems:] は
    // - [NSPopUpButton synchronizeTitleAndSelectedItem] を呼んで状態
    // を初期化している。しかし、そのせいで最初の項目のタイトルが空文字
    // に初期化されてしまう。(NSMenu のメソッドを使っても同じ)
    //
    // (動作確認：Mac OS X 10.3)
    //
    if ([popUp_ numberOfItems] > 0) {
        NSMenuItem    *firstItem = [popUp_ itemAtIndex : 0];
        NSString    *title = [firstItem title];
        
        [firstItem retain];
        //[popUp_ setMenu: nil];
		[popUp_ removeAllItems];
		//[popUp_ setMenu:[[NSMenu alloc] init]];
        //[firstItem setTitle : title];
        [popUp_ setTitle : title];
        [firstItem autorelease];
    }
    
    itemArray_ = [[CMRHistoryManager defaultManager] historyItemArrayForType : aType];
    UTILAssertNotNil(itemArray_);
    
    cnt = [itemArray_ count];
    for (i = 0; i < cnt; i++) {
        CMRHistoryItem    *item_;
        
        item_ = [itemArray_ objectAtIndex : i];
        [self historyManager : [CMRHistoryManager defaultManager] 
           insertHistoryItem : item_
                     atIndex : [popUp_ numberOfItems]];
    }
    
    [self selectNotSelectionPopUpItem : popUp_];
    [self updateForwardBackButtons];
}
- (void) synchronizeHistoryItemsWithManager
{
    [self synchronizeHistoryItemsWithManagerForType : CMRHistoryBoardEntryType];
    [self synchronizeHistoryItemsWithManagerForType : CMRHistoryThreadEntryType];
}

//
// History Manager Client
// 
- (void) historyManager : (CMRHistoryManager *) aManager
      insertHistoryItem : (CMRHistoryItem    *) anItem
                atIndex : (unsigned int       ) anIndex
{
    NSPopUpButton        *popUp_;
    NSMenuItem            *menuItem_;
    SEL                    action_;
    
    if ([anItem type] != CMRHistoryBoardEntryType &&
        [anItem type] != CMRHistoryThreadEntryType)
    { return; }
    
    popUp_ = (CMRHistoryBoardEntryType == [anItem type])
                ? [self boardHistoryPopUp]
                : [self threadHistoryPopUp];
    action_ = (CMRHistoryBoardEntryType == [anItem type])
                ? kShowBoardSelector
                : kShowThreadSelector;
    

    menuItem_ = [[NSMenuItem alloc] initWithTitle : [anItem title]
                                    action : action_
                                    keyEquivalent : @""];
    [menuItem_ setRepresentedObject : anItem];
    
    [[popUp_ menu] insertItem : menuItem_ atIndex : anIndex];
    [menuItem_ release];
}
- (void) historyManager : (CMRHistoryManager *) aManager
      changeHistoryItem : (CMRHistoryItem    *) anItem
                atIndex : (unsigned int       ) anIndex
{
    NSPopUpButton        *popUp_;
    //NSMenuItem            *menuItem_;
	NSMenuItem				*newItem_;
    int                    index_;
    
    if ([anItem type] != CMRHistoryBoardEntryType &&
       [anItem type] != CMRHistoryThreadEntryType)
        return;
    
    popUp_ = (CMRHistoryBoardEntryType == [anItem type])
                ? [self boardHistoryPopUp]
                : [self threadHistoryPopUp];
    index_ = [popUp_ indexOfItemWithRepresentedObject : anItem];
    if (-1 == index_)
        return;
    
    /*menuItem_ = (NSMenuItem*)[popUp_ itemAtIndex : index_];
    [menuItem_ setTitle : [anItem title]];
    [menuItem_ setRepresentedObject : anItem];*/
	newItem_ = [(NSMenuItem*)[popUp_ itemAtIndex : index_] copy];
	[popUp_ removeItemAtIndex : index_]; 
    [newItem_ setTitle : [anItem title]];
    [newItem_ setRepresentedObject : anItem];
	[[popUp_ menu] insertItem : newItem_ atIndex : 0];
    [newItem_ release];
	
}
- (void) historyManager : (CMRHistoryManager *) aManager
      removeHistoryItem : (CMRHistoryItem    *) anItem
                atIndex : (unsigned int       ) anIndex
{
    NSPopUpButton        *popUp_;
    NSMenuItem            *menuItem_;
    int                    index_;
    
    if ([anItem type] != CMRHistoryBoardEntryType &&
       [anItem type] != CMRHistoryThreadEntryType)
        return;
    
    popUp_ = (CMRHistoryBoardEntryType == [anItem type])
                ? [self boardHistoryPopUp]
                : [self threadHistoryPopUp];
    index_ = [popUp_ indexOfItemWithRepresentedObject : anItem];
    if (-1 == index_)
        return;
    
    menuItem_ = (NSMenuItem*)[popUp_ itemAtIndex : index_];
    if (menuItem_ == [popUp_ selectedItem])
        return;
    
    [popUp_ removeItemAtIndex : index_];
    menuItem_ = (NSMenuItem*)[popUp_ selectedItem];
    [self synchronizeHistoryPopUp : popUp_
              selectionWithObject : [menuItem_ representedObject]];
    
}
@end
