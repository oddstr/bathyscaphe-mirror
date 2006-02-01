//: SGBaseQueue.h
/**
  * $Id: SGBaseQueue.h,v 1.2 2006/02/01 17:39:08 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     SGBaseQueue
 * @discussion さまざまなキュー
 */
#import <Foundation/Foundation.h>
//#import <SGFoundation/SGBaseObject.h>


/*!
 * @protocol   SGBaseQueue
 * @abstract   キューのプロトコル定義
 * @discussion このプロトコルに適合するクラスのインスタンスは
 *             キューとして利用できる
 */
@protocol SGBaseQueue <NSObject>
- (void) put : (id) item;
- (id) take;
- (BOOL) isEmpty;
@end


@interface SGBaseQueue : NSObject<SGBaseQueue>
//@interface SGBaseQueue : SGBaseObject<SGBaseQueue>
{
	NSMutableArray	*_mutableArray;
}
+ (id) queue;
@end



@interface SGBaseThreadSafeQueue : SGBaseQueue
{
	NSLock			*_lock;
}
@end
