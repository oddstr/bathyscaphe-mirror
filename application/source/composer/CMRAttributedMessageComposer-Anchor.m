/**
  * $Id: CMRAttributedMessageComposer-Anchor.m,v 1.5 2008/10/12 16:49:15 tsawada2 Exp $
  * 
  * CMRAttributedMessageComposer-Anchor.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRAttributedMessageComposer_p.h"

#import "BSBeSAAPAnchorComposer.h"

// URL��������X�L����
static BOOL scanURLCharactersFallDown(NSScanner *scanner, NSMutableString *stringBuffer);

@implementation CMRAttributedMessageComposer(Anchor)
- (void) convertLinkAnchor : (NSMutableAttributedString *) message
{
	[self makeInnerLinkAnchor : message];
	[self makeOuterLinkAnchor : message];
}

/////////////////////////////////////////////////////////////////////
/////////////////////// ���������N�̍쐬 ////////////////////////////
/////////////////////////////////////////////////////////////////////
- (void) makeInnerLinkAnchor : (NSMutableAttributedString *) message
{
	NSScanner	*scanner_;
	
	scanner_ = [[NSScanner allocWithZone : [self zone]]
						  initWithString : [message string]];
	// ���̎��_�ŃG���e�B�e�B�͉�������Ă��Ȃ��Ă͂Ȃ�Ȃ��B
	// ���_�����i>,���Ȃǁj����n�܂镶������X�L����
	[self makeResLinkAnchor : message
		  startCharacterSet : [NSCharacterSet innerLinkPrefixCharacterSet]
		        withScanner : scanner_];
	[scanner_ release];
}

- (void) makeInnerLinkAnchorInNameField : (NSMutableAttributedString *) nameField
{
	NSScanner		*scanner_;
	NSString		*content_;
	NSCharacterSet	*readerSet_;
	NSRange			searchRange_;
	
	content_ = [nameField string];
	scanner_ = [[NSScanner allocWithZone : nil]
						  initWithString : content_];
	readerSet_ = [NSCharacterSet innerLinkPrefixCharacterSet];
	[scanner_ scanCharactersFromSet:readerSet_ intoString:NULL];
	
	searchRange_ = NSMakeRange(
						[scanner_ scanLocation], 
						[content_ length] - [scanner_ scanLocation]);
	[self makeResLinkAnchor : nameField
			  startingRange : searchRange_
			    withScanner : scanner_
		  startCharacterSet : readerSet_];
	[scanner_ release];
}

- (void) makeResLinkAnchor : (NSMutableAttributedString *) mAttrStr
		 startCharacterSet : (NSCharacterSet            *) cset
		       withScanner : (NSScanner                 *) scanner
{
	NSString       *content_;
	NSRange         searchRng_;
	NSRange         result_;
	unsigned int    length_;
	
	UTILAssertNotNil(cset);
	if (nil == mAttrStr || 0 == (length_ = [mAttrStr length])) return;
	
	content_ = [scanner string];
	searchRng_  = NSMakeRange(0, length_);
	[scanner setScanLocation : 0];
	// �����s�ɂ܂��������C���f�b�N�X�͓ǂ܂Ȃ��B
	// �܂��A�󔒂͂��̓s�x�A��΂��B
	[scanner setCharactersToBeSkipped : nil];
	
	while ((result_ = [content_ rangeOfCharacterFromSet : cset
							                   options : NSLiteralSearch
							                     range : searchRng_]).length != 0)
	{
		[self makeResLinkAnchor : mAttrStr
				  startingRange : result_
				    withScanner : scanner
			  startCharacterSet : cset];
		//�����͈͂��w��(1)
		searchRng_.location = [scanner scanLocation];
		searchRng_.length   = length_ - searchRng_.location;
		
	}
}

- (BOOL)  makeResLinkAnchor : (NSMutableAttributedString *) mAttrStr
              startingRange : (NSRange                    ) linkRange
                withScanner : (NSScanner                 *) scanner
		  startCharacterSet : (NSCharacterSet            *) startCharacters
{
	NSString			*src_;
	NSString			*link_;
	NSCharacterSet		*cset_;
	NSRange				specRange;			// �͈͎w�蕔��
	unsigned			scanLocation_;
	static NSCharacterSet *whiteSpaceSet = nil;
	if (!whiteSpaceSet) {
		whiteSpaceSet = [[NSCharacterSet whitespaceCharacterSet] retain];
	}
	src_ = [scanner string];
	
	// �X�L�����J�n�B
	// �n�_�����Ƌ󔒂͔�΂�
	[scanner setScanLocation : linkRange.location];
	[scanner scanCharactersFromSet : startCharacters 
						intoString : NULL];
//	cset_ = [NSCharacterSet whitespaceCharacterSet];
//	[scanner scanCharactersFromSet:cset_ intoString:NULL];
	[scanner scanCharactersFromSet:whiteSpaceSet intoString:NULL];
	
	specRange.location = [scanner scanLocation];
	specRange.length   = 0;
	
	// �����N�ł͂Ȃ���Ƃ���
	scanLocation_ = NSNotFound;
	while (1) {
		unichar		c;
		
		cset_ = [NSCharacterSet numberCharacterSet_JP];
		if (NO == [scanner scanCharactersFromSet:cset_ intoString:NULL])
			break;
		
		// �ЂƂł����l��ǂ񂾂�A�����N��\�邱�Ƃ��ł���
		scanLocation_ = [scanner scanLocation];
		
//		cset_ = [NSCharacterSet whitespaceCharacterSet];
//		[scanner scanCharactersFromSet:cset_ intoString:NULL];
		[scanner scanCharactersFromSet:whiteSpaceSet intoString:NULL];
		if ([scanner isAtEnd]) break;
		
		// ��؂蕶���܂��͔͈͎w�蕶��
		c = [src_ characterAtIndex : [scanner scanLocation]];
		cset_ = [NSCharacterSet innerLinkRangeCharacterSet];
		if (NO == [cset_ characterIsMember : c]) {
			cset_ = [NSCharacterSet innerLinkSeparaterCharacterSet];
			if (NO == [cset_ characterIsMember : c])
				break;
		}
		[scanner setScanLocation : [scanner scanLocation] +1];
		
//		cset_ = [NSCharacterSet whitespaceCharacterSet];
//		[scanner scanCharactersFromSet:cset_ intoString:NULL];
		[scanner scanCharactersFromSet:whiteSpaceSet intoString:NULL];
	}
	if (NSNotFound == scanLocation_)
		return NO;
	
	// ���l��ǂݍ��񂾒���̈ʒu�ɖ߂�
	[scanner setScanLocation : scanLocation_];
	
	
	linkRange.length = ([scanner scanLocation] - linkRange.location);
	specRange.length = ([scanner scanLocation] - specRange.location);
	
	link_ = [NSString stringWithFormat : @"%@:%@", CMRAttributeInnerLinkScheme, [[scanner string] substringWithRange : specRange]];
	
	[mAttrStr addAttribute : NSLinkAttributeName
				     value : link_
					 range : linkRange];
	return YES;
}

/////////////////////////////////////////////////////////////////////
/////////////////////// �O�������N�̍쐬 ////////////////////////////
/////////////////////////////////////////////////////////////////////
static NSString *const kColonSlash2LinkURLString = @"://";
static NSString *const kSlash2LinkURLString      = @"//";
static NSString *const kW3LinkURLString          = @"www.";
static NSString *const kURLDefaultProtocol       = @"http";
static NSString *const kURLHTTPSProtocol         = @"https";
	
- (void)makeOuterLinkAnchor:(NSMutableAttributedString *)theMessage
{
    NSScanner *scanner_ = nil;
    NSString *content_ = [theMessage string];
    unsigned int length_ = [theMessage length];
    NSRange linkRange_   = kNFRange;

    NSRange searchRange_;
    NSMutableString *anchor_;
    unsigned int scanIndex_;

	BSBeSAAPAnchorComposer *helper = nil;
    
    if (!theMessage || length_ == 0) {
		return;
    }

    scanner_ = [[NSScanner alloc] initWithString:content_];
    [scanner_ setCharactersToBeSkipped:nil];
    
    // www.foo.com/...
    searchRange_ = NSMakeRange(0, length_);
    [scanner_ setScanLocation:0];
    while ((linkRange_ = [content_ rangeOfString:kW3LinkURLString options:NSLiteralSearch range:searchRange_]).length != 0) {
        scanIndex_ = NSMaxRange(linkRange_);
        searchRange_.location = scanIndex_;
        searchRange_.length = (length_ - searchRange_.location);
        if (scanIndex_ != 0 && '/' == [content_ characterAtIndex:linkRange_.location -1]) {
            continue;
        }
        [scanner_ setScanLocation:scanIndex_];
        if ([scanner_ isAtEnd]) {
			break;
        }
        // URL������
		anchor_ = [NSMutableString stringWithString:@"http://www."];
        if (!scanURLCharactersFallDown(scanner_, anchor_)) {
            continue;
        }
        // ���̌����͈͂̎w��i2�j
        scanIndex_ = [scanner_ scanLocation];
        searchRange_.location = scanIndex_;
        searchRange_.length = (length_ - searchRange_.location);
        // �����N��ݒ肷��͈͂̎w��
        linkRange_.length = (scanIndex_ - linkRange_.location);

        [theMessage addAttribute:NSLinkAttributeName value:anchor_ range:linkRange_];
    }

    // http://..., ttp://..., etc
    searchRange_ = NSMakeRange(0, length_);
    [scanner_ setScanLocation : 0];
    while ((linkRange_ = [content_ rangeOfString : kSlash2LinkURLString
                               options : NSLiteralSearch
                               range : searchRange_]).length != 0) {
        scanIndex_ = NSMaxRange(linkRange_);
        [scanner_ setScanLocation : scanIndex_];
        if ([scanner_ isAtEnd]) break;
        
        scanIndex_ = linkRange_.location;
        if (scanIndex_ > 0) scanIndex_--;
        
        anchor_ = [kColonSlash2LinkURLString mutableCopyWithZone : nil];
        [anchor_ autorelease];
        
        if (NSLocationInRange(scanIndex_, searchRange_) && 
            ':' == [content_ characterAtIndex:scanIndex_]) {
            NSRange        prtRng_;
            NSString    *protocol_;
            unichar        c;
            
            protocol_ = kURLDefaultProtocol;
            UTILRequireCondition(scanIndex_ > 0, EndInsertString);
            
            prtRng_.location = scanIndex_;
            prtRng_.length = 0;
            c = [content_ characterAtIndex:(prtRng_.location -1)];
            while ('a' <= c && c <= 'z') {
                prtRng_.location--;
                prtRng_.length++;
                if (NO == NSLocationInRange(prtRng_.location, searchRange_))
                    break;
                if (0 == prtRng_.location)
                    break;
                c = [content_ characterAtIndex:(prtRng_.location -1)];
            }
            
            protocol_ = [content_ substringWithRange : prtRng_];
            if ([kURLDefaultProtocol hasSuffix : protocol_] || 0 == [protocol_ length]) {
                
                protocol_ = kURLDefaultProtocol;
            } else if ( [kURLHTTPSProtocol hasSuffix : protocol_] ) {
                protocol_ = kURLHTTPSProtocol;
            }
            
            scanIndex_ = prtRng_.location;
            
EndInsertString:
            [anchor_ insertString:protocol_ atIndex:0];
            
            linkRange_.length += (linkRange_.location - scanIndex_);
            linkRange_.location = scanIndex_;
        } else {
            if (![scanner_ scanString:kW3LinkURLString intoString:NULL]) {
                // ���̌����͈͂̎w��i1�j
                scanIndex_ = [scanner_ scanLocation];
                searchRange_.location = scanIndex_;
                searchRange_.length = (length_ - searchRange_.location);
                continue;
            }

            linkRange_.length += [kW3LinkURLString length];
            [anchor_ appendString:kW3LinkURLString];
            [anchor_ insertString:kURLDefaultProtocol atIndex:0];
        }
        
        // ���̎��_��
        // (xxxx)://www., �܂��� http:// 
        
        scanIndex_ = NSMaxRange(linkRange_);
        [scanner_ setScanLocation:scanIndex_];
        if ([scanner_ isAtEnd]) break;
        
        // ���̌����͈͂̎w��i1�j
        scanIndex_ = [scanner_ scanLocation];
        searchRange_.location = scanIndex_;
        searchRange_.length = (length_ - searchRange_.location);
        
        if (!scanURLCharactersFallDown(scanner_, anchor_))
            continue;
        
        // ���̌����͈͂̎w��i2�j
        scanIndex_ = [scanner_ scanLocation];
        searchRange_.location = scanIndex_;
        searchRange_.length = (length_ - searchRange_.location);
        // �����N��ݒ肷��͈͂̎w��
        linkRange_.length = (scanIndex_ - linkRange_.location);
        
		if ([anchor_ hasPrefix:@"sssp://"]) {
			helper = [[BSBeSAAPAnchorComposer alloc] initWithRange:linkRange_ saapLinkString:anchor_];
		} else {
			[theMessage addAttribute:NSLinkAttributeName value:anchor_ range:linkRange_];
		}
    }

	if (helper) {
		[helper composeSAAPAnchorIfNeeded:theMessage];
		[helper release];
		helper = nil;
	}

    [scanner_ release];
}
@end



/*!
 * @constant    kLinkFullSizeTildeUnicharMap1
 * @constant    kLinkFullSizeTildeUnicharMap2
 * @discussion  �S�p�`���_
 */
static const unichar kLinkFullSizeTildeUnicharMap1 = 0x301c;
static const unichar kLinkFullSizeTildeUnicharMap2 = 0xff5e;


// NULL Terminated
static NSString **fdNonStandardURLCharacters(void)
{
	static NSString *kNonStandardURLCharacters[3] = {NULL,};
	
	if (NULL == kNonStandardURLCharacters[0]) {
		kNonStandardURLCharacters[0] = 
			[[NSString alloc] initWithCharacter : kLinkFullSizeTildeUnicharMap1];
		kNonStandardURLCharacters[1] = 
			[[NSString alloc] initWithCharacter : kLinkFullSizeTildeUnicharMap2];
		kNonStandardURLCharacters[2] = NULL;
	}
	return kNonStandardURLCharacters;
}
static NSString **fdStandardURLCharacters(void)
{
	static NSString *kFdStandardURLCharacters[3] = {
				@"~", @"~", NULL};
	
	return kFdStandardURLCharacters;
}


// URL��������X�L����
static BOOL scanURLCharactersFallDown(NSScanner *scanner, NSMutableString *stringBuffer)
{
	NSCharacterSet		*cset_;
	NSString			*scanned_;
	BOOL				scanResult_ = NO;
	
	cset_ = [NSCharacterSet URLCharacterSet];
	while (1) {
		NSString	**fdNSUURLs_ = fdNonStandardURLCharacters();
		NSString	**fdSURLs_   = fdStandardURLCharacters();
		
		for (; (*fdNSUURLs_ != NULL && *fdSURLs_ != NULL); fdNSUURLs_++) {
			// �S�p�`���_�Ȃǂ�ϊ�
			if ([scanner scanString:*fdNSUURLs_ intoString:NULL])
				[stringBuffer appendString : *fdSURLs_];
			
			fdSURLs_++;
		}
		
		if (![scanner scanCharactersFromSet:cset_ intoString:&scanned_]) {
			break;
		}

		[stringBuffer appendString:scanned_];
		scanResult_ = YES;
	}
	
	return scanResult_;
}
