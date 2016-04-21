//
//  LeaveOneOut.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/26/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "LeaveOneOut.h"
#import "GestureData.h"

@implementation LeaveOneOut


-(id)initWithKNumber:(int)numberOfDataValue{
    self=[super init];
	if (self) {
		KNumber = numberOfDataValue;
		currentFoldIndex= 0;
		numberOfData = numberOfDataValue;
		
		if ((foldIndexArray = malloc(numberOfDataValue * sizeof(int))) == NULL)
		{
			fprintf(stderr,"Memory allocation error (foldIndexArray 1)\n");
		}
		else {
			for(int i=0; i < numberOfDataValue; i++){
				foldIndexArray[i] = i;	//default each set is in training -> 0th fold is our validation set
			}
		}
		
		
	}
	return self;
}

-(void)makeTrainingAndValidationSet:(NSArray*)gestureDataArray{
	int indexOfEachGesture=0;
	
	for (int i=0; i<[gestureDataArray count]; i++) {
		NSArray* tempGestureDataArray = [gestureDataArray objectAtIndex:i];
		
		for (int j=0; j<[tempGestureDataArray count]; j++) {
			
			if(foldIndexArray[indexOfEachGesture]==currentFoldIndex){
				[(GestureData*)[tempGestureDataArray objectAtIndex:j] setIsForTraining:NO];
			}
			else {
				[(GestureData*)[tempGestureDataArray objectAtIndex:j] setIsForTraining:YES];
			}
			
			indexOfEachGesture++;
		}
	}
	currentFoldIndex++;
	if (currentFoldIndex >= numberOfData) {
		currentFoldIndex = -1;
	}
}

@end
