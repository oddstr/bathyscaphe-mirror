#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <Foundation/Foundation.h>

#define MA_VERSION_MASK			(0x3800000)		// 24-26 (3bit)
#define MA_FL_NOT_TEMP_MASK		(0xfffff)		// 20bit
#define MA_VERSION_1_0_MAGIC	(0x28000)		// version 1.0 magic number
#define MA_VERSION_1_1_MAGIC	(0x800000U)		// version 1.1 magic number
#define ABONED_FLAG				(0x40)			// 7 (different from LOCAL ABONE)
#define INVISIBLE_ABONED_FLAG	(0x100)			// 9
#define SPAM_FLAG				(0x400)			// 11

static BOOL isNotAbonedRes(id rep)
{
	//UInt32		version_;
	UInt32		flags_;
	
	if (rep == nil) return YES;
		
	flags_ = [rep unsignedIntValue];
	
	/*version_ = (flags_ & MA_VERSION_MASK);
	if (0 == version_) {
		if (flags_ & MA_VERSION_1_0_MAGIC) {
			flags_ &= (~MA_VERSION_1_0_MAGIC);
			flags_ &= MA_VERSION_1_1_MAGIC;
		}
	}
	
	if((flags_ & MA_VERSION_1_1_MAGIC) <= 0) return NO; */
	
	flags_ &= MA_FL_NOT_TEMP_MASK;
	if (((flags_ & SPAM_FLAG) > 0) ||
		((flags_ & INVISIBLE_ABONED_FLAG) > 0) ||
		((flags_ & ABONED_FLAG) > 0))
		return NO;
	else
		return YES;
}

CFPropertyListRef CreatePropertiesFromXMLFile(const CFURLRef pCFURLRef)
{
    CFDataRef xmlCFDataRef;
    CFPropertyListRef myCFPropertyListRef = NULL;
    Boolean status;

    // Read the XML file.
    status = CFURLCreateDataAndPropertiesFromResource( 
                        kCFAllocatorDefault, pCFURLRef, 
                        &xmlCFDataRef, NULL, NULL, NULL);
    if (status)
    {
        // Reconstitute the dictionary using the XML data.
        myCFPropertyListRef = CFPropertyListCreateFromXMLData(
                        kCFAllocatorDefault, xmlCFDataRef, 
                        kCFPropertyListImmutable, NULL);

		// Release the XML data
		CFRelease(xmlCFDataRef);
    }

    return myCFPropertyListRef;
}

Boolean GetMetadataForFile(void* thisInterface, 
			   CFMutableDictionaryRef attributes, 
			   CFStringRef contentTypeUTI,
			   CFStringRef pathToFile)
{
    Boolean success = NO;

	CFDictionaryRef	tempDictRef;
	CFStringRef		tempTitleRef;
	CFArrayRef		tempContentRef;
    NSAutoreleasePool *pool;

	// load the document at the specified location	
	CFURLRef		pathToFileURL;
	pathToFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, pathToFile, kCFURLPOSIXPathStyle, false);
	tempDictRef = (CFDictionaryRef)CreatePropertiesFromXMLFile(pathToFileURL);

    if (tempDictRef)
    {
		CFStringRef	tempBrdNameRef;
		CFStringRef	tempDatNumberRef;
		CFNumberRef	tempLengthRef;
		CFDateRef	tempCreatedDateRef;
		CFDateRef	tempModifiedDateRef;

		CFDictionarySetValue(attributes, kMDItemCreator, CFSTR("BathyScaphe"));

		// set the kMDItemTitle attribute to the Title
		tempTitleRef = CFDictionaryGetValue(tempDictRef, CFSTR("Title"));
		if (tempTitleRef != NULL) {
			CFDictionarySetValue(attributes, kMDItemTitle, tempTitleRef);
			CFDictionarySetValue(attributes, kMDItemDisplayName, tempTitleRef);
		}
		
		tempBrdNameRef = CFDictionaryGetValue(tempDictRef, CFSTR("BoardName"));
		if (tempBrdNameRef != NULL)
			CFDictionarySetValue(attributes, CFSTR("jp_tsawada2_bathyscaphe_thread_BoardName"), tempBrdNameRef);

		tempDatNumberRef = CFDictionaryGetValue(tempDictRef, CFSTR("dat"));
		if (tempDatNumberRef != NULL)
			CFDictionarySetValue(attributes, CFSTR("jp_tsawada2_bathyscaphe_thread_DatNumber"), tempDatNumberRef);

		tempLengthRef = CFDictionaryGetValue(tempDictRef, CFSTR("Length"));
		if (tempLengthRef != NULL)
			CFDictionarySetValue(attributes, CFSTR("jp_tsawada2_bathyscaphe_thread_DatSize"), tempLengthRef);

		tempCreatedDateRef = CFDictionaryGetValue(tempDictRef, CFSTR("CreatedDate"));
		if (tempBrdNameRef != NULL)
			CFDictionarySetValue(attributes, kMDItemContentCreationDate, tempBrdNameRef);

		tempModifiedDateRef = CFDictionaryGetValue(tempDictRef, CFSTR("ModifiedDate"));
		if (tempBrdNameRef != NULL)
			CFDictionarySetValue(attributes, kMDItemContentModificationDate, tempBrdNameRef);

		pool = [[NSAutoreleasePool alloc] init];

		tempContentRef = (CFArrayRef)[(NSDictionary *)tempDictRef objectForKey: @"Contents"];
		if (tempContentRef) {
			CFIndex	count_;
			CFNumberRef	countRef_;
			count_ = CFArrayGetCount(tempContentRef);
			countRef_ = CFNumberCreate(kCFAllocatorDefault, kCFNumberCFIndexType, &count_);
			CFDictionarySetValue(attributes, CFSTR("jp_tsawada2_bathyscaphe_thread_ResCount"), countRef_);

			CFRelease(countRef_);

			// Foundation Part
			CFMutableStringRef	cont_ = CFStringCreateMutable(kCFAllocatorDefault, 0);
			CFMutableArrayRef	nameArray_ = (CFMutableArrayRef)[NSMutableArray array];
			NSEnumerator	*e_;
			id				obj;

			e_ = [(NSArray *)tempContentRef objectEnumerator];

			while ((obj = [e_ nextObject]) != nil) {
				if (isNotAbonedRes([obj objectForKey: @"Status"])) {
					NSString	*msg_;
					NSString	*name_; 
					
					msg_ = [obj objectForKey: @"Message"];
					if (msg_) {
						CFStringAppend(cont_, msg_);
					}
					name_ = [obj objectForKey: @"Name"];
					if (name_ && ![(NSMutableArray *)nameArray_ containsObject: name_])
						CFArrayAppendValue(nameArray_, name_);
				}
			}

			CFRange cf_range = CFRangeMake(0, CFStringGetLength((CFStringRef)cont_));
			CFStringFindAndReplace(cont_, CFSTR(" <br> "), CFSTR(""), cf_range, 0);
			CFStringTrimWhitespace(cont_);
																	
			{
				unsigned int	len;
				NSRange			resultRange;
				NSRange			searchRange;

				len = [(NSMutableString *)cont_ length];
				searchRange = NSMakeRange(0, len);

				while (1) {
					NSRange		gtRange;
					
					resultRange = [(NSMutableString *)cont_ rangeOfString: @"<a "
											   options: (NSLiteralSearch|NSCaseInsensitiveSearch)
												 range: searchRange];
					if (resultRange.length == 0) {
						break;
					}
					// Start searching next to "<"
					searchRange.location = NSMaxRange(resultRange);
					searchRange.length = (len - searchRange.location);
					gtRange = [(NSMutableString *)cont_ rangeOfString: @"</a>"
										   options: (NSLiteralSearch|NSCaseInsensitiveSearch)
											 range: searchRange];
					if (gtRange.length == 0) {
						break;
					}
					resultRange.length = NSMaxRange(gtRange) - resultRange.location;
					CFStringDelete(cont_, *(CFRange *)&resultRange);

					searchRange.length -= resultRange.length;
					len -= resultRange.length;
					
					if (searchRange.location >= len) break;
				}
			}

			CFDictionarySetValue(attributes, kMDItemTextContent, cont_);
			CFDictionarySetValue(attributes, kMDItemContributors, nameArray_);
			
			CFRelease(cont_);
		}
		[pool release];

		// return YES so that the attributes are imported
		success = YES;
		CFRelease(pathToFileURL);
		// release the loaded document
		CFRelease(tempDictRef);
    }
    return success;
}
