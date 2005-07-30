#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <Foundation/Foundation.h>


/* -----------------------------------------------------------------------------
   Step 1
   Set the UTI types the importer supports
  
   Modify the CFBundleDocumentTypes entry in Info.plist to contain
   an array of Uniform Type Identifiers (UTI) for the LSItemContentTypes 
   that your importer can handle
  
   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 2 
   Implement the GetMetadataForFile function
  
   Implement the GetMetadataForFile function below to scrape the relevant
   metadata from your document and return it as a CFDictionary using standard keys
   (defined in MDItem.h) whenever possible.
   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 3 (optional) 
   If you have defined new attributes, update the schema.xml file
  
   Edit the schema.xml file to include the metadata keys that your importer returns.
   Add them to the <allattrs> and <displayattrs> elements.
  
   Add any custom types that your importer requires to the <attributes> element
  
   <attribute name="com_mycompany_metadatakey" type="CFString" multivalued="true"/>
  
   ----------------------------------------------------------------------------- */



/* -----------------------------------------------------------------------------
    Get metadata attributes from file
   
   This function's job is to extract useful information your file format supports
   and return it as a dictionary
   ----------------------------------------------------------------------------- */
static BOOL isBookmarkedRes(id rep);

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
			NSDictionary	*first_;
			NSMutableString	*cont_;

			[(NSMutableDictionary *)attributes setObject:[NSNumber numberWithUnsignedInt : [tempContent count]]
										forKey:@"jp_tsawada2_bathyscaphe_thread_ResCount"];

			first_ = [tempContent objectAtIndex : 0];
			cont_ = [NSMutableString stringWithString : [first_ objectForKey:@"Message"]];

			if (cont_) {
				NSEnumerator	*e_;
				id				obj;

				e_ = [tempContent objectEnumerator];

				while ((obj = [e_ nextObject]) != nil) {
					if (isBookmarkedRes([obj objectForKey:@"Status"])) {
						NSString *msg_ = [obj objectForKey : @"Message"];
						if (msg_) [cont_ appendString : msg_];
					}
				}
				
				[cont_ replaceOccurrencesOfString : @"<br>"
									   withString : @""
										  options : NSLiteralSearch
											range : NSMakeRange(0, [cont_ length])];

				[(NSMutableDictionary *)attributes setObject : cont_
													  forKey : (NSString *)kMDItemTextContent];
			}
		}
            // return YES so that the attributes are imported
		success=YES;

            // release the loaded document
		[tempDict release];
    }
    [pool release];
    return success;
}

#define MA_VERSION_MASK			(0x3800000)		// 24-26 (3bit)
#define MA_FL_NOT_TEMP_MASK		(0xfffff)		// 20bit
#define MA_VERSION_1_0_MAGIC	(0x28000)		// version 1.0 magic number
#define MA_VERSION_1_1_MAGIC	(0x800000U)		// version 1.1 magic number
#define BOOKMARK_FLAG			(0x7000)		// 13 - 15 (3bit)

static BOOL isBookmarkedRes(id rep)
{
	UInt32		version_;
	UInt32		flags_;
	
	if (rep == nil) return NO;
		
	flags_ = [rep unsignedIntValue];
	
	version_ = (flags_ & MA_VERSION_MASK);
	if (0 == version_) {
		if (flags_ & MA_VERSION_1_0_MAGIC) {
			flags_ &= (~MA_VERSION_1_0_MAGIC);
			flags_ &= MA_VERSION_1_1_MAGIC;
		}
	}
	
	if((flags_ & MA_VERSION_1_1_MAGIC) <= 0) return NO; 
	
	flags_ &= MA_FL_NOT_TEMP_MASK;
	return ((flags_ & BOOKMARK_FLAG) > 0);
}
