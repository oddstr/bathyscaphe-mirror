#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>

#define MA_VERSION_MASK			(0x3800000)		// 24-26 (3bit)
#define MA_FL_NOT_TEMP_MASK		(0xfffff)		// 20bit
#define MA_VERSION_1_0_MAGIC	(0x28000)		// version 1.0 magic number
#define MA_VERSION_1_1_MAGIC	(0x800000U)		// version 1.1 magic number
#define ABONED_FLAG				(0x40)			// 7 (different from LOCAL ABONE)
#define INVISIBLE_ABONED_FLAG	(0x100)			// 9
#define SPAM_FLAG				(0x400)			// 11

static Boolean isNotAbonedRes(CFNumberRef rep)
{
	UInt32		flags_;
	Boolean		got_;
	
	if (rep == NULL) return true;	
	got_ = CFNumberGetValue(rep, kCFNumberIntType, &flags_);
	if (got_ == false) return true;
	
	flags_ &= MA_FL_NOT_TEMP_MASK;
	if (((flags_ & SPAM_FLAG) > 0) ||
		((flags_ & INVISIBLE_ABONED_FLAG) > 0) ||
		((flags_ & ABONED_FLAG) > 0))
		return false;
	else
		return true;
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
    Boolean success = false;

	CFDictionaryRef	tempDictRef;
	CFStringRef		tempTitleRef;
	CFArrayRef		tempContentRef;

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
		if (tempCreatedDateRef != NULL)
			CFDictionarySetValue(attributes, kMDItemContentCreationDate, tempCreatedDateRef);

		tempModifiedDateRef = CFDictionaryGetValue(tempDictRef, CFSTR("ModifiedDate"));
		if (tempModifiedDateRef != NULL)
			CFDictionarySetValue(attributes, kMDItemContentModificationDate, tempModifiedDateRef);

		tempContentRef = CFDictionaryGetValue(tempDictRef, CFSTR("Contents"));
		if (tempContentRef) {
			CFIndex	i, count_;
			CFNumberRef	countRef_;
			CFMutableStringRef	cont_ = CFStringCreateMutable(kCFAllocatorDefault, 0);
			CFMutableArrayRef	nameArray_ = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
			CFDictionaryRef	obj;
			CFNumberRef		statusStr;

			count_ = CFArrayGetCount(tempContentRef);

			countRef_ = CFNumberCreate(kCFAllocatorDefault, kCFNumberCFIndexType, &count_);
			CFDictionarySetValue(attributes, CFSTR("jp_tsawada2_bathyscaphe_thread_ResCount"), countRef_);
			CFRelease(countRef_);
			
			for (i=0; i<count_; i++) {
				obj = CFArrayGetValueAtIndex(tempContentRef, i);

				if (obj == NULL) continue;
				statusStr = CFDictionaryGetValue(obj, CFSTR("Status"));
				if (isNotAbonedRes(statusStr)) {
					CFStringRef	msg_;
					CFStringRef	name_;

					msg_ = CFDictionaryGetValue(obj, CFSTR("Message"));
					if (msg_) {
						CFStringAppend(cont_, msg_);
					}

					name_ = CFDictionaryGetValue(obj, CFSTR("Name"));
					if (name_) {
						Boolean already_ = CFArrayContainsValue(nameArray_, CFRangeMake(0, CFArrayGetCount(nameArray_)), name_);
						if (already_ == false) CFArrayAppendValue(nameArray_, name_);
					}
				}
			}

			CFStringFindAndReplace(cont_, CFSTR(" <br> "), CFSTR(""), CFRangeMake(0, CFStringGetLength(cont_)), 0);
			CFStringTrimWhitespace(cont_);
																	
			CFIndex	len;
			CFRange	searchRange;
			CFRange	resultRange;
			CFRange	gtRange;

			len = CFStringGetLength(cont_);
			searchRange = CFRangeMake(0, len);

			while (1) {
				Boolean	found_ = CFStringFindWithOptions(cont_, CFSTR("<a "), searchRange, kCFCompareCaseInsensitive, &resultRange);
				if (found_ == false) break;
				// Start searching next to "<"
				searchRange.location = resultRange.location + resultRange.length;
				searchRange.length = (len - searchRange.location);

				found_ = CFStringFindWithOptions(cont_, CFSTR("</a>"), searchRange, kCFCompareCaseInsensitive, &gtRange);
				if (found_ == false) break;
				resultRange.length = gtRange.location + gtRange.length - resultRange.location;
				CFStringDelete(cont_, resultRange);

				searchRange.length -= resultRange.length;
				len -= resultRange.length;
				
				if (searchRange.location >= len) break;
			}

			CFDictionarySetValue(attributes, kMDItemTextContent, cont_);
			CFDictionarySetValue(attributes, kMDItemContributors, nameArray_);
			
			CFRelease(cont_);
			CFRelease(nameArray_);
		}
		// release the loaded document
		CFRelease(pathToFileURL);
		CFRelease(tempDictRef);
		// return YES so that the attributes are imported
		success = true;
    }
    return success;
}
