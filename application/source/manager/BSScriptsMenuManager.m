//
//  BSScriptsMenuManager.m
//  BachyScaphe
//
//  Created by Hori,Masaki on 05/05/29.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//	See http://sourceforge.jp/projects/bathyscaphe/
//  See the file LICENSE for copying permission.

#import "BSScriptsMenuManager.h"

#import "CMRMainMenuManager.h"

/**
	それぞれのメニューの Title にはメニューアイテムを構築した時刻が設定されている。
	再構築時には、再構築した時刻が設定される。
	設定される時刻は　[[NSDate dateWithTimeIntervalSinceNow : 0.0] description]　である。
	
	それぞれの NSMenuItem  の　representedObject には、対応するスクリプト等のフルパルが設定されている。
 
	NSMenuItem の tag に 1 が設定されている場合、管理下にないと判断する。
**/

@implementation BSScriptsMenuManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager)

+ (void) setupScriptsMenu
{
	NSMenuItem *scriptMenu = [[CMRMainMenuManager defaultManager] scriptsMenuItem];
	NSImage *scriptImage;
	
	if (scriptImage = [NSImage imageNamed : @"Scripts"]) {
		[scriptMenu setTitle : @""];
		[scriptMenu setImage : scriptImage];
	}
	
	[[self defaultManager] buldScriptsMenu];
}

// アプリケーション化されたアップルスクリプトに対応。
static inline BOOL isRunnableAppleScripFile(NSString *path)
{
	NSString *extension = [path pathExtension];
	NSURL *url;
	NSAppleScript *as;
	BOOL isRunnable = NO;
	
	if ([@"app" isEqualTo : extension]) {
		isRunnable =  YES;
	} else {
		NSString *filetype;
		filetype = NSHFSTypeOfFile(path);
		if  ([@"'APPL'" isEqualTo : filetype]) {
			isRunnable =  YES;
		}
	}
	if(!isRunnable) return NO;
	
	url = [[[NSURL alloc] initWithScheme : @"file"
									host : @""
									path : path] autorelease];
	as = [[[NSAppleScript alloc] initWithContentsOfURL : url
												 error : nil] autorelease];
	
	return as ? YES : NO;
}

static inline BOOL isAppleScriptFile(NSString * path)
{
	NSString *extension = [path pathExtension];
	NSString *filetype;
	
	if ([@"scpt" isEqualTo : extension]) {
		return YES;
	} else if ([@"applescript" isEqualTo : extension]) {
		return YES;
	} else if ([@"scptd" isEqualTo : extension]) {
		return YES;
	}
	
	filetype = NSHFSTypeOfFile(path);
	if ([@"'osas'" isEqualTo : filetype]) {
		return YES;
	}
	
	if (isRunnableAppleScripFile(path)) {
		return YES;
	}
	
	return NO;
}

static inline NSImage *imageForMenuIcon(NSImage *image)
{
	NSSize menuIconSize = NSMakeSize(16,16);
	
	if (!NSEqualSizes(menuIconSize,[image size]) ) {
		[image setScalesWhenResized : YES];
		[image setSize : menuIconSize];
	}
	
	return image;
}

// extension と数字の接頭辞を削除する。
static inline NSString *titleForScriptsMenuFromPath(NSString *path)
{
	NSString *temp;
	unsigned length;
	NSRange newRange;
	NSCharacterSet *decSet;
	unsigned i;
	
	if (!path) return nil;
	
	temp = [[path lastPathComponent] stringByDeletingPathExtension];
	if (0 == (length = [temp length])) return @"";
	
	decSet = [NSCharacterSet decimalDigitCharacterSet];
	for (i = 0; i < length; i++) {
		if (![decSet characterIsMember : [temp characterAtIndex : i]])
			break;
	}
	if (0 == i) return temp;
	
	newRange.location = i;
	newRange.length = length - i;
	
	return [temp substringWithRange : newRange];
}

// ディレクトリとメニューを同期させる。
// サブディレクトリがあればサブメニューを作成し、再帰呼び出しする。
// title が "-" の場合はセパレーターと解釈する。
// isAppleScriptFile() が　NO であった場合は無視する。
// 動作は DVD Player version 4.6 に準じた。 
static inline void appendDirectoryIntoMenu(NSMenu *inMenu, NSString *dir)
{
	NSArray *items;
	NSEnumerator *itemsEnum;
	NSString *item;
	NSFileManager *fm = [NSFileManager defaultManager];
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	
	items = [fm directoryContentsAtPath : dir];
	items = [items sortedArrayUsingSelector : @selector(localizedCompare:)];
	itemsEnum = [items objectEnumerator];
	
	while (item = [itemsEnum nextObject]) {
		BOOL isDirectory;
		NSString *path = [dir stringByAppendingPathComponent : item];
		NSString *title = titleForScriptsMenuFromPath(path);
		NSImage *image;
		
		image = [ws iconForFile : path];
		
		if (![fm fileExistsAtPath : path isDirectory : &isDirectory]) {
			continue;
		} else if ([@"-" isEqualTo : title]) {
			id <NSMenuItem> menuItem;
			
			if (-1 != [inMenu indexOfItemWithRepresentedObject : path]) {
				continue;
			}
			
			menuItem = [NSMenuItem separatorItem];
			[menuItem setRepresentedObject : path];
			[inMenu addItem : menuItem];
			
		} else if (isDirectory && !isAppleScriptFile(path)) {
			id <NSMenuItem> menuItem;
			NSMenu *submenu;
			int index;
			
			index = [inMenu indexOfItemWithRepresentedObject : path];
			if (-1 == index) {
				menuItem = [inMenu addItemWithTitle : title
											action : nil
									 keyEquivalent : @""];
				submenu = [[[NSMenu alloc] init] autorelease];
				[submenu setTitle : [[NSDate dateWithTimeIntervalSinceNow : 0.0] description]];
				[menuItem setSubmenu : submenu];
				[menuItem setRepresentedObject : path];
				[menuItem setImage : imageForMenuIcon(image)];
			} else {
				menuItem = [inMenu itemAtIndex : index];
				submenu = [menuItem submenu];
			}
			
			appendDirectoryIntoMenu(submenu, path);
		} else {
			id <NSMenuItem> menuItem;
			
			if (-1 != [inMenu indexOfItemWithRepresentedObject : path]) {
				continue;
			}
			
			if (isAppleScriptFile(path)) {
				menuItem = [inMenu addItemWithTitle : title
											 action : @selector(handleScriptMenuItem:)
									  keyEquivalent : @""];
				
				[menuItem setTarget : [BSScriptsMenuManager defaultManager]];
				[menuItem setRepresentedObject : path];
				[menuItem setImage : imageForMenuIcon(image)];
			}
		}
	}
}

// メニュー構築時刻よりディレクトリが新しければ YES
static inline BOOL isModifiriedScriptsDirectory(NSMenu *inMenu, NSString *path)
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSDate *createDate = [NSDate dateWithString : [inMenu title]];
	NSDate *modDate;
	NSDictionary *attr;
	
	attr = [fm fileAttributesAtPath : path traverseLink : YES];
	modDate = [attr objectForKey : NSFileModificationDate];
	
	if ([modDate timeIntervalSinceDate : createDate] > 0 ) {
		return YES;
	}
	
	return NO;
}

// 管理下にあるメニューアイテムを削除する。
static inline void removeAllItem(NSMenu *inMenu)
{
	NSArray *items;
	NSEnumerator *itemsEnum;
	id <NSMenuItem> item;
	
	items = [inMenu itemArray];
	itemsEnum = [items objectEnumerator];
	while ((item = [itemsEnum nextObject])) {		
		if (1 != [item tag]) {
//			NSLog(@"############ DELETED -> %@", [item title]);
			[inMenu removeItem : item];
		}
	}
}

// 対応するディレクトリが更新されていた場合、メニューアイテムをすべて削除する。
// サブディレクトリも対象にするため再帰呼び出しされる。
static inline void removeDeletedOrModifiedMenuItem(NSMenu *inMenu, NSString *inPath)
{
	NSArray *items;
	NSEnumerator *itemsEnum;
	id <NSMenuItem> item;
	
	if (isModifiriedScriptsDirectory(inMenu, inPath)) {
		removeAllItem(inMenu);
		return;
	}
	
	items = [inMenu itemArray];
	itemsEnum = [items objectEnumerator];
	while ((item = [itemsEnum nextObject])) {
		NSString *path = [item representedObject];
		
		if ([item hasSubmenu]) {
			removeDeletedOrModifiedMenuItem([item submenu], path);
		}
	}
}

- (void) buldScriptsMenu
{
	static BOOL isFirst = YES;
	
	NSString *scriptsDir = [[[CMRFileManager defaultManager] supportDirectoryWithName : @"Scripts"] filepath];
	NSMenuItem *scriptMenu = [[CMRMainMenuManager defaultManager] scriptsMenuItem];
	NSMenu *submenu = [scriptMenu submenu];
	
	if (isFirst) {
		isFirst = NO;
		if (submenu) {
			[submenu setDelegate : self];
		}
	}
	
	if (submenu) {
		removeDeletedOrModifiedMenuItem(submenu, scriptsDir);
		appendDirectoryIntoMenu(submenu, scriptsDir);
		[submenu setTitle : [[NSDate dateWithTimeIntervalSinceNow : 0.0] description]];
	}
}

- (IBAction) handleScriptMenuItem : (id) item
{
	if ([item conformsToProtocol : @protocol(NSMenuItem)]) {
		NSDictionary *error = nil;
		NSString *path = [item representedObject];
		NSURL *url;
		NSAppleScript *as;
		
		if (isRunnableAppleScripFile(path)) {
			[[NSWorkspace sharedWorkspace] openFile : path];
			return;
		}
		
		url = [[[NSURL alloc] initWithScheme : @"file"
										host : @""
										path : path] autorelease];
		as = [[[NSAppleScript alloc] initWithContentsOfURL : url
													 error : &error] autorelease];
		if (error) {
//			NSLog(@"ERROR -> %@", error);
			return;
		}
		
		error = nil;
		[as executeAndReturnError : &error];
		if (error) {
//			NSLog(@"ERROR -> %@", error);
		}
	}
}

- (void)menuNeedsUpdate:(NSMenu*)menu
{
	NSMenuItem *scriptMenu = [[CMRMainMenuManager defaultManager] scriptsMenuItem];
	NSMenu *submenu = [scriptMenu submenu];
	
	if (![menu isEqual : submenu]) return;
	
	[self buldScriptsMenu];
}
@end


@implementation NSApplication(BSScriptsMenuManager)
- (IBAction) openScriptsDirectory : (id) sender
{
	NSString *scriptsDir = [[[CMRFileManager defaultManager] supportDirectoryWithName : @"Scripts"] filepath];
	
	[[NSWorkspace sharedWorkspace] openFile : scriptsDir];
}
@end

