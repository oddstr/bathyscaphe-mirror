//
//  $Id: CMRPullDownIconBtn.h,v 1.3 2007/02/12 15:07:34 tsawada2 Exp $
//  CocoMonar & BathyScaphe
//
//  Created by tsawada2 on 05/01/09.
//  Action Button (Pull-down Menu + Icon, like Panther Mail.app)
//

#import <Cocoa/Cocoa.h>

@interface CMRPullDownIconBtn : NSPopUpButtonCell {
	@private
	NSImage	*_btnImg;
	NSImage *_btnImgPressed;
}
- (void) setBtnImg : (NSImage *) anImage;
- (void) setBtnImgPressed : (NSImage *) anImage;
@end
