//
//  BSIndexingPopupper.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/06/21.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class CMRThreadVisibleRange;

@interface BSIndexingPopupper : NSObject {
	IBOutlet NSView				*m_frameView;
	IBOutlet NSPopUpButton		*m_firstVisibleRangePopUpButton;
	IBOutlet NSPopUpButton		*m_lastVisibleRangePopUpButton;
	IBOutlet NSPopUpButton		*m_keywordsButton;
	IBOutlet NSMenu				*m_keywordsMenuBase;
	id							m_delegate;
	CMRThreadVisibleRange		*m_visibleRange;
}

- (id) delegate;
- (void) setDelegate: (id) aDelegate;
- (NSView *) contentView;

- (NSPopUpButton *) firstVisibleRangePopUpButton;
- (NSPopUpButton *) lastVisibleRangePopUpButton;
- (NSPopUpButton *) keywordsButton;
- (CMRThreadVisibleRange *)	visibleRange;
- (void) setVisibleRange: (CMRThreadVisibleRange *) aVisibleRange;
- (void) updateKeywordsMenu;
- (IBAction) selectFirstVisibleRange: (id) sender;
- (IBAction) selectLastVisibleRange: (id) sender;
- (IBAction) selectKeyword: (id) sender;
- (IBAction) aboutKeywords: (id) sender;
- (void) setupVisibleRangePopUp;
- (void) syncButtonsWithCurrentRange;
@end

@interface NSObject(BSIndexingPopupperDelegate)
- (void) indexingPopupper: (BSIndexingPopupper *) popupper
	didChangeVisibleRange: (CMRThreadVisibleRange *) newRange;
@end