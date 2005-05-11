//: CMRBBSAttributes.m
/**
  * $Id: CMRBBSAttributes.m,v 1.1.1.1 2005/05/11 17:51:03 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRBBSAttributes.h"
#import "UTILKit.h"



#define kBoardURLFormat	@"http://%@/%@/"

@implementation CMRBBSAttributes
- (id) initWithURL : (NSURL    *) anURL
			  name : (NSString *) aName
{
	UTILAssertNotNilArgument(anURL, @"URL");
	UTILAssertNotNilArgument(aName, @"Name");
	
	if(self = [super init]){
		_location = [anURL retain];
		_name = [aName retain];
	}
	return self;
}
- (id) initWithPath : (NSString *) aPath
		  directory : (NSString *) aDirectory
			   name : (NSString *) aName
{
	NSURL		*location_;
	
	UTILAssertNotNilArgument(aPath, @"path");
	UTILAssertNotNilArgument(aDirectory, @"directory");
	location_ = [NSURL URLWithString : 
					[NSString stringWithFormat : kBoardURLFormat,
						aPath, aDirectory]];
	
	return [self initWithURL:location_ name:aName];
}

- (NSURL *) URL
{
	return _location;
}
- (NSString *) name
{
	return _name;
}
- (id) identifier
{
	return [self name];
}
- (NSString *) host
{
	return [[self URL] host];
}
- (NSString *) path
{
	return CMRGetHostStringFromBoardURL([self URL], NULL);
}
- (NSString *) directory
{
	return [[[self URL] path] lastPathComponent];
}
@end
