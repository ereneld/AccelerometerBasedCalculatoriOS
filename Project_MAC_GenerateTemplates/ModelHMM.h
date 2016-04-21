//
//  ModelHMM.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/22/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//



#import "Classifier.h"

@interface ModelHMM : Classifier {
	int numberOfStates;			//N - the number of states of model
	int numberOfObservation;	//M - the number of observations in state sequence of model
	int maxIteration;
	
	double* pi;	//The initial probabilities for each state: p[state]
	double** a; // The state change probability to switch from state A to state B: a[stateA][stateB] 
	double** b; // The probability to emit symbol S in state A: b[stateA][symbolS]
	
	int numberOfsequences;
	int observationsequenceLength;
    int dimenstionToClassify; // 0-time, 1-x, 2-y, 3-z, 4-amlitutede cluster
}

-(id)initWithStateNumber:(int)sNumber andObservationNumber:(int)oNumber andMaxIterationNumber:(int)maxIterationValue andDimensionToClassify:(int)dimensionIndex;
-(void)initialize;
-(void)traingGestureData:(NSArray*)gestureDataArray;
-(double)getProbability:(NSArray*)gestureDataArray;


-(double**)forwardProcedure:(NSArray*) observationSequence;
-(double**)forwardProcedureWithoutNormalization:(NSArray*) observationSequenceArray;
-(double**)backwardProcedure:(NSArray*) observationSequence;

-(void)calculateGamma:(double***)gamma andAlpha:(double**)alpha andBeta:(double**)beta andK:(int)k;
-(void)calculateXi:(double****)xi andAlpha:(double**)alpha andBeta:(double**)beta andK:(int)k andObservationSequence:(NSArray*)sequenceArray;
-(void)calculateNewA:(double***)gamma andXi:(double****)xi;
-(void)calculateNewB:(double***)gamma andGestureSequenceData:(NSArray*)gesturesequenceDataArray;
-(void)calculateNewPI:(double***)gamma;

@end
