//: SGInternalMessenger.h
/**
  * $Id: SGInternalMessenger.h,v 1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     SGInternalMessenger
 * @discussion SGInternalMessengerクラス
 */

#import <Foundation/Foundation.h>


@protocol SGInternalMessaging
- (void) invokeMessage : (NSInvocation *) anInvocation
            withResult : (BOOL          ) aResultFlag;
@end


/*!
 * @class      SGInternalMessenger
 * @abstract   スレッド間のメッセージ通信を行うクラス
 *
 * @discussion SGInternalMessengerは別のスレッドにメッセージを
 *             送るときのインターフェースとなるクラスです。この
 *             クラスのインスタンスは生成された時点のスレッドと
 *             何らかのコネクションを確立します。送られたメッセ
 *             ージは受信側のスレッドで実行されます。結果を受け
 *             取る場合は受信側の処理が終了するまでブロックしま
 *             すが、結果を無視する場合はメッセージを送信し終え
 *             た時点で即座に戻ります。
 */
@interface SGInternalMessenger : NSObject<SGInternalMessaging>

/*!
 * @method     currentMessenger
 * @abstract   現在のThread(RunLoop)と通信するMessenger
 * @discussion 現在のThread(RunLoop)と通信するMessengerインスタンスを返します。
 *
 * @result     インスタンス
 */
+ (id) currentMessenger;

- (void)  target : (id ) aTarget
 performSelector : (SEL) aSelector;

- (void)  target : (id ) aTarget
 performSelector : (SEL) aSelector
      withObject : (id ) anObject;

- (void)  target : (id ) aTarget
 performSelector : (SEL) aSelector
      withObject : (id ) anObject
      withObject : (id ) anotherObject;

- (id)    target : (id  ) aTarget
 performSelector : (SEL ) aSelector
      withResult : (BOOL) aResultFlag;

- (id)    target : (id  ) aTarget
 performSelector : (SEL ) aSelector
      withObject : (id  ) anObject
      withResult : (BOOL) aResultFlag;

- (id)    target : (id  ) aTarget
 performSelector : (SEL ) aSelector
      withObject : (id  ) anObject
      withObject : (id  ) anotherObject
      withResult : (BOOL) aResultFlag;

// 通知
- (void) postNotification : (NSNotification *) aNotification
			 synchronized : (BOOL            ) sync;

// 非同期
- (void) postNotification : (NSNotification *) aNotification;
- (void) postNotificationName : (NSString     *) aNotificationName
					   object : (id            ) anObject;
- (void) postNotificationName : (NSString     *) aNotificationName
					   object : (id            ) anObject
					 userInfo : (NSDictionary *) aUserInfo;
@end



@interface SGInternalMessenger(CMXAdditions)
- (void *)    target : (id    ) aTarget
     performSelector : (SEL   ) aSelector
            argument : (void *) param2
          withResult : (BOOL  ) aResultFlag;
- (void *)    target : (id    ) aTarget
     performSelector : (SEL   ) aSelector
            argument : (void *) param1
            argument : (void *) param2
          withResult : (BOOL  ) aResultFlag;
@end


extern NSString *const SGInternalMessengerSendException;
