// Deprecated method list
// このファイルには、BathyScaphe 1.0.x で廃止された、CocoMonar 時代の AppDefaults のメソッドの宣言が
// コメントとして書かれています。
// 単なる資料です。


/*** 掲示板ドロワー ***/
// deprecated in BathyScaphe 1.0.1.
/*
- (int) boardListState;
- (void) setBoardListState : (int) state;
- (float) boardListSizeWidth;
- (void) setBoardListSizeWidth : (float) width;
- (float) boardListSizeHeight;
- (void) setBoardListSizeHeight : (float) height;
- (NSRectEdge) boardListDrawerEdge;
- (void) setBoardListDrawerEdge : (NSRectEdge) edge;
- (NSSize) boardListContentSize;
- (void) setBoardListContentSize : (NSSize) contentSize;
- (BOOL) isBoardListOpen;
- (void) setIsBoardListOpen : (BOOL) isOpen;
*/

//- (NSColor *) browserStripedTableColor; // deprecated in BathyScpahe 1.0.1
//- (void) setBrowserStripedTableColor : (NSColor *) color; // deprecated in BathyScpahe 1.0.1

//- (BOOL) caretUsesTextColor; // deprecated in BathyScaphe 1.0.1
//- (void) setCaretUsesTextColor : (BOOL) flag; // deprecated in BathyScaphe 1.0.1

// @see CMXPopUpWindowAttributes.h
/* deprecated in BathyScaphe 1.0.1
- (BOOL) popUpWindowHasVerticalScroller;
- (BOOL) popUpWindowAutohidesScrollers;
- (void) setPopUpWindowAutohidesScrollers : (BOOL) flag;
- (void) setPopUpWindowHasVerticalScroller : (BOOL) flag;
*/
/*- (BOOL) isResPopUpSeeThrough;
- (void) setIsResPopUpSeeThrough : (BOOL) anIsResPopUpSeeThrough;*/ // deprecated in SledgeHammer and later.

//- (NSColor *) threadsListGridColor; // deprecated in BathyScaphe 1.0
//- (void) setThreadsListGridColor : (NSColor *) color; // deprecated in BathyScaphe 1.0


// statusLine
/* deprecated in BathyScaphe 1.0.2. */
/*
- (BOOL) statusLineUsesSpinningStyle;
- (void) setStatusLineUsesSpinningStyle : (BOOL) usesSpinningStyle;
- (int) statusLinePosition;
- (void) setStatusLinePosition : (int) aStatusLinePosition;
- (int) statusLineToolbarAlignment;
- (void) setStatusLineToolbarAlignment : (int) aStatusLineToolbarAlignment;
*/

/*
#define AppDefaultsBoardListSizeWidthKey		@"BoardListWidth"
#define AppDefaultsBoardListSizeHeightKey		@"BoardListHeight"
#define AppDefaultsBoardListStateKey		    @"BoardListShown"
#define AppDefaultsBoardListDrawerPreferedEdgeKey		@"BoardList PreferredEdge"
*/

//account
/* deprecated in SledgeHammer. */
//- (NSURL *) x2chRegistrationPageURL;
//- (NSURL *) be2chRegistrationPageURL;

//threadsList interCellSpacing
/* Deprecated in SledgeHammer and later. Use SGTemplateResource() instead. */
//- (NSSize) threadsListIntercellSpacing;
//- (void) setThreadsListIntercellSpacing : (NSSize) space;

//- (void) setThreadsListRowHeightNum : (NSNumber *) rowHeight;
//- (void) setThreadsListIntercellSpacingHeight : (NSNumber *) height;
//- (void) setThreadsListIntercellSpacingWidth : (NSNumber *) width;

//deprecated in SecondFlight and later.

/*
//1.0.9.6 以前のお気に入りをインポートしたかどうか 
- (BOOL) isFavoritesImported;
- (void) setIsFavoritesImported : (BOOL) TorF;
*/
