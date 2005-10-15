//:SGHTMLView_p.h
#import "SGHTMLView.h"
#import "CocoMonar_Prefix.h"

#import "SGLinkCommand.h"
//#import "NSCursor+CMXAdditions.h"
#import "CMRMessageAttributesTemplate.h"
#import <SGAppKit/SGAppKit.h>


#define kLocalizableFile	@"HTMLView"
#define kLinkStringKey		@"Link"
#define kCopyLinkStringKey	@"Copy Link"
#define kOpenLinkStringKey	@"Open Link"
#define kPreviewLinkStringKey @"Preview Link"



@interface SGHTMLView(Link)
- (NSMutableDictionary *) trackingRectTags;
- (NSTrackingRectTag) visibleRectTag;

- (void) resetCursorRectsImp;
- (void) responseMouseEvent : (NSEvent *) theEvent
			   mouseEntered : (BOOL     ) isMouseEntered;
- (void) updateAnchoredRectsInBounds : (NSRect    ) aBounds
						forAttribute : (NSString *) attributeName;

- (NSMutableArray *) userDataArray;
- (void) resetTrackingVisibleRect;
- (NSTrackingRectTag) addLinkTrackingRect : (NSRect) aRect
                                     link : (id    ) aLink;
- (void) removeAllLinkTrackingRects;
- (NSRect) trackingRectForTag : (NSTrackingRectTag) aTag;
@end



@interface SGHTMLView(ResponderExtensions)
- (NSMenuItem *) commandItemWithLink : (id		  ) aLink
							 command : (Class	  ) aFunctorClass
							   title : (NSString *) aTitle;
- (NSMenu *) linkMenuWithLink : (id) aLink;
- (NSMenu *) linkMenuWithLink : (id) aLink
				 forImageFile : (BOOL) isImage; // added in Lemonade and later.
- (BOOL) validateLinkByFiltering : (id) aLink;
- (BOOL) validateLinkForImage : (id) aLink; // added in Lemonade and later.

- (void) pushCloseHandCursorIfNeeded;
- (void) commandMouseDragged : (NSEvent *) theEvent;
- (void) commandMouseUp : (NSEvent *) theEvent;
- (void) commandMouseDown : (NSEvent *) theEvent;
@end



@interface SGHTMLView(DelegateSupport)
- (void) mouseEventInVisibleRect : (NSEvent *) theEvent
						 entered : (BOOL)mouseEntered;
- (void) processMouseEvent : (id       ) userData
              trackingRect : (NSRect   ) aRect
                 withEvent : (NSEvent *) anEvent
              mouseEntered : (BOOL     ) flag;

- (BOOL) shouldHandleContinuousMouseDown : (NSEvent *) theEvent;
- (BOOL) handleContinuousMouseDown : (NSEvent *) theEvent;
@end
