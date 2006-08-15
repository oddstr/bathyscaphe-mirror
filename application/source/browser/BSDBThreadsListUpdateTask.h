//
//  BSDBThreadsListUpdateTask.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/08/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CMRTask.h"
#import "CMXWorkerContext.h"

@interface BSDBThreadsListUpdateTask : NSObject <CMXRunnable>
{

}

+ (id)taskWithBBSName:(NSString *)bbsName;
- (id)initWithBBSName:(NSString *)bbsName;

@end

extern NSString *BSDBThreadsListUpdateTaskDidFinishNotification;