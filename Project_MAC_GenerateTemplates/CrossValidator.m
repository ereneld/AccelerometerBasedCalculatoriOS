//
//  CrossValidator.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/26/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "CrossValidator.h"
#import "DataSet.h"

#import "ConfigurationManager.h"
#import "Constants.h"

#import "KFoldValidator.h"
#import "RandomSubsampling.h"
#import "LeaveOneOut.h"

static NSMutableArray* instanceObjectCrossValidatorArray; //singleton object -> stores the array of model

//Hidden methods ! -> to use for instance object
@interface CrossValidator (PrivateMethods)

-(void)getReadyForNextFold; //should be defined in each cross validation algorithm
-(void)makeTrainingAndValidationSet:(NSArray*)gestureDataArray; //should be defined in each cross validation algorithm

@end


@implementation CrossValidator

@synthesize currentFoldIndex;

+(NSArray*) getCrossValidator:(DataSet*)currentDataSet{
	if (!instanceObjectCrossValidatorArray) {
		
		switch ((int)[ConfigurationManager getParameterValue:KPN_CROSSVALIDATOR_TYPE]) {
			case CrossValidatorTypeNONE:
				instanceObjectCrossValidatorArray = nil;
				break;
			case CrossValidatorTypeKFold:
				instanceObjectCrossValidatorArray = [[NSMutableArray alloc]initWithCapacity:[currentDataSet.gestureDataArray count]];
				
				for (int i= 0; i<[currentDataSet.gestureDataArray count]; i++) {
					NSMutableArray* gestureArray = [currentDataSet.gestureDataArray objectAtIndex:i];
					[instanceObjectCrossValidatorArray addObject:[[KFoldValidator alloc]initWithKNumber:[ConfigurationManager getParameterValue:KPN_CROSSVALIDATOR_K_NUMBER] andNumberOfData:[gestureArray count]]];
				}
				
				break;
			case CrossValidatorTypeRandomSubsampling:
				instanceObjectCrossValidatorArray = [[NSMutableArray alloc]initWithCapacity:[currentDataSet.gestureDataArray count]];

				for (int i= 0; i<[currentDataSet.gestureDataArray count]; i++) {
					NSMutableArray* gestureArray = [currentDataSet.gestureDataArray objectAtIndex:i];
					[instanceObjectCrossValidatorArray addObject:[[RandomSubsampling alloc]initWithKNumber:[ConfigurationManager getParameterValue:KPN_CROSSVALIDATOR_K_NUMBER] andNumberOfData:[gestureArray count]]];
				}
				break;
			case CrossValidatorTypeLeaveOneOut:
				instanceObjectCrossValidatorArray = [[NSMutableArray alloc]initWithCapacity:1];
				
				CrossValidator* tempLeaveOneOutCrossValidator = [[LeaveOneOut alloc] initWithKNumber:currentDataSet.totalNumberOfGestureData];
				[instanceObjectCrossValidatorArray addObject:tempLeaveOneOutCrossValidator];
				
				break;
			case CrossValidatorTypeNAN:
				instanceObjectCrossValidatorArray = nil;
				break;
			default:
				instanceObjectCrossValidatorArray = nil;
				break;
		}
	}

	return instanceObjectCrossValidatorArray;
}

// it should be called after classification finish!!
+(void) reset{
	[instanceObjectCrossValidatorArray removeAllObjects];
	[instanceObjectCrossValidatorArray release];
	instanceObjectCrossValidatorArray = nil;
}


+(void)determineTrainingAndValidationSet:(DataSet*)currentDataSet{
	NSArray* crossValidatorArray = [CrossValidator getCrossValidator:currentDataSet];
	if (crossValidatorArray) {
		CrossValidator* crossValidator = nil;
		
		if ([crossValidatorArray count]==1) {	// it is leave-one-out validation so we need to check each data 
			crossValidator = [crossValidatorArray objectAtIndex:0];
			[crossValidator makeTrainingAndValidationSet:currentDataSet.gestureDataArray];
		}
		else {
			for (int i=0; i<[currentDataSet.gestureDataArray count]; i++) {
				crossValidator = [crossValidatorArray objectAtIndex:i];
				NSArray* tempGestureDataArray = [currentDataSet.gestureDataArray objectAtIndex:i];
				[crossValidator makeTrainingAndValidationSet:tempGestureDataArray];
			}
		}
		[currentDataSet.operationsequenceArray addObject:K_OPERATION_CROSSVALIDATOR];
	}
	else {
		[currentDataSet.operationsequenceArray addObject:K_OPERATION_NONCROSSVALIDATOR];
	}
}

+(BOOL)hasNextValidation{
	BOOL returnValue = YES;
	NSArray* crossValidatorArray = instanceObjectCrossValidatorArray;
	if (crossValidatorArray) {
		for (int i=0; i<[crossValidatorArray count]; i++) {
			CrossValidator* crossValidator = [crossValidatorArray objectAtIndex:i];
			if (crossValidator.currentFoldIndex == -1) {
				returnValue = NO;
				break;
			}
		}
	}
	else {
		returnValue = NO;
	}
	return returnValue;
}


@end
