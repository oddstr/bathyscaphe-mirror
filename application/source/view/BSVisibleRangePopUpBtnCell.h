//
//  BSVisibleRangePopUpBtnCell.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/03/07.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>
#import <SGAppKit/BSTsuruPetaPopUpBtnCell.h>

@class CMRThreadVisibleRange;

@interface BSFirstRangePopUpBtnCell: BSTsuruPetaPopUpBtnCell {
}

- (void) setupPopUpMenuBase;
- (void) syncWithCurrentRange: (CMRThreadVisibleRange *) visibleRange;

// subclass should override these methods
+ (NSString *) numberPlistFileName;
- (NSString *) localizedMenuItemTitleTemplate;
- (unsigned) eitherOfLength: (CMRThreadVisibleRange *) range;
@end

@interface BSLastRangePopUpBtnCell: BSFirstRangePopUpBtnCell {
}
@end
