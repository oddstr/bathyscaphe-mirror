/**
 * $Id: CMRAppDelegate+Menu.m,v 1.7.4.2 2006/01/29 12:58:10 masakih Exp $
 * 
 * CMRAppDelegate+Menu.m
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */
#import "CMRAppDelegate_p.h"


// ----------------------------------------
// D e f i n e d
// ----------------------------------------
// Bookmark file
#define kURLBookmarksPlist @"URLBookmarks.plist"

#define kBrowserListColumnsPlist        @"browserListColumns.plist"

// Elements name
#define kCMRAppDelegateNameKey      @"Name"
#define kCMRAppDelegateURLKey       @"URL"
#define kCMRAppDelegateBookmarksKey @"Bookmarks"



@implementation CMRAppDelegate(MenuSetup)
+ (NSString *) pathForURLBookmarkResource
{
    NSString    *path;
    NSBundle    *bundle;
    
    bundle = [NSBundle applicationSpecificBundle];
    path = [bundle pathForResourceWithName : kURLBookmarksPlist];
    if (path != nil)
        return path;
    
    bundle = [NSBundle mainBundle];
    path = [bundle pathForResourceWithName : kURLBookmarksPlist];
    
    return path;
}
+ (NSArray *) URLBookmarkArray
{
    return [NSArray arrayWithContentsOfFile : [self pathForURLBookmarkResource]];
}
+ (BOOL) isCategoryWithDictionary : (NSDictionary *) item
{
    return ([item objectForKey : kCMRAppDelegateBookmarksKey] != nil);
}
+ (NSArray *) defaultColumnsArray
{
    NSBundle    *bundles[] = {
                [NSBundle applicationSpecificBundle], 
                [NSBundle mainBundle],
                nil};
    NSBundle    **p = bundles;
    NSString    *path = nil;
    
    for (; *p != nil; p++)
        if (path = [*p pathForResourceWithName : kBrowserListColumnsPlist])
            break;
    
    return (nil == path) ? nil : [NSArray arrayWithContentsOfFile : path];
}

#pragma mark -

- (void) setupURLBookmarksMenuWithMenu : (NSMenu  *) menu
                             bookmarks : (NSArray *) bookmarks
{
    NSEnumerator    *iter_;
    NSDictionary    *item_;
    
    if (nil == menu) return;
    if (nil == bookmarks) return;
    
    iter_ = [bookmarks objectEnumerator];
    while (item_ = [iter_ nextObject]) {
        NSString        *title_;
        NSMenuItem        *menuItem_;
        
        if (NO == [item_ isKindOfClass : [NSDictionary class]]) continue;
        
        title_ = [item_ objectForKey : kCMRAppDelegateNameKey];
        if (nil == title_) continue;
        
        if (0 == [title_ length]) {
            [menu addItem : [NSMenuItem separatorItem]];
            continue;
        }
        
        menuItem_ = [[NSMenuItem alloc]
                        initWithTitle : title_
                               action : NULL
                        keyEquivalent : @""];
        if ([[self class] isCategoryWithDictionary : item_]) {
            NSMenu        *submenu_;
            NSArray        *bookmarks_;
            
            bookmarks_ = [item_ objectForKey : kCMRAppDelegateBookmarksKey];
            UTILAssertNotNil(bookmarks_);
            
            submenu_ = [[NSMenu allocWithZone : [NSMenu menuZone]]
                            initWithTitle : title_];
            [self setupURLBookmarksMenuWithMenu : submenu_
                                      bookmarks : bookmarks_];
            [menuItem_ setSubmenu : submenu_];
        } else {
            NSString        *URLString_;
            NSURL            *URLToOpen_;
            
            URLString_ = [item_ objectForKey : kCMRAppDelegateURLKey];
            if (nil == URLString_) {
                [menuItem_ release];
                continue;
            }
            URLToOpen_ = [NSURL URLWithString : URLString_];
                            
            [menuItem_ setTarget : self];
            [menuItem_ setAction : @selector(openURL:)];
            [menuItem_ setRepresentedObject : URLToOpen_];
        }
        [menu addItem : menuItem_];
        [menuItem_ release];
    }
}
- (void) setupBrowserArrangementMenuWithMenu : (NSMenu *) menu
{
    NSMenuItem        *menuItem_;
    NSString        *title_;
    id                representedObject_;
    unsigned        index_, count_;
    
    // parameter tables...
    NSString    *keys_[] =    {
                                APP_MAINMENU_SPVIEW_HORIZONTAL,
                                APP_MAINMENU_SPVIEW_VERTICAL
                            };
    BOOL        reps_[] =    {
                                NO,
                                YES
                            };
    
    count_ = UTILNumberOfCArray(keys_);
    NSAssert2(
        count_ == [menu numberOfItems],
        @"BrowserArrangement Menu Item expected (%u) but was (%u).",
        count_,
        [menu numberOfItems]);
    
    for (index_ = 0; index_ < count_; index_++) {
        menuItem_ = (NSMenuItem*)[menu itemAtIndex : index_];
        title_ = [self localizedString : keys_[index_]];
        [menuItem_ setTitle : title_];
        representedObject_ = [NSNumber numberWithBool : reps_[index_]];
        [menuItem_ setRepresentedObject : representedObject_];
    }
}

- (void) setupBrowserArrangementMenu
{
    NSMenuItem    *menuItem_;
    
    menuItem_ = [[CMRMainMenuManager defaultManager] browserArrangementMenuItem];
    NSAssert(
        [menuItem_ hasSubmenu],
        @"menuItem must have submenu");
    
    [self setupBrowserArrangementMenuWithMenu : [menuItem_ submenu]];
    [[CMRMainMenuManager defaultManager] 
            synchronizeBrowserArrangementMenuItemState];
}
- (void) setupURLBookmarksMenuWithMenu : (NSMenu *) menu
{
    NSArray            *URLBookmarkArray_;
    
    UTILAssertNotNilArgument(menu, @"Menu");
    URLBookmarkArray_ = [[self class] URLBookmarkArray];
    if (nil == URLBookmarkArray_) return;
    
    [menu addItem : [NSMenuItem separatorItem]];
    [self setupURLBookmarksMenuWithMenu : menu
                              bookmarks : URLBookmarkArray_];
}

- (void) setupBrowserListColumnsMenuWithMenu : (NSMenu *) menu
{
    NSArray         *defaultColumnsArray_;
    NSEnumerator    *iter_;
    NSDictionary    *item_;
    
    UTILAssertNotNilArgument(menu, @"Menu");
    defaultColumnsArray_ = [[self class] defaultColumnsArray];
    if (nil == defaultColumnsArray_) return;

	iter_ = [defaultColumnsArray_ objectEnumerator];
    while (item_ = [iter_ nextObject]) {
        NSString		*title_;
		NSString		*identifier_;
        NSMenuItem		*menuItem_;
        
        if (NO == [item_ isKindOfClass : [NSDictionary class]]) continue;
        
        title_ = [item_ objectForKey : @"Title"];
        identifier_ = [item_ objectForKey : @"Identifier"];
        
        menuItem_ = [[NSMenuItem alloc]
                        initWithTitle : title_
                               action : NULL
                        keyEquivalent : @""];

		[menuItem_ setRepresentedObject : identifier_];
        [menu addItem : menuItem_];
        [menuItem_ release];
    }
}

- (void) setupBrowserStatusFilteringMenuWithMenu : (NSMenu *) menu
{
    NSArray         *menuItemsArray_;
    NSEnumerator    *iter_;
    id<NSMenuItem>	item_;
    
    UTILAssertNotNilArgument(menu, @"Menu");
    menuItemsArray_ = [menu itemArray];
    if (nil == menuItemsArray_ || [menuItemsArray_ count] == 0) return;

	iter_ = [menuItemsArray_ objectEnumerator];
    while (item_ = [iter_ nextObject]) {
        int			itemTag = [item_ tag];
		
		switch(itemTag) {
		case 50:
			[item_ setRepresentedObject : [NSNumber numberWithUnsignedInt : ThreadStandardStatus]];
			break;
		case 51:
			[item_ setRepresentedObject : [NSNumber numberWithUnsignedInt : ~ThreadNoCacheStatus]];
			break;
		case 52:
			[item_ setRepresentedObject : 
				[NSNumber numberWithUnsignedInt : (ThreadNewCreatedStatus ^ ThreadNoCacheStatus)]];
			break;
		case 53:
			[item_ setRepresentedObject : [NSNumber numberWithUnsignedInt : ThreadLogCachedStatus]];
			break;
		case 54:
			[item_ setRepresentedObject : [NSNumber numberWithUnsignedInt : ThreadNoCacheStatus]];
			break;
		default:
			break;
		}
	}

	[[CMRMainMenuManager defaultManager] synchronizeStatusFilteringMenuItemState];
}

#pragma mark Public

- (void) setupMenu
{
    NSMenuItem    *menuItem_;
	CMRMainMenuManager	*dm_ = [CMRMainMenuManager defaultManager];
    menuItem_ = [dm_ helpMenuItem];
    NSAssert(
        [menuItem_ hasSubmenu],
        @"menuItem must have submenu");
    [self setupURLBookmarksMenuWithMenu : [menuItem_ submenu]];
	
	[self setupBrowserListColumnsMenuWithMenu : [[dm_ browserListColumnsMenuItem] submenu]];
	[self setupBrowserStatusFilteringMenuWithMenu : [[dm_ browserStatusFilteringMenuItem] submenu]];
    
    [self setupBrowserArrangementMenu];
    [dm_ synchronizeIsOnlineModeMenuItemState];

	[BSHistoryMenuManager setupHistoryMenu];
	[BSScriptsMenuManager setupScriptsMenu];
}
@end
