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
//////////////////// [ �C���X�^���X���\�b�h ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * ���݂̐ݒ�Őڑ����m�����A�f�[�^�𑗐M����B
  *
  * @return        �ڑ��ɐ��������ꍇ��YES
  */
- (BOOL) makeSocketHandleAndConnect
{
	NSFileHandle         *fhandle_;		//�t�@�C���n���h��
	NSData               *requestData_;	//���M�f�[�^
	NSURL                *resurl_;		//���M��

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
  * URL���炷�ׂẴf�[�^����M����B
  * ��M����������܂Ńu���b�N�B
  * 
  * @exception      NSFileHandleOperationException
  *
  * @return     ��M�����f�[�^
  */
- (NSData *) loadInForeground
{
	NSData *resourceData_;		//��M�����f�[�^
	
	if(NO == [self makeSocketHandleAndConnect]){
		[self setStatus : NSURLHandleLoadFailed];
		return nil;
	}
	
	resourceData_ = [[self socketHandle] readDataToEndOfFile];
	//�T�[�o����̃��X�|���X��؂蕪����B
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
  * �o�b�N�O�����h�Ŏ�M���J�n
  * 
  */
- (void) loadInBackground
{
	NSFileHandle         *fhandle_;		//�t�@�C���n���h��
	NSNotificationCenter *center_;		//�ʒm�Z���^

	[super loadInBackground];
	if(NO == [self makeSocketHandleAndConnect]){
		[self backgroundLoadDidFailWithReason : @"can't make connection."];
		return;
	}
	
	//�t�@�C���n���h�������ׂĂ�ǂݍ��񂾂Ƃ��ɒʒm
	//���󂯂�B
	fhandle_ = [self socketHandle];
	center_ = [NSNotificationCenter defaultCenter];
	[center_ addObserver : self
		        selector : @selector(loadResourceDataDidEnd:)
		            name : NSFileHandleReadToEndOfFileCompletionNotification
		          object : fhandle_];
	[fhandle_ readToEndOfFileInBackgroundAndNotify];
}

//////////////////////////////////////////////////////////////////////
/////////////////// [ ���I�u�W�F�N�g��Delegate] //////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * �ڑ����A�I�[�v�������t�@�C���n���h�������
  * �S�Ă�ǂݍ��񂾂Ƃ��̒ʒm����Ăяo����郁�\�b�h�B
  * 
  * @param    theNotification  �ʒm
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
	NSString *nn_, *rnn_;		//�ʒm��
	
	rnn_ = NSFileHandleReadToEndOfFileCompletionNotification;
	nn_  = [theNotification name];
	if([nn_ isEqualToString : rnn_]){
		NSFileHandle *fhandle_;		//�t�@�C���n���h��
		NSDictionary *useInfo_;		//���[�U����
		NSData       *resdata_;		//�擾�f�[�^
		
		fhandle_ = [theNotification object];
		useInfo_ = [theNotification userInfo];

		if(NO == [fhandle_ isEqual : [self socketHandle]]) return;
		
		[self setStatus : NSURLHandleLoadSucceeded];
		
		//�f�[�^������
		resdata_ = [useInfo_ objectForKey : NSFileHandleNotificationDataItem];
		//�T�[�o����̃��X�|���X��؂蕪����B
		[self setResponse : [SGHTTPResponse emptyResponse]];
		[self setSocketHandle : nil];
		if(NO == [[self response] appendBytes : resdata_]) return;
		
		[self didLoadBytes : [[self response] body]
			  loadComplete : YES];
	}
}
@end
