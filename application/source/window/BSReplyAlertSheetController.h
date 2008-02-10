//
//  BSReplyAlertSheetController.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/10.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>


@interface BSReplyAlertSheetController : NSWindowController {
	IBOutlet NSObjectController	*alertContentController;

	@private
	NSString	*m_helpAnchor;
}

- (NSString *)helpAnchor;
- (void)setHelpAnchor:(NSString *)anchor;

// NSObjectController's content object (NSDictionary.)
- (id)alertContent;
- (void)setAlertContent:(id)content;

// Treat sender's tag as returnCode
- (IBAction)endSheetWithCodeAsTag:(id)sender;
@end

// content object dictionary keys
extern NSString *const kAlertMessageTextKey; // NSString
extern NSString *const kAlertInformativeTextKey; // NSString
extern NSString *const kAlertAgreementTextKey; // NSString
extern NSString *const kAlertIsContributionKey; // NSNumber (as BOOL)
extern NSString *const kAlertFirstButtonLabelKey; // NSString
extern NSString *const kAlertSecondButtonLabelKey; // NSString
