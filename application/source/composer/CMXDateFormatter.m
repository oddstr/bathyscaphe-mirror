//: CMXDateFormatter.m
/**
  * $Id: CMXDateFormatter.m,v 1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMXDateFormatter.h"
#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>
#import "UTILKit.h"


#define APP_NATURALLANGUAGE_DATEFORMAT	@"%b/%e %I:%M%p"


static NSString *const kStrTodayKey     = @"Today";
static NSString *const kStrYesterdayKey = @"Yesterday";

/*!
 * @function     AppGetTodayCalendarDate
 * @abstract    ���݂̓��t�̔N������ݒ�
 * @discussion  
 * @param    year   �N
 * @param    month  ��
 * @param    day    ��
 * @result          NSCalendarDate(Today)
 */
static NSCalendarDate *AppGetTodayCalendarDate(
										  int      *year,
										  unsigned *month,
										  unsigned *day);

/*!
 * @function     AppGetBasicDataOfYesterday
 * @discussion  
 *
 * ���t�Ǝ����Ɣ�r���邽�߂ɗp����A
 * ����O��00:00AM��Date
 * 
 * @result    NSDate
 */
static NSDate *AppGetBasicDataOfYesterday(void);

/*!
 * @function     AppGetBasicDataOfToday
 * @discussion  
 *
 * ���t�Ǝ����Ɣ�r���邽�߂ɗp����A
 * ���̓���00:00AM��Date
 * 
 * @result    NSDate
 */
static NSDate *AppGetBasicDataOfToday(void);

/*!
 * @function     AppGetBasicDataOfToday
 * @discussion  
 *
 * ���t�Ǝ����Ɣ�r���邽�߂ɗp����A
 * ���̔N�̌��U��00:00AM��Date
 * 
 * @result    NSDate
 */
static NSDate *AppGetBasicDataOfThisYear(void);

static NSDate * AppGetBasicDataOfYesterday_everyTime();
static NSDate * AppGetBasicDataOfToday_everyTime();


@implementation CMXDateFormatter
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance);

- (id) init
{
	dateOfYesterday_ = dateOfToday_ = nil;

	return [self initWithDateFormat : APP_NATURALLANGUAGE_DATEFORMAT
			   allowNaturalLanguage : NO];
}

#if PATCH
- (void)dealloc {
	if (dateOfYesterday_) {[dateOfYesterday_ release]; dateOfYesterday_ = nil;}
	if (dateOfToday_) {[dateOfToday_ release]; dateOfToday_ = nil;}
	[super dealloc];
}
#endif

- (NSString *) naturalLanguageDescriptionWithDate : (NSDate *) date
{
	NSString	*year_ = @"";
	NSString	*date_;
	NSString	*time_;
	
	NSComparisonResult compareToday_;		//�����Ƃ̔�r����
	NSComparisonResult compareYesterday_;	//����Ƃ̔�r����
	
	time_ =  [date descriptionWithCalendarFormat : @"%H:%M" 
						  timeZone : [NSTimeZone localTimeZone] 
						  locale   : nil];
				
	//���ݎ����Ƃ̊Ԋu�ɂ���āA
	//�K�؂ȕ������Ԃ��B
	
	//���t�̏���������
#if PATCH
// �C���X�^���X���ɐ���
	if (!dateOfYesterday_)
		dateOfYesterday_ = AppGetBasicDataOfYesterday_everyTime();
	if (!dateOfToday_)
		dateOfToday_ = AppGetBasicDataOfToday_everyTime();
	compareYesterday_ = [date compare : dateOfYesterday_];
	compareToday_ = [date compare : dateOfToday_];
#else
	compareYesterday_ = [date compare : AppGetBasicDataOfYesterday()];
	compareToday_ = [date compare : AppGetBasicDataOfToday()];
#endif
	
	if(compareToday_ != NSOrderedAscending){
		date_ = NSLocalizedString(kStrTodayKey, @"Today");
	}else if(compareYesterday_ != NSOrderedAscending){
		date_ = NSLocalizedString(kStrYesterdayKey, @"Yesterday");
	}else{
		date_ = [date descriptionWithCalendarFormat : @"%m.%d" 
							timeZone : [NSTimeZone localTimeZone] 
							locale   : nil];
	}
	
	// ���N���O�͔N��\��
	//
	// ex: NSLocalizedString(kStrLastYearKey, @"Last Year");
	//
	if(NSOrderedAscending == [date compare : AppGetBasicDataOfThisYear()]){
		year_ = [date descriptionWithCalendarFormat : @"%Y " 
							timeZone : [NSTimeZone localTimeZone] 
							locale   : nil];
	}
	
	return [NSString stringWithFormat : @"%@%@ %@",
										year_,
										date_,
										time_];
}

- (NSString *) stringForObjectValue : (id) anObject
{
	if(NO == [anObject isKindOfClass : [NSDate class]])
		return nil;
	
	return [self naturalLanguageDescriptionWithDate : anObject];
}
@end



static NSDate *AppGetBasicDataOfYesterday_everyTime(void)
{
#if PATCH
	NSDate *dateOfYesterday_ = nil;
#else
	static NSDate *dateOfYesterday_;
#endif
	
	if(nil == dateOfYesterday_){
		int year_;
		unsigned int month_;
		unsigned int day_;
		
		AppGetTodayCalendarDate(&year_, &month_, &day_);
		
		dateOfYesterday_ = 
			[NSCalendarDate dateWithYear : year_
								   month : month_
									 day : (day_ -1)
									hour : 0
								  minute : 0
								  second : 0
								timeZone : [NSTimeZone localTimeZone]];
		[dateOfYesterday_ retain];
	}
	return dateOfYesterday_;
}

#if PATCH
static NSDate * AppGetBasicDataOfToday_everyTime()
{
#if PATCH
	NSDate *dateOfToday_ = nil;
#else
	static NSDate *dateOfToday_;
#endif
	
	if(nil == dateOfToday_){
		int year_;
		unsigned int month_;
		unsigned int day_;
		
		AppGetTodayCalendarDate(&year_, &month_, &day_);
		
		dateOfToday_ = 
			[NSCalendarDate dateWithYear : year_
								   month : month_
									 day : day_
									hour : 0
								  minute : 0
								  second : 0
								timeZone : [NSTimeZone localTimeZone]];
		[dateOfToday_ retain];
	}
	return dateOfToday_;
}
#endif


static NSCalendarDate *AppGetTodayCalendarDate(
										  int      *year,
										  unsigned *month,
										  unsigned *day)
{
		NSCalendarDate *today_;
		int year_;
		unsigned int month_;
		unsigned int day_;
		
		today_ = [NSCalendarDate date];
		year_  = [today_ yearOfCommonEra];
		month_ = [today_ monthOfYear];
		day_   = [today_ dayOfMonth];
		
		if(year  != NULL) *year  = year_;
		if(month != NULL) *month = month_;
		if(day   != NULL) *day   = day_;
		
		return today_;
}

static NSDate *AppGetBasicDataOfYesterday(void)
{
#if PATCH
	NSDate *dateOfYesterday_ = nil;
#else
	static NSDate *dateOfYesterday_;
#endif
	
	if(nil == dateOfYesterday_){
		int year_;
		unsigned int month_;
		unsigned int day_;
		
		AppGetTodayCalendarDate(&year_, &month_, &day_);
		
		dateOfYesterday_ = 
		  [NSCalendarDate dateWithYear : year_
								 month : month_
								   day : (day_ -1)
								  hour : 0
								minute : 0
								second : 0
						      timeZone : [NSTimeZone localTimeZone]];
		[dateOfYesterday_ retain];
	}
	return dateOfYesterday_;
}

static NSDate *AppGetBasicDataOfToday(void)
{
#if PATCH
	NSDate *dateOfToday_ = nil;
#else
	static NSDate *dateOfToday_;
#endif
	
	if(nil == dateOfToday_){
		int year_;
		unsigned int month_;
		unsigned int day_;
		
		AppGetTodayCalendarDate(&year_, &month_, &day_);
		
		dateOfToday_ = 
		  [NSCalendarDate dateWithYear : year_
								 month : month_
								   day : day_
								  hour : 0
								minute : 0
								second : 0
						      timeZone : [NSTimeZone localTimeZone]];
		[dateOfToday_ retain];
	}
	return dateOfToday_;
}

static NSDate *AppGetBasicDataOfThisYear(void)
{
	static NSDate *dateOfThisYear_;
	
	if(nil == dateOfThisYear_){
		int year_;

		AppGetTodayCalendarDate(&year_, NULL, NULL);
		
		dateOfThisYear_ = 
		  [NSCalendarDate dateWithYear : year_ -1
								 month : 1
								   day : 1
								  hour : 0
								minute : 0
								second : 0
						      timeZone : [NSTimeZone localTimeZone]];
		[dateOfThisYear_ retain];
	}
	return dateOfThisYear_;
}
