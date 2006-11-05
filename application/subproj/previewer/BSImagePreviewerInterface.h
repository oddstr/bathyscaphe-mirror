//
//  BSImagePreviewerInterface.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/15, Last Modified on 06/08/24.
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
//

@class AppDefaults;

@protocol BSImagePreviewerProtocol
// Designated Initializer
- (id) initWithPreferences : (AppDefaults *) prefs;
// Accessor
- (AppDefaults *) preferences;
- (void) setPreferences : (AppDefaults *) aPreferences;
// Action
- (BOOL) showImageWithURL : (NSURL *) imageURL;
- (BOOL) validateLink : (NSURL *) anURL;

// MeteorSweeper Addition - optional method information
// このメソッドはプロトコル定義には含まれませんが、BathyScaphe 1.3 以降でプラグインの Principal class に
// このメソッドを実装しておくと、BathyScaphe の「ウインドウ」＞「プレビュー」メニュー項目が有効になります。
// BathyScaphe は「ウインドウ」＞「プレビュー」が選択されると、プラグインに対してこのメソッドを実行するようメッセージを送信します。
// - (IBAction) togglePreviewPanel : (id) sender;
@end

@interface NSObject(IPPAdditions)
// Storage for plugin-specific settings
- (NSMutableDictionary *) imagePreviewerPrefsDict;

//  Accessor for useful BathyScaphe global settings
- (BOOL) openInBg;
- (BOOL) isOnlineMode;
@end
