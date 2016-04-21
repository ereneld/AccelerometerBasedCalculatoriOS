//
//  CrossValidator.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/26/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataSet;
@interface CrossValidator : NSObject {
	int KNumber; //The default number is 10
	int numberOfData; // In order to split the data we must know the total number of data (exp.100 gesture data array in one gesture)
	int currentFoldIndex; // The current Fold for Training Set
	int* foldIndexArray;	//For each data value we assign a fold number, so we need an array to assign the values and to determine the next folds training set etc.
	
}

@property(nonatomic, assign)int currentFoldIndex;

+(NSArray*) getCrossValidator:(DataSet*)currentDataSet;
+(void) reset;
+(void)determineTrainingAndValidationSet:(DataSet*)currentDataSet;
+(BOOL)hasNextValidation;

@end
