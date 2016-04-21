//
//  KFoldValidator.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/26/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "KFoldValidator.h"
#import "GestureData.h"


@implementation KFoldValidator

-(id)initWithKNumber:(int)kNumberValue andNumberOfData:(int)numberOfDataValue{
    self=[super init];
	if (self) {
		KNumber = kNumberValue;
		currentFoldIndex= 0;
		numberOfData = numberOfDataValue;
		
		if ((foldIndexArray = malloc(numberOfDataValue * sizeof(int))) == NULL)
		{
			fprintf(stderr,"Memory allocation error (foldIndexArray 1)\n");
		}
		else {
			for(int i=0; i < numberOfDataValue; i++){
				foldIndexArray[i] = 0;
			}
		}
		
		[self setupTrainingAndValidationFoldSet];
	
	}
	return self;
}

-(void)setupTrainingAndValidationFoldSet{
	NSMutableArray* tempArray = [[NSMutableArray alloc]initWithCapacity:numberOfData];
	int numberOfDataInEachFold = numberOfData / KNumber;
	int tempIndex = 0;
	int tempFreeIndex = 0;
	int tempFoldIndex = 0;
	for (int i=0; i<numberOfData; i++) {
		[tempArray addObject:[NSNumber numberWithInt:i]];
	}
	
	for (int i=0; i<KNumber; i++) {
		for (int j=0; j<numberOfDataInEachFold; j++) {
			tempIndex = arc4random() % [tempArray count];
			tempFreeIndex = [[tempArray objectAtIndex:tempIndex]intValue];
			foldIndexArray[tempFreeIndex] = i; //we set the data with given fold number
			[tempArray removeObjectAtIndex:tempIndex]; //we need to delete in order not to put once more a fold number to same index
		}
	}
	//Till we set fold number to the given datapoints equally -> now we set the extra points with fold numbers
	int extraDataCount = [tempArray count];
	for (int i=0; i<extraDataCount; i++) {
		tempFoldIndex = i % KNumber;
		tempIndex = arc4random() % [tempArray count];
		tempFreeIndex = [[tempArray objectAtIndex:tempIndex]intValue];
		foldIndexArray[tempFreeIndex] = tempFoldIndex; //we set the data with given fold number
		[tempArray removeObjectAtIndex:tempIndex]; //we need to delete in order not to put once more a fold number to same index
	}
}

-(void)makeTrainingAndValidationSet:(NSArray*)gestureDataArray{
	
	for (int i=0; i<[gestureDataArray count]; i++) {
		if(foldIndexArray[i]==currentFoldIndex){
			[(GestureData*)[gestureDataArray objectAtIndex:i] setIsForTraining:NO];
		}
		else {
			[(GestureData*)[gestureDataArray objectAtIndex:i] setIsForTraining:YES];
		}

	}
	currentFoldIndex++;
	if (currentFoldIndex >= KNumber) {
		currentFoldIndex = -1;
	}
}

@end
