//:CMRAttributedMessageComposer_p.h
#import "CMRAttributedMessageComposer.h"

#import "CocoMonar_Prefix.h"
#import "AppDefaults.h"
#import "CMRThreadMessage.h"
#import "CMRMessageAttributesStyling.h"
#import "CMRMessageAttributesTemplate.h"
#import "CMXTextParser.h"



#define ATTR_TEMPLATE	[CMRMessageAttributesTemplate sharedTemplate]
#define DEFAULT_NEWLINE_CHARACTER				@"\n"



@interface CMRAttributedMessageComposer(Mail)
- (void) appendMailAttachmentWithAddress : (NSString *) address;
- (void) appendMailAddressWithAddress : (NSString *) address;
@end



//:CMRAttrMessageComposer-Convert.m
@interface CMRAttributedMessageComposer(Convert)
- (void) convertMessage : (NSString                  *) message
				   with : (NSMutableAttributedString *) buffer;
- (void) convertName : (NSString                  *) name
				with : (NSMutableAttributedString *) buffer;
@end



//:CMRAttrMessageComposer-Convert.m
@interface CMRAttributedMessageComposer(Anchor)
- (void) convertLinkAnchor : (NSMutableAttributedString *) message;
- (void) makeInnerLinkAnchor : (NSMutableAttributedString *) message;
- (void) makeInnerLinkAnchorInNameField : (NSMutableAttributedString *) name;
- (void) makeResLinkAnchor : (NSMutableAttributedString *) mAttrStr
		 startCharacterSet : (NSCharacterSet            *) cset
		       withScanner : (NSScanner                 *) scanner;
- (BOOL)  makeResLinkAnchor : (NSMutableAttributedString *) mAttrStr
              startingRange : (NSRange                    ) startingRange
                withScanner : (NSScanner                 *) scanner
		  startCharacterSet : (NSCharacterSet            *) cset;
- (void) makeOuterLinkAnchor : (NSMutableAttributedString *) message;
@end



