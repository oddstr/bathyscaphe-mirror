//
// BSSettingTxtDetector.h
// BathyScaphe
//
// Written by Tsutomu Sawada on 06/08/15.
// Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BSSettingTxtDetector: NSObject {
    @private
    NSString    *bsSTD_boardName;
    NSURL       *bsSTD_settingTxtURL;
}

// 指定イニシャライザ
- (id) initWithBoardName: (NSString *) boardName settingTxtURL: (NSURL *) anURL;

- (NSString *) boardName;
- (void) setBoardName: (NSString *) newBoardName;
- (NSURL *) settingTxtURL;
- (void) setSettingTxtURL: (NSURL *) newURL;


// SETTING.TXT のダウンロードを開始
// ダウンロード終了後、自動的に解析が始まる
- (void) startDownloadingSettingTxt;

@end

extern NSString *const BSSettingTxtDetectorDidFinishNotification;
extern NSString *const BSSettingTxtDetectorDidFailNotification;

extern NSString *const kBSSTDBoardNameKey;
extern NSString *const kBSSTDNoNameValueKey;
extern NSString *const kBSSTDBeLoginPolicyTypeValueKey;
