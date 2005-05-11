//: SGBaseQueue.h
/**
  * $Id: SGBaseQueue.h,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     SGBaseQueue
 * @discussion さまざまなキュー
 */
#import <Foundation/Foundation.h>
#import <SGFoundation/SGBaseObject.h>


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


@interface SGBaseQueue : SGBaseObject<SGBaseQueue>
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
