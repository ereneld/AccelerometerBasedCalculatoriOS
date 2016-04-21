//
//  Person.m
//  GestureData
//
//  Created by dogukan erenel on 4/11/10.
//  Copyright 2010 Bogazici University. All rights reserved.
//

#import "Person.h"
#import "GestureData.h"


@implementation Person

@synthesize age, sex, hand, handCurrent, disability, allGestureData; 

static Person* instancePerson;


-(void)setJobType:(JobType)selectedJobType{
	jobType=selectedJobType;
}

-(JobType)jobType{
	return jobType;
}

-(void)setEducationType:(EducationType)selectedEducationType{
	educationType=selectedEducationType;
}

-(JobType)educationType{
	return educationType;
}

-(NSString*)educationTypeString:(EducationType)selectedEducationType{
	NSString* returnString = nil;
	
	if (selectedEducationType==NoEducation) {
		returnString=@"No Education";
	}
	else if (selectedEducationType==UnknownEducation) {
		returnString=@"Unknown Education";
	}
	else if (selectedEducationType==ReadWrite) {
		returnString=@"Read Write";
	}
	else if (selectedEducationType==ElementerySchool) {
		returnString=@"Elementery School";
	}
	else if (selectedEducationType==HighSchool) {
		returnString=@"High-School";
	}
	else if (selectedEducationType==UnderGraduate) {
		returnString=@"UnderGraduate";
	}
	else if (selectedEducationType==MasterDegree) {
		returnString=@"Master Degree";
	}
	else if (selectedEducationType==PhdDegree) {
		returnString=@"Phd Degree";
	}
	else if (selectedEducationType==Professor) {
		returnString=@"Professor";
	}
	else {
		returnString=@"";
	}

	return returnString;
}

-(NSString*)educationTypeString{
	return [self educationTypeString:educationType];
}

-(NSString*)jobTypeString:(JobType)selectedJobType{
	NSString* returnString = nil;
	
	if (selectedJobType==NoJob) {
		returnString=@"No Job";
	}
	else if (selectedJobType==UnknownJob) {
		returnString=@"Unknown Job";
	}
	else if (selectedJobType==Student) {
		returnString=@"Student";
	}
	else if (selectedJobType==Teacher) {
		returnString=@"Teacher";
	}
	else if (selectedJobType==Worker) {
		returnString=@"Worker";
	}
	else if (selectedJobType==Doctor) {
		returnString=@"Doctor";
	}
	else if (selectedJobType==Engineer) {
		returnString=@"Engineer";
	}
	else if (selectedJobType==SportProfession) {
		returnString=@"Sport Profession";
	}
	else if (selectedJobType==ArtProfession) {
		returnString=@"Art Profession";
	}
	else if (selectedJobType==Other) {
		returnString=@"Other";
	}
	else {
		returnString=@"";
	}
	
	return returnString;
}

-(NSString*)jobTypeString{
	return [self jobTypeString:jobType];
}

+(void) resetWithSamePersonalInformation{
	if (instancePerson) {
		for (GestureData* tempGestureData in instancePerson.allGestureData) {
			for (NSMutableArray* tempDataArray in tempGestureData.gestureData) {
				[tempDataArray removeAllObjects];
			}
		}
	}
}

+(Person*) getInstance{

	if (!instancePerson) {
		instancePerson=[[Person alloc]init];
		instancePerson.age=0;
		instancePerson.sex=@"?";
		instancePerson.hand=@"?";
        instancePerson.handCurrent =@"?";
		instancePerson.disability=NO;
		instancePerson.jobType=NoJob;
		instancePerson.educationType=NoEducation;
		instancePerson.allGestureData = [[NSMutableArray alloc]initWithCapacity:52];
		for (int i=0; i<22; i++) {
			GestureData* tempGestureData=[[GestureData alloc]init];
			
			NSMutableArray *arrayForTime = [[NSMutableArray alloc] init];
			NSMutableArray *arrayForX = [[NSMutableArray alloc] init];
			NSMutableArray *arrayForY = [[NSMutableArray alloc] init];
			NSMutableArray *arrayForZ = [[NSMutableArray alloc] init];
			NSMutableArray *arrayForCluster = [[NSMutableArray alloc] init];
			
			tempGestureData.gestureData=[[NSArray alloc] initWithObjects:arrayForTime,arrayForX,arrayForY,arrayForZ, arrayForCluster,nil];

			tempGestureData.gestureMainType = i+1;
			tempGestureData.gestureMovementType= 0;
			tempGestureData.gestureNumber = i+1;
			
			if (tempGestureData.gestureMainType<10) {
				tempGestureData.gestureTitle=[NSString stringWithFormat:@"0%d", tempGestureData.gestureMainType];
			}
			else {
				tempGestureData.gestureTitle=[NSString stringWithFormat:@"%d", tempGestureData.gestureMainType];
			}

			[instancePerson.allGestureData addObject:tempGestureData];
						
		}
		
	}
	return instancePerson;
}

//AGE_SEX_HAND_DISABILITY_EDUCATION_JOB (exp: 22_M_L_Y_2_01 )
-(NSString*) personDescription{
	
	NSString* returnValue=@"";
	if (age>0) {
		returnValue= [returnValue stringByAppendingString:[NSString stringWithFormat:@"%d", age]];
	}
	else {
		returnValue= [returnValue stringByAppendingString:@"?"];
	}
	returnValue= [returnValue stringByAppendingString:[NSString stringWithFormat:@"_%@", sex]];
	returnValue= [returnValue stringByAppendingString:[NSString stringWithFormat:@"_%@", hand]];

	if (disability) {
		returnValue= [returnValue stringByAppendingString:@"_Y"];
	}
	else {
		returnValue= [returnValue stringByAppendingString:@"_N"];
	}

	returnValue= [returnValue stringByAppendingString:[NSString stringWithFormat:@"_%d", educationType]];
	returnValue= [returnValue stringByAppendingString:[NSString stringWithFormat:@"_%d", jobType]];

	return returnValue;
}

@end
