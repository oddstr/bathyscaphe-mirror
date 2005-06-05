//
//  BSScriptsMenuManager.h
//  BachyScaphe
//
//  Created by Hori,Masaki on 05/05/29.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//	See http://sourceforge.jp/projects/bathyscaphe/
//  See the file LICENSE for copying permission.

#import <Cocoa/Cocoa.h>

@interface BSScriptsMenuManager : NSObject
+ (id) defaultManager;
+ (void) setupScriptsMenu;

- (void) buldScriptsMenu;
@end

@interface NSApplication(BSScriptsMenuManager)
- (IBAction) openScriptsDirectory : (id) sender;
@end

#pragma mark -
@class BSScriptsMenuItem;

// 半自動スクリプトメニュークラス
// スクリプトフォルダを指定して、更新タイミングを取ってやるだけで勝手に機能する。
// NSMenuItem の tag に 1 が設定されている場合、管理下にないと判断する。
@interface BSScriptsMenu : NSMenu
{
	NSString *scriptsDirectory;
}

// path が存在しないあるいはディレクトリでなければ nil を返す。
- (id) initWithScriptsDirectoryPath : (NSString *) path;

// path が存在しないあるいはディレクトリでなければ黙って無視する。
- (void) setScriptsDirectoryPath : (NSString *) path;
- (NSString *)scriptDirectoryPath;

// スクリプトメニューを構築する。
- (void) synchronizeScriptsMenu;

// BSScriptsMenuItem を作成し、ファイル名順に沿った位置にそれを追加する。
- (BSScriptsMenuItem *) addBSScriptMenuItemWithScriptFilePath : (NSString *) path;

- (int) indexOfItemWithScriptFilePath : (NSString *) path;

@end

typedef enum {
	unknownMenuItemType = 0,
	scriptMenuItemType,
	runnablescriptMenuItemType,
	directoryMenuItemType,
	invalidMenuItemType,
} BSScriptMenuItemType;

// Scripts Menu 用 メニューアイテム。
@interface BSScriptsMenuItem : NSMenuItem
{
	NSString *appleScriptPath;
	
	BSScriptMenuItemType type;
}

// path がアップルスクリプトでもディレクトリでもなければ nil を返す。
- (id) initWithScriptFilePath : (NSString *) path;

- (BSScriptMenuItemType) type;

- (NSString *) scriptsPath;
- (NSString *) realFileName;

// アップルスクリプトを実行する。
// アプリケーション形式の場合は起動する。
- (void) excute;

// scriptsPath が存在するファイルなら YES.
- (BOOL) isValid;

@end
