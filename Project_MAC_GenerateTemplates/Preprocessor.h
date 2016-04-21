//
//  Preprocessor.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 4/5/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "DataSet.h"
#import "GestureData.h"
#import "Constants.h"
#import "ConfigurationManager.h"

@interface Preprocessor : NSObject {
@private
    NSString* meanString;
    NSString* varianceString;
}
@property(nonatomic, retain)NSString* meanString;
@property(nonatomic, retain)NSString* varianceString;

+(void)preprocessTrainingDataSet:(DataSet*)currentDataSet;
+(void)preprocessTrainingDataSet:(DataSet*)currentDataSet andMakeSameMean:(BOOL)makeSameMean andMakeSameVariance:(BOOL)makeSameVariance;


//+(void)preprocessValidationDataSet:(DataSet*)currentDataSet;
+(void)postProcessTrainingDataSet:(DataSet*)currentDataSet;

// All the data sequences will change according to DTW to minimiza the error
-(void)makeDTWOneSequence:(NSMutableArray*)oneSequenceArray andTemplate:(double*)templateArray;
-(void)makeDTW:(NSArray*)gestureDataArray andTemplate:(double**)arrayTemplate;
-(double**)getMean:(NSArray*)gestureDataArray;


// Making the one class of elements with same mean
-(void)makeSameMean:(NSArray*)gestureDataArray;

// Making the one class of elements with same variance
-(void)makeSameVariance:(NSArray*)gestureDataArray;

// Making the elements with given mean value
-(void)makeSameMean:(NSArray*)gestureDataArray andMeanValue:(double)mean;

// Making the elements with given variance value
-(void)makeSameVariance:(NSArray*)gestureDataArray andVarianceValue:(double)variance;

@end
