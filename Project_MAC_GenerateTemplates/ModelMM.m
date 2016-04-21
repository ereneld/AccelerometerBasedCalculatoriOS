//
//  ModelMM.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/5/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "ModelMM.h"

@implementation ModelMM


-(id)initWithStateNumber:(int)stateNumberValue{
	
	if(self = [super init])
	{
		numberOfStates = stateNumberValue;
		
		if ((initialProbability = malloc(stateNumberValue * sizeof(double))) == NULL){
			fprintf(stderr,"Memory allocation error (initialProbability 1)\n");
		}
		else {
			for (int i=0; i < stateNumberValue; i++)
			{
				initialProbability[i] =  0.0;
			}
		}
		
		if ((transitionProbabilityMatrix = malloc(stateNumberValue * sizeof(double*))) == NULL){
			fprintf(stderr,"Memory allocation error (transitionProbabilityMatrix 1)\n");
		}
		else {
			for (int i=0; i < stateNumberValue; i++){
				if ((transitionProbabilityMatrix[i]= malloc(stateNumberValue * sizeof(double))) == NULL){
					fprintf(stderr,"Memory allocation error (transitionProbabilityMatrix 2)\n");
				}
				else {
					for (int j=0; j < stateNumberValue; j++)
					{
						transitionProbabilityMatrix[i][j] =  0.0;
					}
				}
			}				
		}
	}
	
	return self;
}

-(void)initialize{
	for (int i=0; i < numberOfStates; i++)
	{
		initialProbability[i] =  0.0;
	}
	for (int i=0; i < numberOfStates; i++){
		for (int j=0; j < numberOfStates; j++)
		{
			transitionProbabilityMatrix[i][j] =  0.0;
		}
	}
}

-(void)calculateInitialProbabilityMatrix:(NSArray*)gestureSequenceDataArray{
	
	for(NSArray* oneSequenceArray in gestureSequenceDataArray){
		initialProbability[[[oneSequenceArray objectAtIndex:0]intValue] - 1] += 1.0;
	}
	
	for(int i=0;i<numberOfStates;i++){
		initialProbability[i] = (initialProbability[i] + 0.0001) / [gestureSequenceDataArray count];
	}
	
}

-(void)calculateTransitionProbabilityMatrix:(NSArray*)gestureSequenceDataArray{
	int totalNumberOfTransition=0; int indexOfPreviousObservation=0; int indexOfCurrentObservation=0;
	
	for(NSArray* oneSequenceArray in gestureSequenceDataArray){
		totalNumberOfTransition += [oneSequenceArray count] - 1;
		
		indexOfPreviousObservation = [[oneSequenceArray objectAtIndex:0]intValue] -1;
		for(int i=1; i<[oneSequenceArray count]; i++){
			indexOfCurrentObservation = [[oneSequenceArray objectAtIndex:i]intValue] -1;
			transitionProbabilityMatrix[indexOfPreviousObservation][indexOfCurrentObservation] += 1.0;
			indexOfPreviousObservation = indexOfCurrentObservation;
		}
	}
	
	for(int i=0;i<numberOfStates;i++){
		for(int j=0;j<numberOfStates;j++){
			transitionProbabilityMatrix[i][j] = (transitionProbabilityMatrix[i][j] + 0.0001) / totalNumberOfTransition;
		}
	}
	
}


-(void)traingGestureData:(NSArray*)gestureDataArray{
    
    int numberOfsequences = [gestureDataArray count]; // number of all training observation sequences
    NSMutableArray* gestureSequenceDataArray=[[NSMutableArray alloc]initWithCapacity:numberOfsequences];
    for (NSArray* tempDataArray in gestureDataArray) {
        [gestureSequenceDataArray addObject:[tempDataArray objectAtIndex:4]];
    }
    
	if (gestureSequenceDataArray && [gestureSequenceDataArray count]>0) {
		[self calculateInitialProbabilityMatrix:gestureSequenceDataArray];
		[self calculateTransitionProbabilityMatrix:gestureSequenceDataArray];
	}
	else {
		NSLog(@"ERROR - traingGestureData - null array");
	}

    [gestureSequenceDataArray release];
    gestureSequenceDataArray = nil;
}

-(double)getProbability:(NSArray*)gestureDataArray{
	double returnValue = 0.0;
	
    int numberOfsequences = [gestureDataArray count]; // number of all training observation sequences
    NSMutableArray* oneSequenceArray=[[NSMutableArray alloc]initWithCapacity:numberOfsequences];
    for (NSArray* tempDataArray in gestureDataArray) {
        [oneSequenceArray addObject:[tempDataArray objectAtIndex:4]];
    }
    
	if (oneSequenceArray && [oneSequenceArray count]>0) {
		int indexOfPreviousObservation=[[oneSequenceArray objectAtIndex:0]intValue] - 1; 
		int indexOfCurrentObservation=0;
		returnValue = initialProbability[indexOfPreviousObservation] ; //+1
		for (int i=1; i< [oneSequenceArray count]; i++) {
			indexOfCurrentObservation = [[oneSequenceArray objectAtIndex:i]intValue] - 1;
			//!!!: Here in order to get rid of underflow error we multiply with 50 each probability then compare with each other
			returnValue = returnValue * (transitionProbabilityMatrix[indexOfPreviousObservation][indexOfCurrentObservation]) * 10; 
			indexOfPreviousObservation = indexOfCurrentObservation;
		}
	}
    [oneSequenceArray release];
	return returnValue;
}


-(NSString*)toString{
	NSString* returnValue = [NSString stringWithFormat:@"- Model Probability : %g ; \n", modelProbability];
	for (int i=0; i<numberOfStates; i++) {
		returnValue = [returnValue stringByAppendingFormat:@"%d - %g | ",i, initialProbability[i]];
		for (int j=0; j<numberOfStates; j++) {
			returnValue = [returnValue stringByAppendingFormat:@"%g ,",transitionProbabilityMatrix[i][j]];
		}
		returnValue = [returnValue stringByAppendingString:@"\n"];
	}
	return returnValue;
}


-(void) dealloc{
	free(initialProbability);
	free(transitionProbabilityMatrix);
	[super dealloc];
}

@end
