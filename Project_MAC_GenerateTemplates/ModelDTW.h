//
//  ModelDTW.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/24/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "Classifier.h"
#import "GestureData.h"
//Dynamic time warping with Levenshtein distance
@interface ModelDTW : Classifier {

    int numberOfElements; // number of observation (sample)
    int numberOfsequences;
    
    double* variance;   // All the general variance, 0-X, 1-Y, 2-Z, 3-Cluster
    double* mean;       // All the general mean, 0-X, 1-Y, 2-Z, 3-Cluster
    double length; // the sequence average time length !
    
    double* templateT;
    double* templateX;
    double* templateY;
    double* templateZ;
    double* templateCluster;
    
    double** upperLimit; // [4][sample size] 0-X, 1-Y, 2-Z, 3-Cluster
    double** lowerLimit; // [4][sample size] 0-X, 1-Y, 2-Z, 3-Cluster
    int limitRange;
    int** warpingWindowSize; //if all 0-> euclidean distance will be seen [4][numberofelement]
    //int* warpingWindowSize; //if all 0-> euclidean distance will be seen [4]
    
    double* rangeValueForEnvelope;
    
    double** varianceAll; // All the point variance, varianceAll[time][dimension] = dimension 0-X, 1-Y, 2-Z, 3-Cluster
    
    double** distanceDTW; // [4][3] dimension min, average, max
    double minDistance, averageDistance, maxDistance;
    
}
@property(nonatomic, assign)double minDistance;
@property(nonatomic, assign)double averageDistance;
@property(nonatomic, assign)double maxDistance;
@property(nonatomic, assign)double** distanceDTW;

-(id)initWithSampleSize:(int)sampleSizeValue;
-(void)initialize;

-(void)traingGestureData:(NSArray*)gestureDataArray;
-(double)getProbability:(NSArray*)oneGestureDataArray;

-(void)traingDTWDistances:(NSArray*)gestureDataArray;

-(void)preprocessData:(NSArray*)oneSequenceDataArray andDimension:(int)dimension;

-(double)getUpperLimitValue:(NSArray*)oneSequenceDataArray andPointIndex:(int)pointIndex;
-(double)getLowerLimitValue:(NSArray*)oneSequenceDataArray andPointIndex:(int)pointIndex;
-(double)calculateLBKeoghDistance:(NSArray*)oneSequenceArray andDimension:(int)dimension;
-(double)calculateLBKeoghDistance:(NSArray*)oneGestureDataArray;

-(double)calculateDTWDistance:(NSArray*)oneSequenceArray andTemplate:(double*)templateArray andDimension:(int)dimension;
-(double)calculateDTWDistance:(NSArray*)oneGestureDataArray;
-(double)calculateClassificationDistance:(GestureData*)oneGestureData;
-(double)getDistanceFromThreshold:(double)value andMinValue:(double)minValue andAvgValue:(double)avgValue andMaxValue:(double)maxValue;
-(BOOL)isGestureInRange:(NSArray*)oneGestureDataArray;

//-(void)setWrapingWindowSize:(int)sizeOfWindow andDimension:(int)dimension;
//-(int)getWrapingWindowSize:(int)dimension;
-(void)setWrapingWindowSize:(int*)arraySizeOfWindow andDimension:(int)dimension;
-(int*)getWrapingWindowSize:(int)dimension;

-(NSString*)getShortString:(NSArray*)oneGestureDataArray;
@end
