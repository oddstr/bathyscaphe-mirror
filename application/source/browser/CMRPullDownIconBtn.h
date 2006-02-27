//
//  $Id: CMRPullDownIconBtn.h,v 1.1.1.1.4.1 2006/02/27 17:31:49 masakih Exp $
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

@end
