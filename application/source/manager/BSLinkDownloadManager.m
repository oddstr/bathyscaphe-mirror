//
//  BSLinkDownloadManager.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/08/07.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSLinkDownloadManager.h"
#import "CocoMonar_Prefix.h"

static NSString *const kTicketPlistRepExtensionKey = @"Extension";
static NSString *const kTicketPlistRepAutoopenKey = @"Autoopen";

@implementation BSLinkDownloadTicket
- (id)init
{
	if (self = [super init]) {
		[self setAutoopen:YES];
	}
	return self;
}

- (void)dealloc
{
	[self setExtension:nil];
	[super dealloc];
}

#pragma mark Accessors
- (NSString *)extension
{
	return m_extension;
}

- (void)setExtension:(NSString *)extensionString
{
	[extensionString retain];
	[m_extension release];
	m_extension = extensionString;
}

- (BOOL)autoopen
{
	return m_autoopen;
}

- (void)setAutoopen:(BOOL)isAutoopen
{
	m_autoopen = isAutoopen;
}

#pragma mark CMRPropertyListCoding Protocol
+ (id)objectWithPropertyListRepresentation:(id)rep
{
    if (!rep || ![rep isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

	id instance;
	instance = [[[self class] alloc] init];
	[instance setExtension:[rep stringForKey:kTicketPlistRepExtensionKey]];
	[instance setAutoopen:[rep boolForKey:kTicketPlistRepAutoopenKey]];
	return [instance autorelease];
}

- (id)propertyListRepresentation
{
	if (![self extension] || [[self extension] length] == 0) return nil;
	return [NSDictionary dictionaryWithObjectsAndKeys:[self extension], kTicketPlistRepExtensionKey,
													  [NSNumber numberWithBool:[self autoopen]], kTicketPlistRepAutoopenKey, NULL];
}
@end

@implementation BSLinkDownloadManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager)

+ (NSString *)defaultFilepath
{
    return [[CMRFileManager defaultManager] supportFilepathWithName:BSDownloadableTypesFile resolvingFileRef:NULL];
}

+ (NSString *)spareFilepath
{
	NSString *resourceType = [BSDownloadableTypesFile pathExtension];
	NSString *resourceName = [BSDownloadableTypesFile stringByDeletingPathExtension];
	return [[NSBundle mainBundle] pathForResource:resourceName ofType:resourceType];
}

- (NSMutableArray *)restoreFromPlistRep:(id)rep
{
	UTILAssertKindOfClass(rep, NSArray);
	NSMutableArray	*theArray = [NSMutableArray array];
	NSEnumerator	*iter = [rep objectEnumerator];
	NSDictionary	*item;

	while (item = [iter nextObject]) {
		[theArray addObject:[BSLinkDownloadTicket objectWithPropertyListRepresentation:item]];
	}
	return theArray;
}

- (id)init
{
    if (self = [super init]) {
        NSString        *filepath;
		NSFileManager	*fileManager = [NSFileManager defaultManager];
        
        filepath = [[self class] defaultFilepath];
        UTILAssertNotNil(filepath);

		if (![fileManager fileExistsAtPath:filepath]) {
			// Copy from application package to support directory.
			[fileManager copyPath:[[self class] spareFilepath] toPath:filepath handler:nil];
		}

		NSData		*data;
		NSArray		*rep;
		NSString	*errorStr = [NSString string];

		data = [NSData dataWithContentsOfFile:filepath];
		if (data) {
			rep = [NSPropertyListSerialization propertyListFromData:data
												   mutabilityOption:NSPropertyListImmutable
															 format:NULL
												   errorDescription:&errorStr];
			m_downloadableTypes = [[self restoreFromPlistRep:rep] retain];
		} else {
			m_downloadableTypes = [[NSMutableArray alloc] init];
		}
    }
    return self;
}

- (void)dealloc
{
	[m_downloadableTypes release];
	[super dealloc];
}

- (NSMutableArray *)downloadableTypes
{
	return m_downloadableTypes;
}

- (void)setDownloadableTypes:(NSMutableArray *)array
{
	[array retain];
	[m_downloadableTypes release];
	m_downloadableTypes = array;
}

- (NSArray *)arrayRepresentation
{
	NSMutableArray *theArray = [NSMutableArray array];
	NSEnumerator *iter = [[self downloadableTypes] objectEnumerator];
	BSLinkDownloadTicket *ticket;
	id rep;
	while (ticket = [iter nextObject]) {
		rep = [ticket propertyListRepresentation];
		if (rep) [theArray addObject:rep];
	}
    return theArray;
}

- (void)writeToFileNow
{
	NSString	*errorStr = [NSString string];
	NSData		*rep;
	rep = [NSPropertyListSerialization dataFromPropertyList:[self arrayRepresentation]
													 format:NSPropertyListBinaryFormat_v1_0
										   errorDescription:&errorStr];
	[rep writeToFile:[[self class] defaultFilepath] atomically:YES];
}
@end
