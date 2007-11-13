//
//  BSIPILeopardSlideshowHelper.m
//  BSIPILeopardSlideshowHelper
//
//  Created by Tsutomu Sawada on 07/11/12.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "BSIPILeopardSlideshowHelper.h"


@implementation BSIPILeopardSlideshowHelper
#pragma mark Singleton Object
static id st_instance = nil;

+ (id)sharedInstance
{
    @synchronized(self) {
        if (!st_instance) {
            [[self alloc] init];
        }
    }
    return st_instance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (!st_instance) {
            st_instance = [super allocWithZone:zone];
            return st_instance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (unsigned)retainCount
{
	return UINT_MAX;
}

- (void)release
{
	// Do nothing.
}

- (id)autorelease
{
	return self;
}

- (void)dealloc
{
	m_cube = nil;
	[super dealloc];
}

#pragma mark Accessors
- (NSArrayController *)arrayController
{
	return m_cube;
}

- (void)setArrayController:(id)aController
{
	if (aController != m_cube) {
		m_cube = aController;
	}
}

#pragma mark Public Method
- (void)startSlideshow
{
	unsigned int selectionIdx = [[self arrayController] selectionIndex];
	if (selectionIdx == NSNotFound) {
		[[self arrayController] setSelectionIndex:0];
		selectionIdx = 0;
	}

	NSNumber *no = [NSNumber numberWithBool:NO];
	NSNumber *yes = [NSNumber numberWithBool:YES];
	NSNumber *idx = [NSNumber numberWithUnsignedInt:selectionIdx];

	IKSlideshow	*slideshow = [IKSlideshow sharedSlideshow];

	slideshow.autoPlayDelay = 5.0;
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:yes, IKSlideshowWrapAround,
																	    no, IKSlideshowStartPaused,
																	   idx, IKSlideshowStartIndex,
																	   NULL];

	[slideshow runSlideshowWithDataSource:self inMode:IKSlideshowModeImages options:options];
}

#pragma mark IKSlideshowDataSource Protocol
- (NSUInteger)numberOfSlideshowItems
{
	return [[[self arrayController] arrangedObjects] count];
}

- (id)slideshowItemAtIndex:(NSUInteger)index
{
	return [[[[self arrayController] arrangedObjects] objectAtIndex:index] valueForKey:@"downloadedFilePath"];
}

- (void)slideshowDidChangeCurrentIndex:(NSUInteger)newIndex
{
	[[self arrayController] setSelectionIndex:newIndex];
}
@end
