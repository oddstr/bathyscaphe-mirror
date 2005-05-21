//
//  CMRNSSearchField.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/04/30.
//

#import <Cocoa/Cocoa.h>

// menuItem tags
#define kSearchPopUpOptionItemTag			11
#define kSearchPopUpSeparatorTag			22
#define kSearchPopUpHistoryHeaderItemTag	33
#define kSearchPopUpHistoryItemTag			44

@interface CMRNSSearchField : NSObject {
	IBOutlet NSSearchField *searchField;
}

- (NSSearchField *) pantherSearchField;
- (void) setupUIComponents;

@end
