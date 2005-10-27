#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <Foundation/Foundation.h>

static BOOL isNotAbonedRes(id rep);
static void deleteAnchorTags (NSMutableString *htmlString);

#pragma mark -

Boolean GetMetadataForFile(void* thisInterface, 
			   CFMutableDictionaryRef attributes, 
			   CFStringRef contentTypeUTI,
			   CFStringRef pathToFile)
{
    Boolean success=NO;
    NSDictionary *tempDict;
	NSString *tempTitle;
	NSArray	*tempContent;
    NSAutoreleasePool *pool;

    pool = [[NSAutoreleasePool alloc] init];

	// load the document at the specified location
    tempDict=[[NSDictionary alloc] initWithContentsOfFile:(NSString *)pathToFile];
    if (tempDict)
    {
		[(NSMutableDictionary *)attributes setObject:@"BathyScaphe"
											  forKey:(NSString *)kMDItemCreator];
		// set the kMDItemTitle attribute to the Title
		tempTitle = [tempDict objectForKey:@"Title"];
		if (tempTitle) {
			[(NSMutableDictionary *)attributes setObject:tempTitle
												  forKey:(NSString *)kMDItemTitle];
			[(NSMutableDictionary *)attributes setObject:tempTitle
												  forKey:(NSString *)kMDItemDisplayName];
		}
		
		[(NSMutableDictionary *)attributes setObject:[tempDict objectForKey:@"BoardName"]
											  forKey:@"jp_tsawada2_bathyscaphe_thread_BoardName"];
		[(NSMutableDictionary *)attributes setObject:[tempDict objectForKey:@"dat"]
											  forKey:@"jp_tsawada2_bathyscaphe_thread_DatNumber"];

		[(NSMutableDictionary *)attributes setObject:[tempDict objectForKey:@"Length"]
											  forKey:@"jp_tsawada2_bathyscaphe_thread_DatSize"];

		[(NSMutableDictionary *)attributes setObject:[tempDict objectForKey:@"CreatedDate"]
											  forKey:(NSString *)kMDItemContentCreationDate];
		[(NSMutableDictionary *)attributes setObject:[tempDict objectForKey:@"ModifiedDate"]
											  forKey:(NSString *)kMDItemContentModificationDate];

		tempContent = [tempDict objectForKey:@"Contents"];
		if (tempContent) {
			NSMutableString	*cont_ = [NSMutableString string];
			NSMutableArray	*nameArray_ = [NSMutableArray array];

			NSEnumerator	*e_;
			//unsigned		cLength = 0;
			id				obj;

			[(NSMutableDictionary *)attributes setObject:[NSNumber numberWithUnsignedInt : [tempContent count]]
												  forKey:@"jp_tsawada2_bathyscaphe_thread_ResCount"];

			e_ = [tempContent objectEnumerator];

			//while (((obj = [e_ nextObject]) != nil) && (cLength < 359424)) {
			while ((obj = [e_ nextObject]) != nil) {
				if (isNotAbonedRes([obj objectForKey:@"Status"])) {
					NSString *msg_;
					NSString *name_; 
					
					msg_ = [obj objectForKey : @"Message"];
					if (msg_ && ([msg_ length] > 3)) {
						[cont_ appendString : msg_];
						//cLength += [msg_ maximumLengthOfBytesUsingEncoding : NSUTF8StringEncoding];
					}
					name_ = [obj objectForKey : @"Name"];
					if (name_ && ![nameArray_ containsObject : name_])
						[nameArray_ addObject : name_];
				}
			}

			[cont_ replaceOccurrencesOfString : @" <br> "
								   withString : @" "
									  options : NSLiteralSearch
										range : NSMakeRange(0, [cont_ length])];
			[cont_ replaceOccurrencesOfString : @"</a>"
								   withString : @""
									  options : (NSCaseInsensitiveSearch | NSLiteralSearch)
										range : NSMakeRange(0, [cont_ length])];
										
			deleteAnchorTags(cont_);

			[(NSMutableDictionary *)attributes setObject : cont_
												  forKey : (NSString *)kMDItemTextContent];
			[(NSMutableDictionary *)attributes setObject : nameArray_
												  forKey : (NSArray *)kMDItemContributors];
		}
		// return YES so that the attributes are imported
		success=YES;

		// release the loaded document
		[tempDict release];
    }
    [pool release];
    return success;
}

#pragma mark -

#define MA_VERSION_MASK			(0x3800000)		// 24-26 (3bit)
#define MA_FL_NOT_TEMP_MASK		(0xfffff)		// 20bit
#define MA_VERSION_1_0_MAGIC	(0x28000)		// version 1.0 magic number
#define MA_VERSION_1_1_MAGIC	(0x800000U)		// version 1.1 magic number
#define ABONED_FLAG				(0x40)			// 7
#define INVISIBLE_ABONED_FLAG	(0x100)			// 9
#define SPAM_FLAG				(0x400)			// 11
//#define INVALID_FLAG			(0x800)			// 12
//#define BOOKMARK_FLAG			(0x7000)		// 13 - 15 (3bit)

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

//From CocoMonar
static void deleteAnchorTags (NSMutableString *htmlString)
{
	unsigned int	len;
	NSRange			resultRange;
	NSRange			searchRange;

	while (1) {
		NSRange		gtRange;		// ">"
		
		len = [htmlString length];
		searchRange = NSMakeRange(0, len);
		resultRange = [htmlString rangeOfString:@"<a "
										options:(NSLiteralSearch | NSCaseInsensitiveSearch)
										  range:searchRange];
		if (resultRange.length == 0) {
			break;
		}
		// Start searching next to "<"
		searchRange.location = NSMaxRange(resultRange);
		searchRange.length = (len - searchRange.location);
		gtRange = [htmlString rangeOfString:@">"
									options:NSLiteralSearch
									  range:searchRange];
		if (gtRange.length == 0) {
			break;
		}
		resultRange.length = NSMaxRange(gtRange) - resultRange.location;
		[htmlString deleteCharactersInRange:resultRange];
	}
}
