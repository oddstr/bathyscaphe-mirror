//
//  BSQuickLookObjec_p.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/02.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSQuickLookObject.h"
#import "BS2chQuickLookObject.h"
#import "BSHTMLQuickLookObject.h"

#import "CocoMonar_Prefix.h"

#import "CMRThreadSignature.h"
#import "CMRThreadMessage.h"
#import "CMRHostHandler.h"
#import "CMXTextParser.h"

@interface BSQuickLookObject(Private)
- (void)setThreadTitle:(NSString *)title;
- (void)setThreadSignature:(CMRThreadSignature *)signature;
- (void)setThreadMessage:(CMRThreadMessage *)message;

- (NSURLConnection *)currentConnection;
- (void)setCurrentConnection:(NSURLConnection *)connection;

- (void)setIsLoading:(BOOL)flag;
- (void)setLastError:(NSError *)error;

- (CFStringEncoding)encodingForData;

- (void)loadFromContentsOfFile;
- (void)startDownloadingQLContent;
- (CMRThreadMessage *)threadMessageFromReceivedData;
@end
