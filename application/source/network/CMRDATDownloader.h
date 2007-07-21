//
//  CMRDATDownloader.h
//  BathyScaphe "Twincam Angel"
//
//  Updated by Tsutomu Sawada on 07/07/22.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThreadTextDownloader.h"



@interface CMRDATDownloader : ThreadTextDownloader
@end

extern NSString *const CMRDATDownloaderDidDetectDatOchiNotification; // available in CometBlaster and later.
