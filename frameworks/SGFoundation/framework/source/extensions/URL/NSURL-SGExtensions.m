//: NSURL-SGExtensions.m
/**
  * $Id: NSURL-SGExtensions.m,v 1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <SGFoundation/NSURL-SGExtensions_p.h>
#import <SGFoundation/SGFileRef.h>
#import <SGFoundation/String+Utils.h>


@implementation NSURL(SGExtensions)
+ (id) URLWithLink : (id) aLink
{
	return [self URLWithLink:aLink baseURL:nil];
}
+ (id) URLWithLink : (id     ) anLink
		   baseURL : (NSURL *) baseURL
{
	NSString		*path_ = nil;
	
	if(nil == anLink) 
		return nil;
	
	if([anLink isKindOfClass : [NSURL class]]){
		if(nil == baseURL)
			return anLink;
		
		path_ = [anLink absoluteString];
	}
	
	if([anLink isKindOfClass : [NSString class]])
		path_ = anLink;
	
	return [self URLWithString : path_ 
				 relativeToURL : baseURL];
}

+ (id) URLWithScheme : (NSString *) scheme
                host : (NSString *) host
                path : (NSString *) path
{
	return [[[self alloc] initWithScheme : scheme
									host : host
									path : path] autorelease];
}



- (NSString *) stringValue
{
	return [self absoluteString];
}
- (NSDictionary *) queryDictionary
{
	NSMutableDictionary	*params_;
	NSString			*query_;
	
	if(nil == (query_ = [self query]))
		return nil;
	
	params_ = [NSMutableDictionary dictionary];
	
	if([query_ length] > 1){
		NSArray      *parray_;
		NSEnumerator *iter_;
		NSString     *pstr_;
		
		//各パラメータを切り出す
		parray_ = [query_ componentsSeparatedByString : @"&"];
		iter_ = [parray_ objectEnumerator];
		while(pstr_ = [iter_ nextObject]){
			NSArray *pair_;
			if([pstr_ length] < 2){
				continue;
			}
			pair_ = [pstr_ componentsSeparatedByString : @"="];
			if([pair_ count] != 2){
				continue;
			}
			//辞書に登録
			[params_ setObject : [pair_ objectAtIndex : 1]
						forKey : [pair_ objectAtIndex : 0]];
		}
	}
	
	return params_;
}



- (NSURL *) URLByAppendingPathComponent : (NSString *) pathComponent;
{
	NSURL	*appended_;
	
	if(nil == pathComponent || 0 == [pathComponent length]) return self;
	
	appended_ = (NSURL *)CFURLCreateCopyAppendingPathComponent(
							CFAllocatorGetDefault(),
							(CFURLRef)self,
							(CFStringRef)pathComponent,
							([[pathComponent pathExtension] isEmpty]));
	return [appended_ autorelease];
}

- (NSURL *) URLByDeletingLastPathComponent
{
	NSURL	*deleted_;
	
	deleted_ = (NSURL *)CFURLCreateCopyDeletingLastPathComponent(
							CFAllocatorGetDefault(),
							(CFURLRef)self);
	return [deleted_ autorelease];
}


// Carbon FSRef/Alias
+ (id) fileURLWithFileSystemReference : (const FSRef *) fileSystemRef
{
	CFURLRef		URLRef_;
	
	URLRef_ = CFURLCreateFromFSRef(
						kCFAllocatorDefault,
						fileSystemRef);
	return [(NSURL*)URLRef_ autorelease];
}

- (BOOL) getFileSystemReference : (FSRef *) fileSystemRef
{
	NSString	*path_;
	
	path_ = [self path];
	return [self getFileSystemReference : fileSystemRef
				 UTF8PathString : [path_ UTF8String]];
}

- (NSString *) fileSystemPathHFSStyle
{
	CFStringRef		fileSystemPath_;
	
	fileSystemPath_ = CFURLCopyFileSystemPath(
						(CFURLRef)self,
						kCFURLHFSPathStyle);
	return [(NSString*)fileSystemPath_ autorelease];
}
- (NSURL *) resolveAliasFile
{
	FSRef			fileSystemRef_;
	Boolean			isTargetFolder_;
	Boolean			wasAliased_;
	OSErr			error_;
	
	[self getFileSystemReference : &fileSystemRef_];
	error_ = FSResolveAliasFile(
				&fileSystemRef_,
				YES,
				&isTargetFolder_,
				&wasAliased_);
	if(noErr == error_) 
		return [NSURL fileURLWithFileSystemReference:&fileSystemRef_];
	return nil;
}
@end



@implementation NSURL(SGExtensionsPrivate)
- (BOOL) getFileSystemReference : (FSRef      *) fileSystemRef
				 UTF8PathString : (const char *) pathString
{
	NSString		*path_;
	const char		*UTF8String_;
	ByteCount		byteCount_;
	
	path_ = [self path];
	UTF8String_ = [path_ UTF8String];
	byteCount_ = strlen(UTF8String_);
	
	if(PATH_MAX < byteCount_){
		NSString	*prefix_;
		NSString	*suffix_;
		
		[self getDividedPathWithUTF8PathString : UTF8String_
								  stringLength : byteCount_
										prefix : &prefix_
										suffix : &suffix_];
		return [self getFileSystemReference : fileSystemRef
						prefixPath : prefix_
						suffixPath : suffix_];
	}
	
	return CFURLGetFSRef((CFURLRef)self,
						 fileSystemRef);

}

- (BOOL) getDividedPathWithUTF8PathString : (const char *) pathString
							 stringLength : (ByteCount   ) byteLength
								   prefix : (NSString  **) prefixPtr
			                       suffix : (NSString  **) suffixPtr
{
	int			index_;
	CFStringRef	prefix_;
	CFStringRef	suffix_;
	
	if(byteLength <= PATH_MAX) return NO;
	index_ = byteLength;
	for(index_ = PATH_MAX; index_ >= 0; index_--){
		if('/' == pathString[index_] && index_ < PATH_MAX)
			break;
	}
	prefix_ = CFStringCreateWithBytes(
					CFAllocatorGetDefault(),
					pathString,
					index_+1, 
					kCFStringEncodingUTF8, 
					false);
	if(NULL == prefix_) return NO;
	if(prefixPtr != NULL) *prefixPtr = [(NSString*)prefix_ autorelease];
	
	suffix_ = CFStringCreateWithBytes(
					CFAllocatorGetDefault(),
					&pathString[index_+1],
					byteLength - index_ -1, 
					kCFStringEncodingUTF8, 
					false);
	if(NULL == suffix_) return NO;
	if(suffixPtr != NULL) *suffixPtr = [(NSString*)suffix_ autorelease];
	return YES;
}
- (BOOL) getFileSystemReference : (FSRef    *) fileSystemRef
					 prefixPath : (NSString *) prefix
					 suffixPath : (NSString *) suffix
{
	NSURL		*prefixURL_;
	
	if(NULL == fileSystemRef || nil == prefix || nil == suffix) return NO;
	prefixURL_ = [NSURL fileURLWithPath : prefix];
	
/*	NSLog(@"prefix = %@", prefix);
	NSLog(@"suffix = %@", [suffix pathComponents]);
*/	
	if(CFURLGetFSRef((CFURLRef)prefixURL_, fileSystemRef)){
		NSEnumerator	*pathIter_;
		NSString		*component_;
		SGFileRef		*fileRef_;
		
		fileRef_ = 
			[SGFileRef fileRefWithFSRef : fileSystemRef];
		if(nil == fileRef_) return NO;
		pathIter_ = [[suffix pathComponents] objectEnumerator];
		while(component_ = [pathIter_ nextObject]){
			fileRef_ = [fileRef_ fileRefWithChildName : component_];
			if(nil == fileRef_) return NO;
			
		}
		*fileSystemRef = *[fileRef_ getFSRef];
		return YES;
	}
	return NO;
}
@end
