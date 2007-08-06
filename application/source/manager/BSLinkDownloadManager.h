//
//  BSLinkDownloadManager.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/08/07.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BSLinkDownloadTicket : NSObject {
	NSString	*m_extension;
	BOOL		m_autoopen;
}
- (NSString *)extension;
- (void)setExtension:(NSString *)extensionString;
- (BOOL)autoopen;
- (void)setAutoopen:(BOOL)isAutoopen;
@end

@interface BSLinkDownloadManager : NSObject {
	NSMutableArray *m_downloadableTypes;
}

+ (id)defaultManager;

- (NSMutableArray *)downloadableTypes;
- (void)setDownloadableTypes:(NSMutableArray *)array;

- (void)writeToFileNow;
@end
