//: CMXMenuHolder.m
/**
  * $Id: CMXMenuHolder.m,v 1.1.1.1 2005/05/11 17:51:03 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMXMenuHolder.h"
#import "UTILKit.h"


@implementation CMXMenuHolder
+ (NSMenu *) menuFromBundle : (NSBundle *) bundle
			        nibName : (NSString *) nibName
{
	id		instance_;
	
	instance_ = [[self alloc] initWithBundle:bundle nibName:nibName];
	[instance_ autorelease];
	
	return [instance_ menu];
}
- (id) initWithBundle : (NSBundle *) bundle
			  nibName : (NSString *) nibName
{
	UTILAssertNotNilArgument(bundle, @"bundle");
	UTILAssertNotNilArgument(nibName, @"nibName");
	if(self = [super init]){
		NSDictionary	*externalNameTable_;
		
		externalNameTable_ = 
			[NSDictionary dictionaryWithObjectsAndKeys :
					self,
					@"NSOwner",
					nil];
		if(NO == [bundle loadNibFile : nibName
						  externalNameTable : externalNameTable_
								   withZone : [self zone]]){
			NSLog(@"Can't locate nib file %@", nibName);
			
			[self release];
			return nil;
		}
	}
	return self;
}
- (NSMenu *) menu
{
	return _menu;
}

- (void) dealloc
{
	[_menu release];
	[super dealloc];
}
@end
