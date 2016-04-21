//
//  Classifier.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/21/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "DataSet.h"
#import "GestureData.h"
#import "ConfusionMatrix.h"
#import "CrossValidator.h"

@interface Classifier : NSObject {	
	int classNumberActual; //it is used the see the predicted and actual class number
	double modelProbability; //it is used for model probability
}

@property(nonatomic, assign)int classNumberActual;
@property(nonatomic, assign)double modelProbability;

+(NSMutableArray*) getClassifierModelArray:(int)numberOfModel;
+(void) reset;
+(void)trainingWithAllDataSet:(DataSet*)currentDataSet;
+(ConfusionMatrix*)classifyDataSet:(DataSet*)currentDataSet;
+(int)classifyGestureData:(GestureData*)currentGestureData;
+(int)classifyGestureDataWithDTW:(GestureData*)currentGestureData andThresholdControl:(BOOL)thresholdControl;
+(ConfusionMatrix*)classifyHeuristic:(DataSet*)currentDataSet andThresholdControl:(BOOL)thresholdControl;
+(void)trainingForDTWDistances:(DataSet*)currentDataSet;

+(double)getModelProbability:(int)modelIndex;
+(double)getSequenceProbability:(GestureData*)currentGestureData andModelIndex:(int)modelIndex;
//+(void)testHMM:(DataSet*)currentDataSet;
+(NSString*)getsequenceString:(NSArray*)sequenceArray;

-(double****)getNewDoubleArray:(int)firstDimension andSecondDimension:(int)secondDimension andThirdDimension:(int)thirdDimension andFourthDimension:(int)fourthDimension;
-(double***)getNewDoubleArray:(int)firstDimension andSecondDimension:(int)secondDimension andThirdDimension:(int)thirdDimension;
-(double**)getNewDoubleArray:(int)firstDimension andSecondDimension:(int)secondDimension;
-(int**)getNewIntegerArray:(int)firstDimension andSecondDimension:(int)secondDimension;
-(double*)getNewDoubleArray:(int)firstDimension;
-(int*)getNewIntegerArray:(int)firstDimension;
-(void)freeArray:(double****)array andFirstDimension:(int)firstDimension andSecondDimension:(int)secondDimension andThirdDimension:(int)thirdDimension;
-(void)freeArray:(double***)array andFirstDimension:(int)firstDimension andSecondDimension:(int)secondDimension;
-(void)freeArray:(double**)array andFirstDimension:(int)firstDimension;
-(void)freeIntArray:(int**)array andFirstDimension:(int)firstDimension;
-(NSString*)toStringDoubleArray:(double**)array andFirstDimension:(int)firstDimension andSecondDimension:(int)secondDimension;

+(void)makeDTWBestWithValidationDataSet:(DataSet*)validationDataSet;
+(BOOL)evaluateDTWWithNewWrapWindowSize:(DataSet*)validationDataSet andPreviousBestDistance:(double*)previousBestDistance andPreviousBestTrueClassification:(int*)previousTrueClassification;

@end
