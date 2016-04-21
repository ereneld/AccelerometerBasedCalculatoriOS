//
//  GestureData.h
//  GestureData
//
//  Created by dogukan erenel on 4/11/10.
//  Copyright 2010 Bogazici University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GestureData : NSObject {

	NSArray *gestureData; //5 dimension - 0: Time , 1: X , 2: Y, 3:Z , 4:ClusterNumber  (OR UIAcceleration with array of plist)
	//NSMutableArray *gestureStateData;  // After sampling / quantization -> the data / double value
	//NSMutableArray *gestureStateData_int;  // After sampling / quantization -> the data / double value
	NSString *gestureTitle; //GESTURENAME_AGE_SEX_DISABILITY_EDUCATION_JOB (exp: A2_22_M_Y_2_01 )
	NSString* gestureFullPath;
	int gestureNumber;
	int gestureNumber_PREDICTED; //used after classification for test data
	int gestureMainType;
	int gestureMovementType;
	double zKeyValue; // ( |max z - min z| / |time max z - time min z|)
	bool isForTraining; //if YES -> then for training else use for test
}

@property(assign,nonatomic)NSArray *gestureData;
//@property(retain,nonatomic)NSMutableArray *gestureStateData;
//@property(retain,nonatomic)NSMutableArray *gestureStateData_int;
@property(retain,nonatomic)NSString *gestureTitle;
@property(retain,nonatomic)NSString *gestureFullPath;

@property(nonatomic, assign)int gestureNumber;
@property(nonatomic, assign)int gestureNumber_PREDICTED;
@property(nonatomic, assign)int gestureMainType;
@property(nonatomic, assign)int gestureMovementType;
@property(nonatomic, assign)double zKeyValue;
@property(nonatomic, assign)bool isForTraining;

-(BOOL) isGestureFilled;
-(NSString*)getStatementIntString;
-(NSString*)getDataStringForMatlab;
-(NSString*)getClusterSquenceStringForMatlab;
@end
