//: SGHTTPSocketHandle.m
/**
  * $Id: SGHTTPSocketHandle.m,v 1.1.1.1 2005/05/11 17:51:50 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <SGNetwork/SGHTTPSocketHandle.h>
#import <SGNetwork/SGHTTPRequest.h>
#import <SGNetwork/SGHTTPResponse.h>
#import <SGNetwork/SGHTTPSocketUtilities.h>
#import <SGNetwork/FrameworkDefines.h>
#import <AppKit/NSAttributedString.h>



@implementation SGHTTPSocketHandle
- (void) dealloc
{
	[m_socketHandle release];
	[super dealloc];
}

/* Accessor for m_socketHandle */
- (NSFileHandle *) socketHandle
{
	return m_socketHandle;
}
- (void) setSocketHandle : (NSFileHandle *) aSocketHandle
{
	[aSocketHandle retain];
	[m_socketHandle release];
	m_socketHandle = aSocketHandle;
}

//////////////////////////////////////////////////////////////////////
//////////////////// [ インスタンスメソッド ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * 現在の設定で接続を確立し、データを送信する。
  *
  * @return        接続に成功した場合にYES
  */
- (BOOL) makeSocketHandleAndConnect
{
	NSFileHandle         *fhandle_;		//ファイルハンドル
	NSData               *requestData_;	//送信データ
	NSURL                *resurl_;		//送信先

	if(nil == [self request]) return NO;
	
	resurl_ = [[self request] requestURL];
	if(nil == resurl_) return NO;
	fhandle_ = fnc_fileHandleForURL(resurl_);
	if(nil == fhandle_) return NO;
	
	requestData_ = [[self request] serializedMessage];
	if(nil == requestData_ || 0 == [requestData_ length])
		return NO;
	[fhandle_ writeData : requestData_];
	[self setSocketHandle : fhandle_];
	
	return YES;
}

/////////////////////////////////////////////////////////////////////
///////////////////////// [ NSURLHandle] ////////////////////////////
/////////////////////////////////////////////////////////////////////
/**
  * URLからすべてのデータを受信する。
  * 受信が完了するまでブロック。
  * 
  * @exception      NSFileHandleOperationException
  *
  * @return     受信したデータ
  */
- (NSData *) loadInForeground
{
	NSData *resourceData_;		//受信したデータ
	
	if(NO == [self makeSocketHandleAndConnect]){
		[self setStatus : NSURLHandleLoadFailed];
		return nil;
	}
	
	resourceData_ = [[self socketHandle] readDataToEndOfFile];
	//サーバからのレスポンスを切り分ける。
	[self setStatus : NSURLHandleLoadSucceeded];
	[self setResponse : [SGHTTPResponse emptyResponse]];
	[[self socketHandle] closeFile];
	[self setSocketHandle : nil];
	if(NO == [[self response] appendBytes : resourceData_]){
		return nil;
	}
	return [[self response] body];
}

/**
  * バックグランドで受信を開始
  * 
  */
- (void) loadInBackground
{
	NSFileHandle         *fhandle_;		//ファイルハンドル
	NSNotificationCenter *center_;		//通知センタ

	[super loadInBackground];
	if(NO == [self makeSocketHandleAndConnect]){
		[self backgroundLoadDidFailWithReason : @"can't make connection."];
		return;
	}
	
	//ファイルハンドルがすべてを読み込んだときに通知
	//を受ける。
	fhandle_ = [self socketHandle];
	center_ = [NSNotificationCenter defaultCenter];
	[center_ addObserver : self
		        selector : @selector(loadResourceDataDidEnd:)
		            name : NSFileHandleReadToEndOfFileCompletionNotification
		          object : fhandle_];
	[fhandle_ readToEndOfFileInBackgroundAndNotify];
}

//////////////////////////////////////////////////////////////////////
/////////////////// [ 他オブジェクトのDelegate] //////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * 接続し、オープンしたファイルハンドルからの
  * 全てを読み込んだときの通知から呼び出されるメソッド。
  * 
  * @param    theNotification  通知
  *
  * NSFileHandleReadToEndOfFileCompletionNotification
  *
  * Key - Value 
  * NSFileHandleNotificationDataItem
  *   An NSData containing the available data read 
  *   from a socket connection.
  * NSFileHandleNotificationMonitorModes
  *   An NSArray containing the run-loop
  *   modes in which the notification can be posted.
  */
- (void) loadResourceDataDidEnd : (id) theNotification
{
	NSString *nn_, *rnn_;		//通知名
	
	rnn_ = NSFileHandleReadToEndOfFileCompletionNotification;
	nn_  = [theNotification name];
	if([nn_ isEqualToString : rnn_]){
		NSFileHandle *fhandle_;		//ファイルハンドル
		NSDictionary *useInfo_;		//ユーザ辞書
		NSData       *resdata_;		//取得データ
		
		fhandle_ = [theNotification object];
		useInfo_ = [theNotification userInfo];

		if(NO == [fhandle_ isEqual : [self socketHandle]]) return;
		
		[self setStatus : NSURLHandleLoadSucceeded];
		
		//データを処理
		resdata_ = [useInfo_ objectForKey : NSFileHandleNotificationDataItem];
		//サーバからのレスポンスを切り分ける。
		[self setResponse : [SGHTTPResponse emptyResponse]];
		[self setSocketHandle : nil];
		if(NO == [[self response] appendBytes : resdata_]) return;
		
		[self didLoadBytes : [[self response] body]
			  loadComplete : YES];
	}
}
@end
