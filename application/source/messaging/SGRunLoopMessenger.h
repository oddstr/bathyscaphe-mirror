//: SGRunLoopMessenger.h
/**
  * $Id: SGRunLoopMessenger.h,v 1.1.1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     SGRunLoopMessenger
 * @discussion SGRunLoopMessenger <-- SGInternalMessaging
 */

#import <Foundation/Foundation.h>
#import "SGInternalMessenger.h"


/*!
 * @class      SGRunLoopMessenger
 * @abstract   SGInternalMessengerのクラス・クラスタ実装
 * @discussion SGRunLoopMessengerはポート間通信を利用して、
 *             異なるスレッド同士でメッセージをやりとりします。
 *             受信側のスレッドにはRunLoopが必要です。
 */
@interface SGRunLoopMessenger : SGInternalMessenger
{
	@private
	NSPort		*_sendPort;
}

/*!            
 * @method     sendPort
 * @abstract   送信用ポート
 * @discussion 送信用ポートのオブジェクトを返す
 * @result     NSPortインスタンス
 */            
- (NSPort *) sendPort;
@end
