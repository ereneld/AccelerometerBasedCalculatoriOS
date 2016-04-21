//
//  ModelHMMWii.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/24/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "Classifier.h"

@interface ModelHMMWii : Classifier {
	int numberOfStates;			//N - the number of states of model
	int numberOfObservation;	//M - the number of observations in state sequence of model
	//int observationLength;
	
	double* pi;	//The initial probabilities for each state: p[state]
	double** a; // The state change probability to switch from state A to state B: a[stateA][stateB] 
	double** b; // The probability to emit symbol S in state A: b[stateA][symbolS]
	
	//double** alpha; // The forward variable array [state][observation time] -> it is reset for each forward variable call and fill itself
	//double** beta; // The backward varible array [state][observation time] -> it is reset for each backward variable call and fill itself

}

-(id)initWithStateNumber:(int)sNumber andObservationNumber:(int)oNumber;
-(void)initialize;

-(void)traingGestureData:(NSArray*)gestureDataArray;

-(double)getProbability:(NSArray*)gestureDataArray;

//-(void)generateForwardVariableArray:(NSArray*) observationSequenceArray andState:(int)stateIndexValue;
//-(void)generateBackwardVariableArray:(NSArray*) observationSequenceArray andState:(int)stateIndexValue;
	
-(double**)forwardProcedure:(NSArray*) o;
-(double**)backwardProcedure:(NSArray*) o;

-(double**)getNewDoubleArray:(int)firstDimension andSecondDimension:(int)secondDimension;
@end
