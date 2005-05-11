/**
  * $Id: NSString+TEC.m,v 1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * NSString+TEC.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <SGFoundation/NSString-SGExtensions.h>
#import <SGFoundation/String+Utils.h>
#import <SGFoundation/NSMutableString-SGExtensions.h>
#import <SGFoundation/NSCharacterSet-SGExtensions.h>
#import "UTILKit.h"


// BOM
static const UniChar kBOMUniChar = 0xFEFF;

// for Workaround missing API
struct TECObjectRep {
	UInt32 skip1;
	UInt32 skip2;
	UInt32 skip3;
	OptionBits optionsControlFlags;
};



static TextEncoding GetTextEncodingForNSString(void);
static NSString *AllocateNSStringWithBytesUsingTEC(const UInt8 *srcBuffer, size_t srcLength, TextEncoding theEncoding, BOOL flush);



@implementation NSString(SGExtensionTEC)
// Using TEC
- (id) initWithDataUsingTEC : (NSData     *) theData
                   encoding : (TextEncoding) encoding
{
	return AllocateNSStringWithBytesUsingTEC(
				[theData bytes],
				[theData length],
				encoding,
				YES);
}
+ (id) stringWithDataUsingTEC : (NSData     *) theData
                     encoding : (TextEncoding) encoding
{
	return [[[self alloc] initWithDataUsingTEC : theData 
									  encoding : encoding] autorelease];
}
@end



static TextEncoding GetTextEncodingForNSString(void)
{
	return CreateTextEncoding(
						kTextEncodingUnicodeDefault,
						kTextEncodingDefaultVariant,
						kUnicode16BitFormat);
}

static id AllocateNSStringWithBytesUsingTEC(const UInt8 *srcBuffer, size_t srcLength, TextEncoding theEncoding, BOOL flush)
{

	static TECObjectRef		cachedConverter = NULL;
	static CFStringEncoding	cachedEncoding  = kCFStringEncodingInvalidId;
	
	OSStatus			err;
	TECObjectRef		encodingConverter = NULL;
	CFStringEncoding	encoding          = theEncoding;
	CFMutableStringRef	result            = nil;
	
	// Naki-Wakare
	unsigned int _partialCharLen;
    UInt8 _partialCharBuffer[16];


	// Get a Text Encoding Converter for the passed-in encoding.
	if (cachedEncoding == encoding) {
		encodingConverter = cachedConverter;
		TECClearConverterContextInfo(encodingConverter);
		
		cachedConverter = NULL;
		cachedEncoding  = kCFStringEncodingInvalidId;
	} else {
		TextEncoding		toEncoding;
		struct TECObjectRep	**peek_;
		
		toEncoding = GetTextEncodingForNSString();
		err = TECCreateConverter(
					&encodingConverter,
					encoding,
					toEncoding);
		
		if (err) goto ErrTECCreateConverter;
		// Workaround for missing TECSetBasicOptions call.
/*
		TECSetBasicOptions(_converter, kUnicodeForceASCIIRangeMask);
*/
		peek_ = (struct TECObjectRep	**)encodingConverter;
		peek_[0]->optionsControlFlags = kUnicodeForceASCIIRangeMask;
	}
	
	//Naki-Wakare
	_partialCharLen = 0;
	
	//const UInt8		*sourcePointer = srcBuffer;
	//ByteCount		sourceLength   = srcLength;

	//Naki-Wakare
    const UInt8 *sourcePointer;
    ByteCount sourceLength;

    if(_partialCharLen == 0) {
        sourcePointer = srcBuffer;
        sourceLength = srcLength;
    }
    else {
        sourceLength = _partialCharLen + srcLength;
        if(sourceLength > 16) {
            sourceLength = 16;
        }

        memcpy(_partialCharBuffer + _partialCharLen, srcBuffer, sourceLength - _partialCharLen);
        sourcePointer = _partialCharBuffer;
    }
//end Naki-Wakare
	
	result = (CFMutableStringRef)[[NSMutableString alloc] init];
	while (1) {
		UniChar		buffer[4096];
		//Naki-Wakare
		ByteCount	bytesRead = 0;
		//end
		ByteCount	bytesWritten = 0;
		bool		doingFlush = false;
		
		if (sourceLength == 0) {
			if (!flush) {
				// Done.
				break;
			}
			doingFlush = true;
		}
		 
		if (doingFlush) {
			err = TECFlushText(encodingConverter,
							(UInt8 *)buffer,
							sizeof(buffer),
							&bytesWritten);
			//Naki-Wakare
            _partialCharLen = 0;
		} else {
			bytesRead = 0;//ByteCount	bytesRead = 0;
			
			err = TECConvertText(
					encodingConverter,
					sourcePointer,
					sourceLength,
					&bytesRead,
					(UInt8 *)buffer,
					sizeof(buffer),
					&bytesWritten);
			sourcePointer += bytesRead;
			sourceLength  -= bytesRead;
		}
		
		
		// Appending Decoded Bytes
		if (bytesWritten) {
			int	i;
			int start = 0;
			int characterCount = 0;
			
			NSCAssert2(bytesWritten % sizeof(UniChar) == 0,
				@"Written Bytes must be sizeof(UniChar)<%u> * X, but was %u",
				sizeof(UniChar),
				bytesWritten);
			
			characterCount = bytesWritten / sizeof(UniChar);
			for (i = 0; i < characterCount; i++) {
				// BOM:
				if (kBOMUniChar == buffer[i]) {
					if (start != i) {
						CFStringAppendCharacters(
							result,
							(&buffer[start]),
							i - start);
					}
					start = i + 1;
				}
			}
			if (start != characterCount) {
				CFStringAppendCharacters(
					result,
					(&buffer[start]),
					characterCount - start);
			}
		}
		
		// MalformedInput || UndefinedElement
		if (err == kTextMalformedInputErr || err == kTextUndefinedElementErr) {
			// FIXME: Put in FFFD character here?
			TECClearConverterContextInfo(encodingConverter);
			if (sourceLength) {
				sourcePointer += 1;
				sourceLength -= 1;
			}
			err = noErr;
		}
		//Naki-Wakare
        if (_partialCharLen > 0) {
            unsigned int skipLen;
            if(bytesRead < _partialCharLen) {
                skipLen = 0;
            }
            else {
                skipLen = bytesRead - _partialCharLen;
            }
            sourcePointer = srcBuffer + skipLen;
            sourceLength = srcLength - skipLen;
            if(err == kTECPartialCharErr) {
                err = noErr;
            }
            _partialCharLen = 0;
        }
		
		if (err == kTECOutputBufferFullStatus)
			continue;
			
		// Naki-Wakare
		if (err == kTECPartialCharErr) {
            if(sourceLength < 16) {
                memcpy(_partialCharBuffer, sourcePointer, sourceLength);
                _partialCharLen = sourceLength;
            }
            sourcePointer += sourceLength;
            sourceLength = 0;
			err = noErr;
		}
		
		if (err != noErr) goto ErrTextDecoding;
		// Done
		if (doingFlush) break;
	}
	
	return (id)result;

ErrTECCreateConverter:
	NSLog(@"[TEC] won't convert from text encoding 0x%X, error %ld",
			encoding,
			err);
	return nil;
ErrTextDecoding:
	NSLog(@"[TEC] text decoding failed with error %d", err);
	return nil;
}
