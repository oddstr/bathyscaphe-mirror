/**
  * $Id: CMRThreadViewer.h,v 1.3 2005/07/09 00:01:49 tsawada2 Exp $
  * 
  * CMRThreadViewer.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "CMRStatusLineWindowController.h"

@class CMXScrollView;
@class CMRThreadAttributes;
@class Messenger;
@class CMRDownloader;
@class TextSystemDebug;

@class CMRBBSSignature;
@class CMRThreadSignature;
@class CMRIndexingStepper;
@class CMRThreadLayout;



@interface CMRThreadViewer : CMRStatusLineWindowController
{
	NSTextStorage				*_textStorage;
	
	// History
	unsigned					_historyIndex;
	NSMutableArray				*_history;
	
	// Helper
	CMRThreadLayout				*_layout;
	
	// Interface
	CMRIndexingStepper			*m_indexingStepper;
	
	IBOutlet NSView				*m_componentsView;
	IBOutlet NSView				*m_containerView;
	IBOutlet NSView				*m_windowContentView;	// dummy
	
	IBOutlet CMXScrollView		*m_scrollView;
	IBOutlet NSTextView			*m_textView;
	
	IBOutlet NSPopUpButton		*m_firstVisibleRangePopUpButton;
	IBOutlet NSPopUpButton		*m_lastVisibleRangePopUpButton;
	
	struct {
		unsigned int invalidate :1;		/* invalid contents */
		unsigned int reserved   :31;
	} _flags;
}

/* Register history list if relativeIndex == 0 */
- (void) setThreadContentWithThreadIdentifier : (id  ) aThreadIdentifier
							  noteHistoryList : (int ) relativeIndex;
- (void) setThreadContentWithFilePath : (NSString     *) filepath
                            boardInfo : (NSDictionary *) boardInfo
					  noteHistoryList : (int           ) relativeIndex;
- (void) setThreadContentWithThreadIdentifier : (id) aThreadIdentifier;
- (void) setThreadContentWithFilePath : (NSString     *) filepath
                            boardInfo : (NSDictionary *) boardInfo;

- (void) loadFromContentsOfFile : (NSString *) filepath;
- (void) composeDATContents : (NSString           *) datContents
			threadSignature : (CMRThreadSignature *) aSignature
				  nextIndex : (unsigned int        ) aNextIndex;

/*** auxiliary ***/
- (BOOL) isInvalidate;
- (void) setInvalidate : (BOOL) flag;

- (CMRThreadLayout *) threadLayout;
- (CMRThreadAttributes *) threadAttributes;

/* called when thread did be changed */
- (void) didChangeThread;

/*** NO_NAME properties ***/
- (NSString *) detectDefaultNoName;
- (NSString *) setupDefaultNoNameIfNeeded;

- (NSString *) path;
- (NSString *) title;
- (NSString *) boardName;
- (NSURL *) boardURL;
- (NSURL *) threadURL;
- (NSString *) datIdentifier;
- (NSString *) bbsIdentifier;

- (BOOL) isAAThread;
- (void) setAAThread : (BOOL) flag;
@end



@interface CMRThreadViewer(Action)
- (NSPoint) locationForInformationPopUp;

// KeyBinding...
- (IBAction) forceDeleteThread : (id) sender;
- (void) forceDeleteThreadAtPath : (NSString *) filepath;
- (IBAction) deleteThread : (id) sender;
- (IBAction) reloadThread : (id) sender;
- (IBAction) reply : (id) sender;

- (IBAction) toggleAAThread : (id) sender;

- (IBAction) copyThreadAttributes : (id) sender;
- (IBAction) copyInfoFromContextualMenu : (id) sender;
- (void) copyThreadInfoOf : (NSEnumerator *) Iter_;
- (IBAction) showThreadAttributes : (id) sender;

- (IBAction) copySelectedResURL : (id) sender;
- (IBAction) reloadIfOnlineMode : (id) sender;
- (IBAction) openInBrowser : (id) sender;
- (IBAction) openBBSInBrowser : (id) sender;
- (IBAction) openLogfile : (id) sender;
- (IBAction) addFavorites : (id) sender;
- (IBAction) toggleOnlineMode : (id) sender;
- (IBAction) selectFirstVisibleRange : (id) sender;
- (IBAction) selectLastVisibleRange : (id) sender;

- (IBAction) customizeBrdListTable : (id) sender;   //Action Button
- (IBAction) launchBWAgent : (id) sender;   //Action Button
// make text area to be first responder
- (IBAction) focus : (id) sender;
/* NOTE: It is a history item's action. */
- (IBAction) showThreadWithMenuItem : (id) sender;
@end



@interface CMRThreadViewer(MoveAction)
/* 最初／最後のレス */
- (IBAction) scrollFirstMessage : (id) sender;
- (IBAction) scrollLastMessage : (id) sender;

/* 次／前のレス */
- (IBAction) scrollPrevMessage : (id) sender;
- (IBAction) scrollPreviousMessage : (id) sender;
- (IBAction) scrollNextMessage : (id) sender;

/* 次／前のブックマーク */
- (IBAction) scrollPreviousBookmark : (id) sender;
- (IBAction) scrollNextBookmark : (id) sender;

- (IBAction) scrollToLastReadedIndex : (id) sender;
- (IBAction) scrollToLastUpdatedIndex : (id) sender;
@end



@interface CMRThreadViewer(MoveActionSupport)
- (void) updateIndexField;
- (void) scrollMessageAtIndex : (int) index;
@end



@interface CMRThreadViewer(TextViewSupport)
- (IBAction) findNextText : (id) sender;
- (IBAction) findPreviousText : (id) sender;
- (IBAction) findFirstText : (id) sender;
- (IBAction) findTextInSelection : (id) sender;
- (IBAction) findAll : (id) sender;
- (IBAction) findAllByFilter : (id) sender;
- (void) findTextByFilter : (NSString    *) aString
			 searchOption : (CMRSearchMask) searchOption;
@end



@interface CMRThreadViewer(Validation)
- (BOOL) validateUIItem : (id) theItem;
@end



@interface CMRThreadViewer(SelectingThreads)
- (unsigned int) numberOfSelectedThreads;
- (NSDictionary *) selectedThread;
- (NSArray *) selectedThreads;
- (NSArray *) selectedThreadsReallySelected;
@end



extern NSString *const CMRThreadViewerDidChangeThreadNotification;
