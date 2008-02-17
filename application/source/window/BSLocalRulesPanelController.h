//
//  BSLocalRulesPanelController.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/11.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>


@interface BSLocalRulesPanelController : NSWindowController {
	IBOutlet NSObjectController *m_objectController;
	IBOutlet NSTextView			*m_textView;
}
- (NSObjectController *)objectController;
- (NSTextView *)textView;

- (void)setObjectControllerContent:(id)contentObject bindToTextView:(BOOL)flag;

- (IBAction)reload:(id)sender;
@end
