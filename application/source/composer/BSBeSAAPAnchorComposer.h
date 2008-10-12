//
//  BSBeSAAPAnchorComposer.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/10/12.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

/*!
    @class		 BSBeSAAPAnchorComposer
    @abstract    Be ログインして書き込むと表示されるアイコンを描画する為のクラスです。
    @discussion  BSBeSAAPAnchorComposer のインスタンスは -[CMRAttributedMessageComposer(Anchor)
				 makeOuterLinkAnchor:] メソッド内部でのみ生成、使用、破棄されます。
				 saap:// で始まるリンクを http:// に変換し、-[NSImage initWithContentsOfURL:] で
				 イメージを取得（アイコンなのですぐに取得できるはず、と割り切っている）します。次に、その
				 イメージから NSTextAttachment を、さらにそれを含む NSAttributedString を生成し、
				 saap:// で始まるリンク文字列の部分と置き換えます。
*/

@interface BSBeSAAPAnchorComposer : NSObject {
	NSRange		m_replacingRange;
	NSString	*m_httpLinkString;
}

+ (BOOL)showsSAAPIcon;
+ (void)setShowsSAAPIcon:(BOOL)flag;
/*!
    @method     initWithRange:saapLinkString:
    @abstract   指定イニシャライザ
    @discussion BSBeSAAPAnchorComposer インスタンスを生成して返します。range には、本文メッセージ
				中で saap:// リンク文字列が存在する範囲を指定します。string には、saap:// リンク文字列
				そのものを指定します。
*/
- (id)initWithRange:(NSRange)range saapLinkString:(NSString *)string;

/*!
    @method     composeSAAPAnchorIfNeeded:
    @abstract   アイコンへの置き換えを実行
    @discussion message 本文メッセージ中の saap:// リンク文字列を、その指し示すアイコンに置き換えます。
				アイコンが取得できない場合は、単に saap:// リンク文字列が削除されます。
*/
- (void)composeSAAPAnchorIfNeeded:(NSMutableAttributedString *)message;
@end
