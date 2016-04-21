//
//  Person.h
//  GestureData
//
//  Created by dogukan erenel on 4/11/10.
//  Copyright 2010 Bogazici University. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	NoJob,
	UnknownJob,
	Student,
	Teacher,
	Worker,
	Doctor,
	Engineer,
	SportProfession,
	ArtProfession,
	Other
} JobType;

typedef enum {
	NoEducation,
	UnknownEducation,
	ReadWrite,
	ElementerySchool,
	HighSchool,
	UnderGraduate,
	MasterDegree,
	PhdDegree,
	Professor
} EducationType;


@interface Person : NSObject {
	
	NSInteger age;
	NSString* sex;
	NSString* hand;
    NSString* handCurrent;
	BOOL disability;
	JobType jobType;
	EducationType educationType;
	
	NSMutableArray* allGestureData;

}

@property(assign,nonatomic)NSInteger age;
@property(retain,nonatomic)NSString* sex;
@property(retain,nonatomic)NSString* hand;
@property(retain,nonatomic)NSString* handCurrent;
@property(assign,nonatomic)BOOL	disability;
@property(assign,nonatomic)NSMutableArray*	allGestureData;
//@property(retain,nonatomic)JobType jobType;
//@property(retain,nonatomic)EducationType educationType;
+(Person*) getInstance;
+(void) resetWithSamePersonalInformation;

-(void)setJobType:(JobType)selectedJobType;
-(JobType)jobType;
-(void)setEducationType:(EducationType)selectedEducationType;
-(JobType)educationType;

-(NSString*) personDescription;

@end
