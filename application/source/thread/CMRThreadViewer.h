/**
  * $Id: CMRThreadViewer.h,v 1.17 2007/01/31 18:02:25 tsawada2 Exp $
  * BathyScaphe
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * Copyright (c) 2005-2006, BathyScaphe Project.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>
#import "CMRStatusLineWindowController.h"
#import "CMRFavoritesManager.h"

@class CMRIndexingStepper;
@class CMRThreadLayout;
@class CMRThreadAttributes;
@class CMRThreadSignature;
@class BSIndexingPopupper;

@interface CMRThreadViewer : CMRStatusLineWindowController
{	
	// History
	unsigned					_historyIndex;
	NSMutableArray				*_history;
	
	// Helper
	CMRThreadLayout				*_layout;
	
	// Interface
	CMRIndexingStepper			*m_indexingStepper;
	BSIndexingPopupper			*m_indexingPopupper;
	IBOutlet NSView				*m_navigationBar;
	
	IBOutlet NSView				*m_componentsView;
	IBOutlet NSView				*m_containerView;
	IBOutlet NSView				*m_windowContentView;	// dummy
	
	IBOutlet NSScrollView		*m_scrollView;
	IBOutlet NSTextView			*m_textView;
	
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

- (NSString *) titleForTitleBar;

/* called when thread did be changed */
- (void) didChangeThread;

/*** NO_NAME properties ***/
- (NSString *) detectDefaultNoName;
- (void) setupDefaultNoNameIfNeeded;

- (NSString *) path;
- (NSString *) title;
- (NSString *) boardName;
- (NSURL *) boardURL;
- (NSURL *) threadURL;
- (NSString *) datIdentifier;
- (NSString *) bbsIdentifier;

- (BOOL) isAAThread;
- (void) setAAThread : (BOOL) flag;
// available in BathyScaphe 1.2 and later.
- (BOOL) isDatOchiThread;
- (void) setDatOchiThread : (BOOL) flag;
- (BOOL) isMarkedThread;
- (void) setMarkedThread : (BOOL) flag;

// testing: BathyScaphe 1.5
- (NSString *) boardNameArrowingSecondSource;
@end



@interface CMRThreadViewer(Action)
- (NSPoint) locationForInformationPopUp;

// NOTE: CMRBrowser overrides this method.
- (NSArray *) targetThreadsForAction: (SEL) action;

- (BOOL) forceDeleteThreadAtPath : (NSString *) filepath
				   alsoReplyFile : (BOOL      ) deleteReply;

// KeyBinding...
- (IBAction) deleteThread : (id) sender;
- (IBAction) reloadThread : (id) sender;
- (IBAction) reply : (id) sender;

//- (IBAction) toggleAAThread : (id) sender; // Moved to CMRAbstructThreadDocument.

- (IBAction) copyThreadAttributes : (id) sender;
//- (IBAction) showThreadAttributes : (id) sender; // Moved to CMRAbstructThreadDocument.

- (IBAction) copySelectedResURL : (id) sender;
- (IBAction) reloadIfOnlineMode : (id) sender;
- (IBAction) openInBrowser : (id) sender;
- (IBAction) openBBSInBrowser : (id) sender;
- (IBAction) addFavorites : (id) sender;

// make text area to be first responder
- (IBAction) focus : (id) sender;
// NOTE: It is a history item's action.
- (IBAction) showThreadWithMenuItem : (id) sender;
// available in SledgeHammer and later.
//- (IBAction) orderFrontMainBrowser : (id) sender; // Moved to CMRAbstructThreadDocument.
// available in Vita and later.
//- (IBAction) toggleDatOchiThread : (id) sender; // Moved to CMRAbstructThreadDocument.
//- (IBAction) toggleMarkedThread : (id) sender; // Moved to CMRAbstructThreadDocument.
@end


@interface CMRThreadViewer(History)
// History: ThreadSignature...
- (unsigned) historyIndex;
- (void) setHistoryIndex : (unsigned) aHistoryIndex;
- (NSMutableArray *) threadHistoryArray;

- (id) threadIdentifierFromHistoryWithRelativeIndex : (int) relativeIndex;
- (void) noteHistoryThreadChanged : (int) relativeIndex;
- (void) clearThreadHistories;

- (IBAction) historyMenuPerformForward : (id) sender;
- (IBAction) historyMenuPerformBack : (id) sender;
@end


@interface CMRThreadViewer(MoveAction)
/* �ŏ��^�Ō�̃��X */
- (IBAction) scrollFirstMessage : (id) sender;
- (IBAction) scrollLastMessage : (id) sender;

/* ���^�O�̃��X */
- (IBAction) scrollPrevMessage : (id) sender;
- (IBAction) scrollPreviousMessage : (id) sender;
- (IBAction) scrollNextMessage : (id) sender;

/* ���^�O�̃u�b�N�}�[�N */
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

// Available in TestaRossa and later.
- (void) findTextByFilter : (NSString    *) aString
				targetKey : (NSString	 *) targetKey
			 searchOption : (CMRSearchMask) searchOption
			 locationHint : (NSPoint	  ) location
				   hilite : (BOOL		  ) hilite;
@end



@interface CMRThreadViewer(Validation)
- (BOOL) validateDeleteThreadItemEnabling: (NSString *) threadPath;
- (void) validateDeleteThreadItemTitle: (id) theItem;
- (CMRFavoritesOperation) favoritesOperationForThreads: (NSArray *) threadsArray;
- (BOOL) validateAddFavoritesItem: (id) theItem forOperation: (CMRFavoritesOperation) operation;
- (BOOL) validateUIItem : (id) theItem;
@end



@interface CMRThreadViewer(SelectingThreads)
- (unsigned int) numberOfSelectedThreads;
- (NSDictionary *) selectedThread;
- (NSArray *) selectedThreads;
- (NSArray *) selectedThreadsReallySelected;
@end



extern NSString *const CMRThreadViewerDidChangeThreadNotification;

/**
  * userInfo:
  * 	@"Count"	-- number of found items (NSNumber, as an unsigned int)
  *
  */
#define kAppThreadViewerFindInfoKey	@"Count"

extern NSString *const BSThreadViewerWillStartFindingNotification;
extern NSString *const BSThreadViewerDidEndFindingNotification;
