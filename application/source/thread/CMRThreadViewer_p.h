//:ThreadViewer_p.h
#import "CMRThreadViewer.h"
#import "BSTitleRulerView.h"
#import "CMRStatusLineWindowController_p.h";
#import "AppDefaults.h"

#import "CMRBBSSignature.h"
#import "CMRThreadSignature.h"
#import "CMRThreadAttributes.h"
#import "CMRThreadDocument.h"
#import "CMRThreadMessageBuffer.h"
#import "CMRThreadMessage.h"

#import "CMRIndexingStepper.h"
#import "CMXScrollView.h"

#import "CMRFavoritesManager.h"
#import "CMRTrashbox.h"
#import "CMRTaskManager.h"
#import "CMRDocumentFileManager.h"
#import "CMRHostHandler.h"

@class CMRReplyMessenger;


// private notification
extern NSString *const CMRThreadViewerRunSpamFilterNotification;

#define APP_TVIEW_LOCALIZABLE_FILE			@"ThreadViewer"
#define APP_TVIEW_STATUSLINE_IDENTIFIER		@"ThreadViewer"
#define APP_TVIEWER_INVALID_PERT_TITLE		@"Invalid Pertical Contents Title"
#define APP_TVIEWER_INVALID_PERT_MSG_FMT	@"Invalid Pertical Contents Message"
#define APP_TVIEWER_DELETE_LABEL			@"Delete Button Label"
#define APP_TVIEWER_NOT_DELETE_LABEL		@"Do Not Delete Button Label"
#define APP_TVIEWER_DEL_AND_RETRY_LABEL		@"Delete And Retry Button Label"
#define APP_TVIEWER_INVALID_THREAD_TITLE	@"Invalidated Thread Contents Title"
#define APP_TVIEWER_INVALID_THREAD_MSG_FMT	@"Invalidated Thread Contents Message"
#define APP_TVIEWER_DO_RELOAD_LABEL			@"Reload From File Button Label"
#define APP_TVIEWER_NOT_RELOAD_LABEL		@"Do Not Reload Button Label"
#define APP_TVIEW_FIRST_VISIBLE_LABEL_KEY	@"First Visibles"
#define APP_TVIEW_LAST_VISIBLE_LABEL_KEY	@"Last Visibles"
#define APP_TVIEW_SHOW_ALL_LABEL_KEY		@"Show All"
#define APP_TVIEW_SHOW_NONE_LABEL_KEY		@"Show None"

#define kDeleteThreadTitleKey	@"Delete Thread Title"
#define kDeleteThreadMessageKey	@"Delete Thread Message"
#define kDeleteOKBtnKey			@"Delete OK"
#define kDeleteCancelBtnKey		@"Delete Cancel"
#define kDeleteAndReloadBtnKey	@"Delete & Reload"

@interface CMRThreadViewer(NotificationPrivate)
- (void) cleanUpItemsToBeRemoved : (NSArray *) files;
- (void) threadAttributesDidChangeAttributes : (NSNotification *) notification;
- (void) appDefaultsLayoutSettingsUpdated : (NSNotification *) notification;
- (void) trashDidPerformNotification : (NSNotification *) notification;
@end



@interface CMRThreadViewer(ThreadContents)
- (BOOL) shouldShowContents;
- (BOOL) shouldLoadWindowFrameUsingCache;
- (BOOL) shouldSaveThreadDataAttributes;
- (BOOL) canGenarateContents;
- (BOOL) checkCanGenarateContents;

- (NSTextStorage *) threadContent;
- (void) setThreadAttributes : (CMRThreadAttributes *) aThreadData;
- (void) disposeThreadAttributes : (CMRThreadAttributes *) oldThread;
- (void) registerThreadAttributes : (CMRThreadAttributes *) newThread;
@end



@interface CMRThreadViewer(MoveActionValidation)
- (BOOL) canScrollFirstMessage;
- (BOOL) canScrollLastMessage;
- (BOOL) canScrollPrevMessage;
- (BOOL) canScrollNextMessage;

- (BOOL) canScrollToLastReadedMessage;
- (BOOL) canScrollToLastUpdatedMessage;
@end



@interface CMRThreadViewer(ThreadTaskNotification)
- (id) identifierForThreadTask;

- (void) registerComposingNotification : (id) task;
- (void) removeFromComposingNotification : (id) task;
@end



@interface CMRThreadViewer(ThreadDataNotification)
- (void) synchronizeVisibleLength : (BOOL					) isFirst
					 visibleRange : (CMRThreadVisibleRange *) visibleRange;
- (void) synchronizeVisibleRange;
- (void) synchronizeAttributes;
- (void) synchronizeLayoutAttributes;
@end



@interface CMRThreadViewer(ActionSupport)
- (CMRFavoritesOperation) favoritesOperationForThreads : (NSArray *) threadsArray;
- (void) addMessenger : (CMRReplyMessenger *) aMessenger;
- (CMRReplyMessenger *) messenger : (BOOL) create;
- (void) replyMessengerDidFinishPosting : (NSNotification *) aNotification;
- (void) removeMessenger : (CMRReplyMessenger *) aMessenger;

- (void) openThreadsInThreadWindow : (NSArray *) threads;
- (void) openThreadsInBrowser : (NSArray *) threads;
- (void) openThreadsLogFiles : (NSArray *) threads;
@end




@interface CMRThreadViewer(SaveAttributes)
- (void) threadWillClose;

- (BOOL) synchronize;

- (void) saveWindowFrame;
- (void) saveLastIndex;
@end



//:CMRThreadViewer-Download.m
@interface CMRThreadViewer(Download)
- (void) downloadThread : (CMRThreadSignature *) aSignature
				  title : (NSString           *) threadTitle
			  nextIndex : (unsigned int        ) aNextIndex;

// available in LittleWish and later.
- (void) reloadAfterDeletion : (NSString *) filePath_; // subclass(CMRBrowser) should override this method
@end



//:CMRThreadViewer-ViewAccessor.m
@interface CMRThreadViewer(ViewAccessor)
/* Accessor for m_textView */
- (NSTextView *) textView;
- (void) setTextView : (NSTextView *) aTextView;
/* Accessor for m_scrollView */
- (CMXScrollView *) scrollView;

/* Accessor for m_firstVisibleRangePopUpButton */
- (NSPopUpButton *) firstVisibleRangePopUpButton;
/* Accessor for m_lastVisibleRangePopUpButton */
- (NSPopUpButton *) lastVisibleRangePopUpButton;

/* Accessor for m_indexingStepper */
- (CMRIndexingStepper *) indexingStepper;
@end



@interface CMRThreadViewer(UIComponents)
- (BOOL) loadComponents;
- (NSView *) containerView;
- (void) setupLoadedComponents;
@end


@interface CMRThreadViewer(VisibleNumbersPopUpSetup)
+ (NSArray *) firstVisibleNumbersArray;
+ (NSArray *) lastVisibleNumbersArray;

- (NSString *) localizedVisibleStringWithFormat : (NSString *) fotmat
								  visibleLength : (unsigned  ) visibleLength;
- (NSString *) localizedFirstVisibleStringWithNumber : (NSNumber *) visibleNumber;
- (NSString *) localizedLastVisibleStringWithNumber : (NSNumber *) visibleNumber;
- (NSMenuItem *) addItemWithVisibleRangePopUpButton : (NSPopUpButton *) popUpBtn
                           isFirstVisibles : (BOOL           ) isFirst
                          representedIndex : (NSNumber      *) aNum;

- (void) setupVisibleRangePopUpButtonCell : (NSPopUpButtonCell *) popUpBtnCell;
- (void) setupVisibleRangePopUpButton : (NSPopUpButton *) popUpBtn;
- (void) setupVisibleRangePopUpButtonAttributes : (NSPopUpButton *) popUpBtn
								isFirstVisibles : (BOOL           ) isFirst;
- (void) setupVisibleRangePopUp;
@end



@interface CMRThreadViewer(ViewInitializer)
+ (NSMenu *) loadContextualMenuForTextView;

- (void) setupScrollView;
- (void) setupTextView;
- (void) updateLayoutSettings;
- (void) setupTextViewBackground;
- (void) setWindowFrameUsingCache;
- (void) setupKeyLoops;

+ (BOOL) shouldShowTitleRulerView;
+ (BSTitleRulerModeType) rulerModeForInformDatOchi;
- (void) cleanUpTitleRuler: (NSTimer *) aTimer;
@end
