//
//  TemporaryFolder.h
//  IconSetComposer
//
//  Created by Hori,Masaki on 05/08/15.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TemporaryFolder : NSObject
{
	NSString *_path;
}

+(id)temporaryFolder;
-(id)init;

-(NSString *)path;
-(NSURL *)url;

@end
