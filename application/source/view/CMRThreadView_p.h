//
//  CMRThreadView_p.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/09/07.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRThreadView.h"
#import "SGHTMLView_p.h"

#import "CMRThreadSignature.h"
#import "CMRThreadLayout.h"
#import "CMRThreadMessage.h"
#import "CMRThreadMessageBuffer.h"
#import "CMRMessageFilter.h"

@interface CMRThreadView(Action)
- (BOOL)setUpMessageActionMenuItem:(NSMenuItem *)theItem forIndexes:(NSEnumerator *)anIndexEnum withAttributeName:(NSString *)aName;

// Contextual Menu Items
- (IBAction)messageCopy:(id)sender;
- (IBAction)messageReply:(id)sender;
- (IBAction)changeMessageAttributes:(id)sender;
- (IBAction)googleSearch:(id)sender;
- (IBAction)openWithWikipedia:(id)sender;
- (IBAction)messageGyakuSansyouPopUp:(id)sender;
@end

// Constants

#define kMessageActionMenuTag	-1
#define kLocalAboneTag			0
#define kInvisibleAboneTag		1
#define kAsciiArtTag			2
#define kBookmarkTag			3
#define kSpamTag				4

// @see googleSearch:
#define kPropertyListGoogleQueryKey		@"Thread - GoogleQuery"
#define kGoogleQueryValiableKey			@"%%%Query%%%"
// @see openWithWikipedia:
#define kPropertyListWikipediaQueryKey		@"Thread - WikipediaQuery"
