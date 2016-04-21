//
//  ModelMM.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/5/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "Classifier.h"

//Observable Markov Model -> all the states are observable (each cluster corresponds one state), we are going to use them
@interface ModelMM : Classifier {
	int numberOfStates;			//the number of states of model

	double* initialProbability;
	double** transitionProbabilityMatrix;
}

-(id)initWithStateNumber:(int)stateNumberValue;

-(void)traingGestureData:(NSArray*)gestureSequenceDataArray;
-(double)getProbability:(NSArray*)oneSequenceArray;

-(void)calculateInitialProbabilityMatrix:(NSArray*)gestureSequenceDataArray;
-(void)calculateTransitionProbabilityMatrix:(NSArray*)gestureSequenceDataArray;



@end
