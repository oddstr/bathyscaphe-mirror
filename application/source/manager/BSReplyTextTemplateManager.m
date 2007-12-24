//
//  BSReplyTextTemplateManager.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/12/20.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSReplyTextTemplateManager.h"
#import "CocoMonar_Prefix.h"
#import <AppKit/NSMenu.h>
#import "AppDefaults.h"

@implementation BSReplyTextTemplateManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager)

+ (NSString *)defaultFilepath
{
    return [[CMRFileManager defaultManager] supportFilepathWithName:BSReplyTextTemplatesFile resolvingFileRef:NULL];
}

- (void)fillArray:(NSMutableArray *)mutableArray fromPlistRep:(id)rep
{
	UTILAssertKindOfClass(rep, NSArray);
	NSEnumerator	*iter = [rep objectEnumerator];
	NSDictionary	*item;

	while (item = [iter nextObject]) {
		[mutableArray addObject:[BSReplyTextTemplate objectWithPropertyListRepresentation:item]];
	}
}

- (id)init
{
    if (self = [super init]) {
        NSString        *filepath;
		NSFileManager	*fileManager = [NSFileManager defaultManager];
		NSMutableArray	*tmp;
		BSBugReportingTemplate	*bugReporter;
        
        filepath = [[self class] defaultFilepath];
        UTILAssertNotNil(filepath);

		bugReporter = [[BSBugReportingTemplate alloc] init];
		tmp = [[NSMutableArray alloc] initWithObjects:bugReporter, nil];
		[bugReporter release];

		if ([fileManager fileExistsAtPath:filepath]) {
			NSData		*data;
			NSArray		*rep;
			NSString	*errorStr = [NSString string];

			data = [NSData dataWithContentsOfFile:filepath];
			if (data) {
				rep = [NSPropertyListSerialization propertyListFromData:data
													   mutabilityOption:NSPropertyListImmutable
																 format:NULL
													   errorDescription:&errorStr];
				if (rep) {
					[self fillArray:tmp fromPlistRep:rep];
				}
			}
		}
		[self setTemplates:tmp];
		[tmp release];
    }
    return self;
}

- (void)dealloc
{
	[m_templates release];
	[super dealloc];
}

- (NSArray *)arrayRepresentation
{
	NSMutableArray *theArray = [NSMutableArray array];
	NSEnumerator *iter = [[self templates] objectEnumerator];
	BSReplyTextTemplate *template;
	id rep;
	while (template = [iter nextObject]) {
		rep = [template propertyListRepresentation];
		if (rep) [theArray addObject:rep];
	}
    return theArray;
}

- (void)removeFileIfNeeded
{
	BOOL	isDir;
	if ([[NSFileManager defaultManager] fileExistsAtPath:[[self class] defaultFilepath] isDirectory:&isDir] && !isDir) {
		[[NSFileManager defaultManager] removeFileAtPath:[[self class] defaultFilepath] handler:nil];
	}
}

- (void)writeToFileNow
{
	NSString	*errorStr = [NSString string];
	NSArray		*array = [self arrayRepresentation];

	if (!array || [array count] == 0) {
//		NSLog(@"No need to write file.");
		[self removeFileIfNeeded];
		return;
	}

	NSData		*rep;
	rep = [NSPropertyListSerialization dataFromPropertyList:array
													 format:NSPropertyListBinaryFormat_v1_0
										   errorDescription:&errorStr];
	[rep writeToFile:[[self class] defaultFilepath] atomically:YES];
}

- (NSString *)templateForDisplayName:(NSString *)aString
{
	unsigned int index = [[[self templates] valueForKey:@"displayName"] indexOfObject:aString];
	if (index == NSNotFound) return nil;

	return [[self objectInTemplatesAtIndex:index] template];
}

- (NSString *)templateForShortcutKeyword:(NSString *)aString
{
	unsigned int index = [[[self templates] valueForKey:@"shortcutKeyword"] indexOfObject:aString];
	if (index == NSNotFound) return nil;

	return [[self objectInTemplatesAtIndex:index] template];
}

#pragma mark NSCoding Protocol
- (id)initWithCoder:(NSCoder *)decoder
{
	if (self = [super init]) {
		[self setTemplates:[decoder decodeObjectForKey:@"templates"]];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:[self templates] forKey:@"templates"];
}

#pragma mark KVO Accessors
- (NSMutableArray *)templates
{
	return m_templates;
}

- (void)setTemplates:(NSMutableArray *)anArray
{
	[anArray retain];
	[m_templates release];
	m_templates = anArray;
}

- (unsigned int)countOfTemplates
{
	return [[self templates] count];
}

- (id)objectInTemplatesAtIndex:(unsigned int)index
{
	return [[self templates] objectAtIndex:index];
}

- (void)insertObject:(id)anObject inTemplatesAtIndex:(unsigned int)index
{
	[[self templates] insertObject:anObject atIndex:index];
}

- (void)removeObjectFromTemplatesAtIndex:(unsigned int)index
{
	[[self templates] removeObjectAtIndex:index];
}

- (void)replaceObjectInTemplatesAtIndex:(unsigned int)index withObject:(id)anObject
{
	[[self templates] replaceObjectAtIndex:index withObject:anObject];
}

#pragma mark NSMenu Delegate
- (void)menuNeedsUpdate:(NSMenu *)menu
{
	if ([menu delegate] != self) return;
	BOOL	isPopupButtonMenu = ([menu supermenu] == nil);

	// Clear Menu
	unsigned int count = [menu numberOfItems];
	unsigned int i;
	unsigned int min = isPopupButtonMenu ? 1 : 0;
	for (i = count; i > min; i--) {
		[menu removeItemAtIndex:i-1];
	}

	// Build Menu
	NSEnumerator *iter = [[self templates] objectEnumerator];
	BSReplyTextTemplate *eachItem;
	NSMenuItem	*item;
	NSString	*displayName;

	while (eachItem = [iter nextObject]) {
		displayName = [eachItem displayName];
		if (!displayName) continue;
		item = [[NSMenuItem alloc] initWithTitle:displayName action:@selector(insertTextTemplate:) keyEquivalent:@""];
		[item setRepresentedObject:displayName];
		[menu addItem:item];
		[item release];
	}

	// Insert Separator
	if ([menu numberOfItems] > min+1) {
		item = [NSMenuItem separatorItem];
		[menu insertItem:item atIndex:min+1];
	}

	// Insert Customizer
	[menu addItem:[NSMenuItem separatorItem]];
	item = [[NSMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Customize Templates", @"Messenger", @"")
									  action:@selector(customizeTextTemplates:) keyEquivalent:@""];
	[menu addItem:item];
	[item release];
}
@end


@implementation BSBugReportingTemplate
- (NSString *)displayName
{
	return NSLocalizedStringFromTable(@"Bug Report", @"Messenger", @"");
}

- (void)setDisplayName:(NSString *)aString{;}

- (NSString *)shortcutKeyword
{
	return @"bugreport";
}

- (void)setShortcutKeyword:(NSString *)aString{;}

- (NSString *)template
{
	NSString *base = NSLocalizedStringFromTable(@"BugReportTemplate", @"Messenger", @"");
	NSString *replacedString;
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *marker = NSLocalizedStringFromTable(@"BugReportMarker", @"Messenger", @"");
	NSDictionary *dict = [[CMRPref installedPreviewerBundle] infoDictionary];

	replacedString = [NSString stringWithFormat:base, 
						[[NSProcessInfo processInfo] operatingSystemVersionString],
						[bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
						[bundle objectForInfoDictionaryKey:@"CFBundleVersion"],
						[dict objectForKey:@"CFBundleIdentifier"],
						[dict objectForKey:@"CFBundleShortVersionString"],
						[dict objectForKey:@"CFBundleVersion"],
						marker];

	return replacedString;
}

- (void)setTemplate:(NSString *)aString{;}

- (NSString *)templateDescription
{
	return NSLocalizedStringFromTable(@"BugReporterDescription", @"Messenger", @"");
}

+ (id)objectWithPropertyListRepresentation:(id)rep
{
	id instance;
	instance = [[[self class] alloc] init];

	return [instance autorelease];
}

- (id)propertyListRepresentation
{
	return nil;
}
@end
