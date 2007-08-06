//
//  BSLinkDownloadManager.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/08/07.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "BSLinkDownloadManager.h"
#import "CocoMonar_Prefix.h"

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

#pragma mark CMRPropertyListCoding
+ (id)objectWithPropertyListRepresentation:(id)rep
{
    if (!rep || ![rep isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

	id instance;
	instance = [[[self class] alloc] init];
	[instance setExtension:[rep stringForKey:@"Extension"]];
	[instance setAutoopen:[rep boolForKey:@"Autoopen"]];
	return [instance autorelease];
}

- (id)propertyListRepresentation
{
	return [NSDictionary dictionaryWithObjectsAndKeys:[self extension], @"Extension",
													  [NSNumber numberWithBool:[self autoopen]], @"Autoopen", NULL];
}
@end

@implementation BSLinkDownloadManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager)

+ (NSString *)defaultFilepath
{
    return [[CMRFileManager defaultManager] supportFilepathWithName:@"DownloadableLinkTypes.plist" resolvingFileRef:NULL];
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
        NSString        *filepath_;
        
        filepath_ = [[self class] defaultFilepath];
        UTILAssertNotNil(filepath_);

		NSData		*data;
		NSArray		*rep;
		NSString	*errorStr = [NSString string];

		data = [NSData dataWithContentsOfFile:filepath_];
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
	while (ticket = [iter nextObject]) {
		[theArray addObject:[ticket propertyListRepresentation]];
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
