/**
  * $Id: NSData-SGExtensions.m,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "NSData-SGExtensions.h"
#import <SGFoundation/PrivateDefines.h>
#import <SGFoundation/SGFileRef.h>



#define DATA_READ_BUFFER_SIZE	(((4 * 2) + 8) * 1024)



static NSData *CreateDataWithContentsOfFSRef_(FSRef *fromFSRef, NSZone *zone)
{
	NSMutableData		*mdata_;
	HFSUniStr255		forkName_;
	SInt16				forkRefNum_;
	OSErr				err;
	Byte				buffer_[DATA_READ_BUFFER_SIZE];
	
	
	err = FSGetDataForkName(&forkName_);
	UTILDebugRequire(noErr == err, ErrOSError, @"FSGetDataForkName");
	
	err = FSOpenFork(fromFSRef,
						forkName_.length,
						forkName_.unicode,
						fsRdPerm,
						&forkRefNum_);
	UTILDebugRequire(noErr == err, ErrOSError, @"FSOpenFork");
	
	mdata_ = [[NSMutableData allocWithZone : zone] init];
	do {
		ByteCount			requestCount_;
		ByteCount			actualCount_;
		
		requestCount_ = DATA_READ_BUFFER_SIZE * sizeof(Byte);
		err = FSReadFork(forkRefNum_,
							fsAtMark,
							0,
							requestCount_,
							&buffer_,
							&actualCount_);
		actualCount_ /= sizeof(Byte);
		[mdata_ appendBytes:buffer_ length:actualCount_];
	} while (noErr == err);
	
	err = FSCloseFork(forkRefNum_);
	UTILDebugRequire(noErr == err, ErrOSError, @"FSCloseFork");
	
	return mdata_;

ErrOSError:
	
	return nil;
}



@implementation NSData(SGExtensions)
+ (id) dataWithContentsOfFileRef : (SGFileRef *) fileRef
{
	return [[[self alloc] 
				initWithContentsOfFileRef : fileRef] autorelease];
}
- (id) initWithContentsOfFileRef : (SGFileRef *) fileRef
{
	[self autorelease];
	if (nil == fileRef) return nil;
	return CreateDataWithContentsOfFSRef_(
				[fileRef getFSRef],
				[self zone]);
}

- (BOOL) isEmpty
{
	return (0 == [self length]);
}
@end
