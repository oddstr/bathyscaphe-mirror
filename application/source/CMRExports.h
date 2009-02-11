/**
  * $Id: CMRExports.h,v 1.12 2009/02/11 14:49:59 tsawada2 Exp $
  * 
  * CMRExports.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */




#ifndef CMREXPORTS_H_INCLUDED
#define CMREXPORTS_H_INCLUDED

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif


//@class SGInternalMessenger;
@class CMRBrowser, NDRunLoopMessenger;
// main browser
extern CMRBrowser			*CMRMainBrowser;

// main thread & runLoop...
//extern NSThread				*CMRMainThread;
//extern NSRunLoop			*CMRMainRunLoop;
//extern SGInternalMessenger	*CMRMainMessenger;

extern void CMRApplicationReset(id sender);

/*!
 * @function    CMXInit
 * @discussion  �e�T�[�r�X�̏�����
 */
extern void CMXServicesInit(void);

/*!
 * @abstract    ���O�o�̓I�u�W�F�N�g
 * @discussion  �A�v���P�[�V�����S�̂Ŏg�p���郍�O�o�̓I�u�W�F�N�g
 */
//extern SGUtilLogger *CMRLogger;

/*!
 * @category    CMXFavoritesDirectoryName
 * @discussion  Version 1 �Ƃ̌݊����̂��߂����̋@�\
 */
#define CMXFavoritesDirectoryName	NSLocalizedString(@"Favorites", @"")

#define NSAppKitVersionNumber10_4 824

#ifdef __cplusplus
}  /* End of the 'extern "C"' block */
#endif
#endif /* CMREXPORTS_H_INCLUDED */
