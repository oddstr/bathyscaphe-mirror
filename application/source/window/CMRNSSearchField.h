//
//  CMRNSSearchField.h
//  CocoMonar
//
//  Created by Tsutomu Sawada on 05/04/30.
//

#import <Cocoa/Cocoa.h>


@interface CMRNSSearchField : NSObject {
	IBOutlet NSSearchField *searchField;
}
- (NSSearchField *) pantherSearchField;
- (void) setupUIComponents;
- (IBAction) searchString : (id) sender;
@end
