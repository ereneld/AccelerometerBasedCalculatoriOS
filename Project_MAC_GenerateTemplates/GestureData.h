//
//  GestureData.h
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

typedef enum {
	kGestureDataSavingTypeText,
	kGestureDataSavingTypePlist,
	kGestureDataSavingTypeMatlab
} kGestureDataSavingType;

@interface GestureData : NSObject {

	NSString *gestureFullPath;
	NSString *gestureTitle;		//GESTURENAME_AGE_SEX_DISABILITY_EDUCATION_JOB (exp: A2_22_M_Y_2_01 )
	int gestureImageNumber;
	int gestureClassNumberActual;
	int gestureClassNumberPredicted;	//used after classification for test data
	bool isForTraining;				//if YES -> then for training else use for test
	
    int gestureMainType;
    int gestureMovementType;
    int gestureNumber;
    
	int personAge;
	NSString* personSex;
	NSString* personHandUsage;
    NSString* personCurrentHand;
	BOOL personDisability;
	JobType personJob;
	EducationType personEducation;
	
	NSDate* gestureDate;
	
	NSArray* gestureData;		//5 dimension - 0: Time , 1: X , 2: Y, 3:Z , 4:ClusterNumber  (OR UIAcceleration with array of plist)
    
    double* variance;   // All the general variance, 0-X, 1-Y, 2-Z, 3-Cluster
    double* mean;       // All the general mean, 0-X, 1-Y, 2-Z, 3-Cluster
    double length; // the sequence average time length !
}
@property(assign,nonatomic)NSArray *gestureData;
@property(retain,nonatomic)NSString *gestureFullPath;
@property(retain,nonatomic)NSString *gestureTitle;
@property(nonatomic, assign)int gestureImageNumber;
@property(nonatomic, assign)int gestureClassNumberActual;
@property(nonatomic, assign)int gestureClassNumberPredicted;
@property(nonatomic, assign)bool isForTraining;

@property(nonatomic, assign)int gestureNumber;
@property(nonatomic, assign)int gestureMainType;
@property(nonatomic, assign)int gestureMovementType;

@property(assign,nonatomic)int personAge;
@property(retain,nonatomic)NSString* personSex;
@property(retain,nonatomic)NSString* personHandUsage;
@property(retain,nonatomic)NSString* personCurrentHand;
@property(assign,nonatomic)BOOL	personDisability;
@property(assign,nonatomic)JobType personJob;
@property(assign,nonatomic)EducationType personEducation;

@property(retain,nonatomic)NSDate* gestureDate;
//@property(nonatomic, assign)double zKeyValue;
@property(assign,nonatomic)double* variance;

-(id)initWithDictionary:(NSDictionary*)plistDictionary;
-(id)initWithPath:(NSString*)fullPathString;
-(NSDictionary*)getDictionaryFileOfGestureData;

-(bool) isGestureFilled;
-(NSString*)getDataStringForMatlab;

-(BOOL)saveDataSetToPath:(NSString*)pathToSaveGestureData andSavingMethod:(kGestureDataSavingType)gestureDataSavingType;
-(BOOL)saveAsText:(NSString*)pathToSaveGestureData;
-(BOOL)saveAsMatlab:(NSString*)pathToSaveGestureData;
-(BOOL)saveAsPlist:(NSString*)pathToSaveGestureData;

-(NSString*)getDataStringForMatlab;
-(NSString*)getGestureDataInfoString;
//-(NSString*)getClustersequenceStringForMatlab;
//-(NSString*)getStatementIntString;
@end
