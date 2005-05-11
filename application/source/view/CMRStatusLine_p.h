//:CMRStatusLine_p.h
#import "CMRStatusLine.h"

#import <SGAppKit/SGAppKit.h>
#import "CMRTask.h"
#import "CMRTaskManager.h"
#import "CMXPreferences.h"



// 「ブックマーク」ボタン・アクション
#define kShowBookmarksPaneSelector	@selector(toggleBookmarksPane:)
// 履歴ポップアップ・アクション
#define kShowBoardSelector			@selector(showBoardWithMenuItem:)
#define kShowThreadSelector			@selector(showThreadWithMenuItem:)


//:CMRStatusLine-Autosave.m
@interface CMRStatusLine(Autosave)
- (NSString *) userDefaultsKeyWithKey : (NSString *) key;
- (NSString *) statusLineShownUserDefaultsKey;

// NSUserDefaults / NSMutableDictionary ...
- (id) preferencesObject;
@end



//:CMRStatusLine-ViewAccessor.m
@interface CMRStatusLine(View)
- (NSView *) statusLineView;
- (NSView *) indicatorView;
- (NSTextField *) statusTextField;
- (NSProgressIndicator *) progressIndicator;
- (NSButton *) stopButton;

// toolbar
- (NSView *) toolbarView;
//- (NSButton *) bookmarksButton;
- (NSPopUpButton *) boardHistoryPopUp;
- (NSPopUpButton *) threadHistoryPopUp;
- (NSMatrix *) forwardBackMatrix;
- (NSMatrix *) toolbarItemMatrix;
- (NSButtonCell *) forwardButtonCell;
- (NSButtonCell *) backButtonCell;
- (NSTextField *) infoTextField;

- (void) setInfoTextFieldObjectValue : (id) anObject;

- (void) historyPopUpSizeToFit;
- (void) selectNotSelectionPopUpItem : (NSPopUpButton *) aPopUp;
- (void) removeNotSelectionPopUpItem : (NSPopUpButton *) aPopUp;

- (void) updateToolbarUIComponents;

- (void) setupProgressIndicator;
- (void) setupStatusLineView;
- (void) setupToolbarUIComponents;
- (void) setupUIComponents;
@end



@interface CMRStatusLine(StatusLineView)
- (NSView *) currentSubview;
- (void) removeSubviewsFromStatusLineView;
- (void) addSubviewIntoStatusLineView : (NSView *) subview;
@end



@interface CMRStatusLine(ViewController)
+ (NSSize) subviewInset;
- (void) removeUnnecessaryProgressViews;
- (void) addViewsIfNeeded;
- (void) updateStatusLineWithTask : (id<CMRTask>) aTask;
@end
