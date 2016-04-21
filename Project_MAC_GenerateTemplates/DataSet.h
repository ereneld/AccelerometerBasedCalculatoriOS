//
//  DataSet.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/2/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kDataSetSavingTypeText,
	kDataSetSavingTypePlist,
	kDataSetSavingTypeMatlab
} kDataSetSavingType;

@class GestureData;

//The dataset is storing all captured data within the sample application
@interface DataSet : NSObject {

	NSMutableArray* gestureDataArray; // It hold all the gesture data according to class number -> the array hold number of class of array, they hold the gesture data
    NSMutableArray* gestureDataArrayAllWithoutClass; // Used in clustering
    
	NSMutableArray* operationsequenceArray; //it holds all operation names to check what we did namely
	
	NSMutableArray* sequenceDataArray; //--> it is used for array of gesture sqeunce (after clustering) data according to their image number
	
	NSMutableArray* trainingDataArray;		//Multiple sequence of training data according to their image number
	NSMutableArray* validationDataArray;	
	
	int* arrayOfGestureClass;
	int* arrayOfGestureCount;
	
	int totalNumberOfGestureData;
	int totalNumberOfGestureClass;
	int totalNumberOfUniquePeople;
	int totalNumberOfMen;
	int totalNumberOfWomen;
	int totalNumberOfLeftHanded;
	int totalNumberOfRightHanded;
	int totalNumberOfDisability;
	int totalNumberOfNonDisability;
	
}
@property(nonatomic, retain)NSMutableArray* gestureDataArray;
@property(nonatomic, retain)NSMutableArray* gestureDataArrayAllWithoutClass;
@property(nonatomic, retain)NSMutableArray* operationsequenceArray;
@property(nonatomic, retain)NSMutableArray* sequenceDataArray;

@property(nonatomic, retain)NSMutableArray* trainingDataArray;
@property(nonatomic, retain)NSMutableArray* validationDataArray;

@property(nonatomic, assign)int totalNumberOfGestureData;


-(id)initWithGestureDataPath:(NSString*)pathOfGestureData;
-(id)initWithDateSetPath:(NSString*)pathOfDataSet;
-(void)setupDataSetAccordingToClassNumber;
-(BOOL)saveDataSetToPath:(NSString*)pathToSaveDataSet andSavingMethod:(kDataSetSavingType)dataSetSavingType;

-(NSMutableArray*)getGestureDataArrayWithoutClass; // Used in clustering
-(void)initializeObservationsequenceArray;
-(void)setGestureClassAndArray;
-(int)indexGestureDataInClassArray:(GestureData*) currentGestureData;
-(void)setDataSetAnalytics;
-(int) getNumberOfClass;
-(int)getNextEmptyIndex;

-(BOOL)saveAsText:(NSString*)pathToSaveDataSet;
-(BOOL)saveAsMatlab:(NSString*)pathToSaveDataSet;
-(BOOL)saveAsPlist:(NSString*)pathToSaveDataSet;

-(NSString*)getClassificationResultString;
-(double)getClassificationResultPercent;
-(NSString*)getDataAnaliyticString;

-(void)makeAllDataAsTraining;
-(void)setupTrainingAndValidationData;
/*
-(BOOL)filterDataSet
DimensionalReduction
Cluster
*/


@end
