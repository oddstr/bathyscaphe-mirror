/**
  * $Id: SGFileLocation.m,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * SGFileLocation.m
  *
  * Copyright (c) 2004, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "SGFileLocation.h"
#import <SGFoundation/SGFileRef.h>



@implementation SGFileLocation
//
// P R I V A T E
//
- (void) setDirectory : (SGFileRef *) aDirectory
{
    id tmp;
    
    tmp = m_directory;
    m_directory = [aDirectory retain];
    [tmp release];
}
- (void) setName : (NSString *) aName
{
    id tmp;
    
    tmp = m_name;
    m_name = [aName retain];
    [tmp release];
}

//
// P U B L I C
//
+ (id) fileLocationWithName : (NSString  *) aFileName
                  directory : (SGFileRef *) aDirectory
{
    return [[[self alloc] initWithName:aFileName directory:aDirectory] autorelease];
}
- (id) initWithName : (NSString  *) aFileName
          directory : (SGFileRef *) aDirectory;
{
    if (nil == aDirectory) {
        [self release];
        return nil;
    }
    if (self = [self init]) {
        [self setName : aFileName];
        [self setDirectory : aDirectory];
    }
    return self;
}
+ (id) fileLocationAtPath : (NSString  *) aFilePath
{
    return [[[self alloc] initLocationAtPath : aFilePath] autorelease];
}
- (id) initLocationAtPath : (NSString  *) aFilePath
{
    SGFileRef *directory;
    NSString  *name;
    
    name = [aFilePath lastPathComponent];
    directory = [SGFileRef fileRefWithPath : [aFilePath stringByDeletingLastPathComponent]];
    
    return [self initWithName:name directory:directory];
}
- (id) init
{
    if (self = [super init]) {
        ;
    }
    return self;
}
- (void) dealloc
{
    [m_directory release];
    [m_name release];
    [super dealloc];
}

- (SGFileRef *) actualDirectory
{ return [[self directory] fileRefResolvingLinkIfNeeded]; }
- (SGFileRef *) directory
{
    return m_directory;
}
- (NSString *) name
{
    return m_name;
}

- (BOOL) exists
{
    return ([self fileRef] != nil);
}
- (SGFileRef *) fileRef
{
    return [[self actualDirectory] fileRefWithChildName : [self name]];
}
- (NSString *) filepath
{
    return [[[self actualDirectory] filepath] stringByAppendingPathComponent : [self name]];
}

//
// NSObject
//
- (BOOL) isEqual : (id) other
{
    if(self == other) return YES;
    if(nil == other) return NO;
    
    if([other isKindOfClass : [self class]]){
        BOOL ret;
        
        ret = [[self name] isEqual : [other name]];
        if (NO == ret) return NO;
        ret = [[self directory] isEqual : [other directory]];
        if (NO == ret) return NO;
        
        return YES;
    }
    
    return NO;
}
- (NSString *) description
{
    return [NSString stringWithFormat :
            @"<%@:%p> directory:%@ name:%@",
            [self className], self,
            [[self directory] filepath],
            [self name]];
}
- (unsigned) hash
{
    return ([[self name] hash] ^ [[self directory] hash]);
}
//
// NSCopying
//
- (id) copyWithZone : (NSZone *) aZone
{
    return [self retain];
}
@end
