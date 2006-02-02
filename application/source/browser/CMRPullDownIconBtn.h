//
//  $Id: CMRPullDownIconBtn.h,v 1.2 2006/02/02 13:00:47 tsawada2 Exp $
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
