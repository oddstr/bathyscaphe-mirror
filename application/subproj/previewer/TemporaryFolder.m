//
//  TemporaryFolder.m
//  IconSetComposer
//
//  Created by Hori,Masaki on 05/08/15.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "TemporaryFolder.h"


@implementation TemporaryFolder

-(NSString *)appName
{
	NSBundle *bundle_ = [NSBundle mainBundle];
	
	return [bundle_ bundleIdentifier];
}

+(id)temporaryFolder
{
	return [[[[self class] alloc] init] autorelease];
}
-(id)init
{
	if( self = [super init] ) {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *tmpDir = NSTemporaryDirectory();
		NSString *appName = [self appName];
		BOOL created = NO;
		
		do {
			NSString *folderName;
			folderName = [NSString stringWithFormat:@"%@_%@",
				appName, 
				[[NSCalendarDate dateWithTimeIntervalSinceNow:0.0]
							descriptionWithCalendarFormat:@"%Y%m%d%H%M%S%F"] ];
			_path = [tmpDir stringByAppendingPathComponent:folderName];
			
			if( ![fm fileExistsAtPath:_path] &&
				[fm createDirectoryAtPath:_path attributes:nil] ) {
				created = YES;
			}
		} while( !created );
		
		[_path retain];
	}
	
	return self;
}

-(void)dealloc
{
	NSFileManager *fm = [NSFileManager defaultManager];
	
	//NSLog(@"Start Dealocate TemporaryFolder(%@)", self );
	
	[fm  removeFileAtPath:_path handler:nil];
	[_path release];
	
	//NSLog(@"End Dealocate TemporaryFolder" );
	
	[super dealloc];
}

-(NSString *)path
{
	return [NSString stringWithString:_path];
}
-(NSURL *)url
{
	return [NSURL fileURLWithPath:_path];
}

-(id)description
{
	return [self path];
}

@end
