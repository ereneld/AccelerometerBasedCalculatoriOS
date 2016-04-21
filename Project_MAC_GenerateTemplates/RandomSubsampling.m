//
//  RandomSubsampling.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/26/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "RandomSubsampling.h"
#import "GestureData.h"

@implementation RandomSubsampling


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
				foldIndexArray[i] = 0;	//default each set is in training -> 0th fold is our validation set
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
	
	for (int i=0; i<numberOfData; i++) {
		[tempArray addObject:[NSNumber numberWithInt:i]];
	}
	
	for (int j=0; j<numberOfDataInEachFold; j++) {
		tempIndex = arc4random() % [tempArray count];
		tempFreeIndex = [[tempArray objectAtIndex:tempIndex]intValue];
		foldIndexArray[tempFreeIndex] = -1; //we set it -1 for validation data
		[tempArray removeObjectAtIndex:tempIndex]; //we need to delete in order not to put once more a fold number to same index
	}
	
	[tempArray removeAllObjects];
}

-(void)makeTrainingAndValidationSet:(NSArray*)gestureDataArray{
	
	for (int i=0; i<[gestureDataArray count]; i++) {
		if(foldIndexArray[i]>= 0){
			[(GestureData*)[gestureDataArray objectAtIndex:i] setIsForTraining:YES];
		}
		else {
			[(GestureData*)[gestureDataArray objectAtIndex:i] setIsForTraining:NO];
		}
		
	}
	currentFoldIndex = -1;
}


@end
