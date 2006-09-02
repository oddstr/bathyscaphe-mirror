//
//  BSDBThreadsListUpdateTask.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/08/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BSDBThreadsListUpdateTask.h"

NSString *BSDBThreadsListUpdateTaskDidFinishNotification = @"BSDBThreadsListUpdateTaskDidFinishNotification";

@implementation BSDBThreadsListUpdateTask

+ (id)taskWithBBSName:(NSString *)bbsName
{
	return [[[self alloc] initWithBBSName:bbsName] autorelease];
}
- (id)initWithBBSName:(NSString *)bbsName
{
	if(self = [super init]) {
		//
	}
	
	return self;
}
- (void)runOnMainThread:(id)dummy
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DidUpdateDBNotification"
														object:self];
}
- (void)run
{

	UTILDebugWrite(@"Start BSDBThreadsListUpdateTask.");
	// メインスレッド上でなければきちんと表示されない
	[self performSelectorOnMainThread:@selector(runOnMainThread:)
						   withObject:nil
						waitUntilDone:YES];
	/*
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DidUpdateDBNotification"
														object:self];
	 */
	[[NSNotificationCenter defaultCenter] postNotificationName:BSDBThreadsListUpdateTaskDidFinishNotification
														object:self];
	UTILDebugWrite(@"End BSDBThreadsListUpdateTask.");
}

- (void)cancel:(id)sender
{
	//
}


@end
