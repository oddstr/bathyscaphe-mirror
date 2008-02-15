//:ThreadViewer_p.h
#import "CMRThreadViewer.h"
#import <SGAppKit/BSTitleRulerView.h>
#import "CMRStatusLineWindowController.h";
#import "AppDefaults.h"

#import "CMRThreadSignature.h"
#import "CMRThreadAttributes.h"
#import "CMRThreadDocument.h"
#import "CMRThreadMessageBuffer.h"
#import "CMRThreadMessage.h"

#import "CMRIndexingStepper.h"
#import "BSIndexingPopupper.h"

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

#define kDeleteThreadTitleKey	@"Delete Thread Title"
#define kDeleteThreadMessageKey	@"Delete Thread Message"
#define kDeleteOKBtnKey			@"Delete OK"
#define kDeleteCancelBtnKey		@"Delete Cancel"
#define kDeleteAndReloadBtnKey	@"Delete & Reload"

#define kNotFoundTitleKey				@"Not Found Title"
#define kNotFoundMessageFormatKey		@"Not Found Message"
#define kNotFoundMessageFormat2Key		@"Not Found Message 2"
#define kNotFoundMaruLabelKey			@"Not Found Maru Button Label"
#define kNotFoundHelpKeywordKey			@"NotFoundSheet Help Anchor"
#define kInvalidPerticalContentsHelpKeywordKey	@"InvalidPerticalSheet Help Anchor"
#define kNotFoundCancelLabelKey			@"Do Not Reload Button Label"



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

- (void) updateKeywordsCache; // Available in Starlight Breaker.
@end



@interface CMRThreadViewer(MoveActionValidation)
- (BOOL) canScrollFirstMessage;
- (BOOL) canScrollLastMessage;
- (BOOL) canScrollPrevMessage;
- (BOOL) canScrollNextMessage;
- (BOOL) canScrollToMessage;
- (BOOL) canScrollToLastReadedMessage;
- (BOOL) canScrollToLastUpdatedMessage;
@end



@interface CMRThreadViewer(ThreadTaskNotification)
- (id) identifierForThreadTask;

- (void) registerComposingNotification : (id) task;
- (void) removeFromComposingNotification : (id) task;
@end



@interface CMRThreadViewer(ThreadDataNotification)
- (void) synchronizeVisibleRange;
- (void) synchronizeAttributes;
- (void) synchronizeLayoutAttributes;
@end



@interface CMRThreadViewer(ActionSupport)
- (CMRReplyMessenger *)replyMessenger;
- (void) addMessenger : (CMRReplyMessenger *) aMessenger;
- (void) replyMessengerDidFinishPosting : (NSNotification *) aNotification;
- (void) removeMessenger : (CMRReplyMessenger *) aMessenger;

- (void) openThreadsInThreadWindow : (NSArray *) threads;
//- (void) openThreadsInBrowser : (NSArray *) threads;
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

// Available in Twincam Angel.
- (void)downloadThreadUsingMaru:(CMRThreadSignature *)aSignature title:(NSString *)threadTitle;
@end



//:CMRThreadViewer-ViewAccessor.m
@interface CMRThreadViewer(ViewAccessor)
- (NSTextView *) textView;
- (void) setTextView : (NSTextView *) aTextView;
- (NSScrollView *) scrollView;

- (BSIndexingPopupper *) indexingPopupper;
- (CMRIndexingStepper *) indexingStepper;

- (NSView *) navigationBar;
@end

@interface CMRThreadViewer(NSTextViewDelegate)
- (IBAction) runSpamFilter : (id) sender;
@end

@interface CMRThreadViewer(UIComponents)
- (BOOL) loadComponents;
- (NSView *) containerView;
- (void) setupLoadedComponents;
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
