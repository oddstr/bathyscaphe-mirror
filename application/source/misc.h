//: misc.h
/**
  * $Id: misc.h,v 1.1 2005/05/11 17:51:03 tsawada2 Exp $
  * 
  * misc.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#ifndef MISC_H_INCLUDED
#define MISC_H_INCLUDED

#import <Foundation/Foundation.h>
#import <SGFoundation/SGFoundation.h>

#ifdef __cplusplus
extern "C" {
#endif



/*!
 * @function    CMXInit
 * @discussion  �e�T�[�r�X�̏�����
 */
extern void CMXServicesInit(void);

/*!
 * @abstract    ���O�o�̓I�u�W�F�N�g
 * @discussion  �A�v���P�[�V�����S�̂Ŏg�p���郍�O�o�̓I�u�W�F�N�g
 */
extern SGUtilLogger *CMRLogger;

/*!
 * @category    CMXFavoritesDirectoryName
 * @discussion  Version 1 �Ƃ̌݊����̂��߂����̋@�\
 */
#define CMXFavoritesDirectoryName	NSLocalizedString(@"Favorites", nil)



#ifdef __cplusplus
}  /* End of the 'extern "C"' block */
#endif
#endif /* MISC_H_INCLUDED */
