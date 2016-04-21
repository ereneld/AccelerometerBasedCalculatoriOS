//
//  ModelHMMWii.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/24/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "ModelHMMWii.h"


@implementation ModelHMMWii

-(id)initWithStateNumber:(int)sNumber andObservationNumber:(int)oNumber{
	if(self = [super init])
	{
		numberOfStates = sNumber;
		numberOfObservation = oNumber;
		//observationLength = sampleSize;
		
		if ((pi = malloc(numberOfStates * sizeof(double))) == NULL)
		{
			fprintf(stderr,"Memory allocation error (pi 1)\n");
		}
		else {
			for(int i=0; i < numberOfStates; i++){
				pi[i] = 0.0;
			}
		}
		
		if ((a = malloc(numberOfStates * sizeof(double *))) == NULL)
		{
			fprintf(stderr,"Memory allocation error (a 1)\n");
		}
		else {
			for (int i=0; i < numberOfStates; i++){
				if ((a[i] = malloc(numberOfStates * sizeof(double))) == NULL)
				{
					fprintf(stderr,"Memory allocation error (a 2)\n");
				}
				else {
					for(int j=0; j < numberOfStates; j++){
						a[i][j] = 0.0;
					}
				}
				
			}
		}
		
		if ((b = malloc(numberOfStates * sizeof(double *))) == NULL)
		{
			fprintf(stderr,"Memory allocation error (a 1)\n");
		}
		else {
			for (int i=0; i < numberOfStates; i++){
				if ((b[i] = malloc(numberOfObservation * sizeof(double))) == NULL)
				{
					fprintf(stderr,"Memory allocation error (a 2)\n");
				}
				else {
					for(int j=0; j < numberOfObservation; j++){
						b[i][j] = 0.0;
					}
				}
				
			}
		}
		/*
		if ((alpha = malloc(numberOfStates * sizeof(double *))) == NULL)
		{
			fprintf(stderr,"Memory allocation error (alpha 1)\n");
		}
		else {
			for (int i=0; i < numberOfStates; i++){
				if ((alpha[i] = malloc(observationLength * sizeof(double))) == NULL)
				{
					fprintf(stderr,"Memory allocation error (alpha 2)\n");
				}
				else {
					for(int j=0; j < observationLength; j++){
						alpha[i][j] = 0.0;
					}
				}
				
			}
		}
		
		if ((beta = malloc(numberOfStates * sizeof(double *))) == NULL)
		{
			fprintf(stderr,"Memory allocation error (beta 1)\n");
		}
		else {
			for (int i=0; i < numberOfStates; i++){
				if ((beta[i] = malloc(observationLength * sizeof(double))) == NULL)
				{
					fprintf(stderr,"Memory allocation error (beta 2)\n");
				}
				else {
					for(int j=0; j < observationLength; j++){
						beta[i][j] = 0.0;
					}
				}
				
			}
		}
		*/
		
		[self initialize];
	}
	return self;
}

-(void)initialize{
	int jumplimit = 2;
	
	// set startup probability
	pi[0] = 1;
	for(int i=1; i<numberOfStates; i++) {
		pi[i] = 0;
	}
	
	// set state change probabilities in the left-to-right version
	// NOTE: i now that this is dirty and very static. :)
	for(int i=0; i<numberOfStates; i++) {
		for(int j=0; j<numberOfStates; j++) {
			if(i==numberOfStates-1 && j==numberOfStates-1) { // last row
				a[i][j] = 1.0;
			} else if(i==numberOfStates-2 && j==numberOfStates-2) { // next to last row
				a[i][j] = 0.5;
			} else if(i==numberOfStates-2 && j==numberOfStates-1) { // next to last row
				a[i][j] = 0.5;
			} else if(i<=j && i>j-jumplimit-1) {
				a[i][j] = 1.0/(jumplimit+1);
			} else {
				a[i][j] = 0.0;
			}
		}
	}
	
	
	// emission probability & forward & backward variables
	for(int i=0; i<numberOfStates; i++) {
		for(int j=0; j<numberOfObservation; j++) {
			b[i][j] = 1.0/(double)numberOfObservation;
		}
	}
	
	/*for(int i=0; i<numberOfStates; i++) {
		for(int j=0; j<observationLength; j++) {
			alpha[i][j] = 0.0;
			beta[i][j] = 0.0;
		}
	}
	 */
	
	
}

-(void)traingGestureData:(NSArray*)gestureDataArray{	
    int numberOfsequences = [gestureDataArray count]; // number of all training observation sequences
    NSMutableArray* gestureSequenceDataArray=[[NSMutableArray alloc]initWithCapacity:numberOfsequences];
    for (NSArray* tempDataArray in gestureDataArray) {
        [gestureSequenceDataArray addObject:[tempDataArray objectAtIndex:4]];
    }
    
	double** a_new = [self getNewDoubleArray:numberOfStates andSecondDimension:numberOfStates];
	double** b_new = [self getNewDoubleArray:numberOfStates andSecondDimension:numberOfObservation];
	
	// re calculate state change probability a
	for(int i=0; i<numberOfStates; i++) {
		for(int j=0; j<numberOfStates; j++) {	
			double numerator=0.0;
			double denominator=0.0;
			
			for(int k=0; k<[gestureSequenceDataArray count]; k++) {
				
				NSArray* sequenceArray = [gestureSequenceDataArray objectAtIndex:k];
				
				//[self generateForwardVariableArray:sequenceArray andState:-1];
				//[self generateBackwardVariableArray:sequenceArray andState:-1];
				double** alpha= [self forwardProcedure:sequenceArray];
				double** beta= [self backwardProcedure:sequenceArray];
				double prob = [self getProbability:sequenceArray];
				
				double numerator_innersum=0;
				double denominator_innersum=0;
				
				for(int t=0; t<[sequenceArray count]-1; t++) {
					numerator_innersum += alpha[i][t]*a[i][j]*b[j][[[sequenceArray objectAtIndex:t+1] intValue]-1]*beta[j][t+1];
					denominator_innersum += alpha[i][t]*beta[i][t];
				}
				
				if (prob!=0) {
					numerator += (1/prob)*numerator_innersum;
					denominator += (1/prob)*denominator_innersum;
				}
				
			} // k
			if (denominator!=0) {
				a_new[i][j] = numerator/denominator;
			}
			else {
				a_new[i][j] = 0;
			}

			
		} // j
	} // i
	
	// re calculate emission probability b
	for(int i=0; i<numberOfStates; i++) { // States
		for(int j=0; j<numberOfObservation; j++) {	// Observation symboles
			double numerator=0;
			double denominator=0;
			
			for(int k=0; k<[gestureSequenceDataArray count]; k++) {
				
				NSArray* sequenceArray = [gestureSequenceDataArray objectAtIndex:k];
				int sequence[[sequenceArray count]];
				for (int tempIndex = 0; tempIndex<[sequenceArray count]; tempIndex++) {
					sequence[tempIndex] = [[sequenceArray objectAtIndex:tempIndex] intValue] - 1;
				}
				
				//[self generateForwardVariableArray:sequenceArray andState:-1];
				//[self generateBackwardVariableArray:sequenceArray andState:-1];
				double** alpha= [self forwardProcedure:sequenceArray];
				double** beta= [self backwardProcedure:sequenceArray];
				double prob = [self getProbability:sequenceArray];
				
				double numerator_innersum=0;
				double denominator_innersum=0;
				
				
				for(int t=0; t<[sequenceArray count]-1; t++) {
					if(sequence[t]==j) {
						numerator_innersum+=alpha[i][t]*beta[i][t];
					}
					denominator_innersum+=alpha[i][t]*beta[i][t];
				}
				if (prob!=0) {
					numerator+=(1/prob)*numerator_innersum;
					denominator+=(1/prob)*denominator_innersum;
				}
				
			} // k
			
			if (denominator!=0) {
				b_new[i][j] = numerator/denominator;
			}
			else {
				b_new[i][j] = 0;
			}
			
		} // j
	} // i
	
	
	/*for(int i = 0; i < numberOfStates; i++)
		free(a[i]);
	free(a);
	
	for(int i = 0; i < numberOfStates; i++)
		free(b[i]);
	free(b);
	*/
	
	a=a_new;
	b=b_new;
	
    [gestureSequenceDataArray release];
    gestureSequenceDataArray = nil;
}

// Returning forward variable array - [State Value Index][Observation Index]
-(double**)forwardProcedure:(NSArray*) observationSequenceArray{
	int T = [observationSequenceArray count];
	double** alpha = [self getNewDoubleArray:numberOfStates andSecondDimension:T];
	double sumOfAllProbabilitiesComingFromPrevious = 0.0;
    double* ct = [self getNewDoubleArray:T];	//the sum of alpha values of a given time index
	
	
	
    //For each observation index (except that the Observation 0) starting from 1 - Looping in TIME
    for (int time = 0; time < T; time++) {
        if (time==0) {
            //The initial condition - for first observation (the 0 index) the forward variable value of state i = PI(i) x B[i][ Observation[0] ]
            for (int i = 0; i < numberOfStates; i++) {
                alpha[i][0] = pi[i] * b[i][[[observationSequenceArray objectAtIndex:0]intValue]-1];
            }
        }
        else{
            //For each state - Looping for each STATE to calculate the forward variable
            for (int stateIndex = 0; stateIndex < numberOfStates; stateIndex++) {
                sumOfAllProbabilitiesComingFromPrevious = 0.0;
                
                //To sum the probability of coming from each state we are looping each STATE
                for (int i = 0; i < numberOfStates; i++) {
                    sumOfAllProbabilitiesComingFromPrevious += alpha[i][time-1] * a[i][stateIndex];
                }
                
                alpha[stateIndex][time] = sumOfAllProbabilitiesComingFromPrevious * b[stateIndex][[[observationSequenceArray objectAtIndex:time]intValue]-1];
            }
        }
        
        ct[time] = 0.0;
		for (int stateIndex = 0; stateIndex < numberOfStates; stateIndex++) {
			ct[time] += alpha[stateIndex][time];
		}
		//Normalization
		for (int stateIndex = 0; stateIndex < numberOfStates; stateIndex++) {
			if (ct[time]!=0) {
				alpha[stateIndex][time] = alpha[stateIndex][time] / ct[time];
			}
			else {
				alpha[stateIndex][time] = 0;
			}
		}
    }
	
	return alpha;
}

// Returning backward variable array - [State Value Index][Observation Index]
-(double**)backwardProcedure:(NSArray*) observationSequenceArray{
	int T = [observationSequenceArray count];
	double** beta = [self getNewDoubleArray:numberOfStates andSecondDimension:T];
	double* ct = [self getNewDoubleArray:T];	//the sum of beta values of a given time index

	for (int time = T - 1; time >= 0; time--) {
        if (time==T-1) {
            // Basisfall
            for (int i = 0; i < numberOfStates; i++){
                beta[i][T - 1] = 1;
            }
        }
        else{	// Induktion 
            for (int i = 0; i < numberOfStates; i++) {
                beta[i][time] = 0;
                for (int j = 0; j < numberOfStates; j++)
                    beta[i][time] += (beta[j][time + 1] * a[i][j] * b[j][[[observationSequenceArray objectAtIndex:(time+1)]intValue]-1]);
            }
        }
		//Normalization
        ct[time] = 0.0;
		for (int stateIndex = 0; stateIndex < numberOfStates; stateIndex++) {
			ct[time] += beta[stateIndex][time];
		}
		
		for (int stateIndex = 0; stateIndex < numberOfStates; stateIndex++) {
			if (ct[time]!=0) {
				beta[stateIndex][time] = beta[stateIndex][time] / ct[time];
			}
			else {
				beta[stateIndex][time] = 0;
			}
		}
	}
	
	return beta;
}


-(double)getProbability:(NSArray*)gestureDataArray{
	double prob = 0.0;
    
    int numberOfsequences = [gestureDataArray count]; // number of all training observation sequences
    NSMutableArray* oneSequenceArray=[[NSMutableArray alloc]initWithCapacity:numberOfsequences];
    for (NSArray* tempDataArray in gestureDataArray) {
        [oneSequenceArray addObject:[tempDataArray objectAtIndex:4]];
    }
    
	//[self generateForwardVariableArray:gestureDataArray andState:-1];
	double** alpha= [self forwardProcedure:oneSequenceArray];
	//	add probabilities
	for (int i = 0; i <numberOfStates; i++) { // for every state
		prob += alpha[i][[oneSequenceArray count] - 1];
	}
    
    [oneSequenceArray release];
	return prob;
}


/*
-(double)getProbability:(NSArray*)gestureDataArray{
	double prob = 0.0;
	[self generateForwardVariableArray:gestureDataArray andState:-1];
	//	add probabilities
	for (int i = 0; i <numberOfStates; i++) { // for every state
		prob += alpha[i][[gestureDataArray count] - 1];
	}
	return prob;
}

-(void)generateForwardVariableArray:(NSArray*) observationSequenceArray andState:(int)stateIndexValue{
	double sumOfAllProbabilitiesComingFromPrevious = 0.0;
	
	//The initial condition - for first observation (the 0 index) the forward variable value of state i = PI(i) x B[i][ Observation[0] ]
	for (int i = 0; i < numberOfStates; i++) {
		alpha[i][0] = pi[i] * b[i][[[observationSequenceArray objectAtIndex:0]intValue]];
	}
	// Calculate forward variable for each time index of given State Index
	if (stateIndexValue>=0) {
		for (int time = 1; time < [observationSequenceArray count]; time++) {
			sumOfAllProbabilitiesComingFromPrevious = 0.0;
			
			//To sum the probability of coming from each state we are looping each STATE
			for (int i = 0; i < numberOfStates; i++) {
				sumOfAllProbabilitiesComingFromPrevious += alpha[i][time-1] * a[i][stateIndexValue];
			}
			
			alpha[stateIndexValue][time] = sumOfAllProbabilitiesComingFromPrevious * b[stateIndexValue][[[observationSequenceArray objectAtIndex:time]intValue]];
		}
	}
	// Calculate forward variable for each time index of ALL States
	else {
		//For each state - Looping for each STATE to calculate the forward variable
		for (int stateIndex = 0; stateIndex < numberOfStates; stateIndex++) {
			//For each observation index (except that the Observation 0) starting from 1 - Looping in TIME
			for (int time = 1; time < [observationSequenceArray count]; time++) {
				sumOfAllProbabilitiesComingFromPrevious = 0.0;
				
				//To sum the probability of coming from each state we are looping each STATE
				for (int i = 0; i < numberOfStates; i++) {
					sumOfAllProbabilitiesComingFromPrevious += alpha[i][time-1] * a[i][stateIndex];
				}
				
				alpha[stateIndex][time] = sumOfAllProbabilitiesComingFromPrevious * b[stateIndex][[[observationSequenceArray objectAtIndex:time]intValue]];
			}
		}
	}
}


-(void)generateBackwardVariableArray:(NSArray*) observationSequenceArray andState:(int)stateIndexValue{
	
	int T = [observationSequenceArray count]; // The time limit
	//The initial condition - for first observation (the 0 index) the forward variable value of state i = PI(i) x B[i][ Observation[0] ]
	for (int i = 0; i < numberOfStates; i++) {
		beta[i][T-1] = 1.0;
	}
	// Calculate backward variable for each time index of given State Index
	if (stateIndexValue>=0) {
		//For each observation index (except that the last Observation -observation at T-) Looping in TIME reverve
		for (int time = T-2; time >= 0; time--) {
			beta[stateIndexValue][time] = 0.0;
			
			//To sum the probability of coming from each state. we are looping each STATE
			for (int i = 0; i < numberOfStates; i++) {
				beta[stateIndexValue][time] += (beta[i][time + 1] * a[stateIndexValue][i] * b[i][[[observationSequenceArray objectAtIndex:(time+1)]intValue]]);
			}
		}
	}
	// Calculate backward variable for each time index of ALL States 
	else {
		//For each state - Looping for each STATE to calculate the forward variable
		for (int stateIndex = 0; stateIndex < numberOfStates; stateIndex++) {
			//For each observation index (except that the last Observation -observation at T-) Looping in TIME reverve
			for (int time = T-2; time >= 0; time--) {
				beta[stateIndex][time] = 0.0;
				
				//To sum the probability of coming from each state. we are looping each STATE
				for (int i = 0; i < numberOfStates; i++) {
					beta[stateIndex][time] += (beta[i][time + 1] * a[stateIndex][i] * b[i][[[observationSequenceArray objectAtIndex:(time+1)]intValue]]);
				}
			}
		}
	}
}

*/

/*
-(void)traingGestureData:(NSArray*)gestureDataArray{
	double** a_new = [self getNewDoubleArray:numberOfStates andSecondDimension:numberOfStates];
	double** b_new = [self getNewDoubleArray:numberOfStates andSecondDimension:numberOfObservation];
	
	// re calculate state change probability a
	for(int i=0; i<numberOfStates; i++) {
		for(int j=0; j<numberOfStates; j++) {	
			double numerator=0;
			double denominator=0;
			
			for(int k=0; k<[gestureDataArray count]; k++) {
				
				NSArray* sequenceArray = [gestureDataArray objectAtIndex:k];
				int sequence[[sequenceArray count]];
				for (int tempIndex = 0; tempIndex<[sequenceArray count]; tempIndex++) {
					sequence[tempIndex] = [[sequenceArray objectAtIndex:tempIndex] intValue];
				}
				
				double** fwd = [self forwardProcedure:sequenceArray];
				double** bwd = [self backwardProcedure:sequenceArray];
				double prob = [self getProbability:sequenceArray];
				
				double numerator_innersum=0;
				double denominator_innersum=0;
				
				
				for(int t=0; t<[sequenceArray count]-1; t++) {
					numerator_innersum += fwd[i][t]*a[i][j]*b[j][sequence[t+1]]*bwd[j][t+1];
					denominator_innersum +=fwd[i][t]*bwd[i][t];
				}
				numerator+=(1/prob)*numerator_innersum;
				denominator+=(1/prob)*denominator_innersum;
			} // k
			
			a_new[i][j] = numerator/denominator;
		} // j
	} // i
	
	// re calculate emission probability b
	for(int i=0; i<numberOfStates; i++) { // States
		for(int j=0; j<numberOfObservation; j++) {	// Observation symboles
			double numerator=0;
			double denominator=0;
			
			for(int k=0; k<[gestureDataArray count]; k++) {
				
				NSArray* sequenceArray = [gestureDataArray objectAtIndex:k];
				int sequence[[sequenceArray count]];
				for (int tempIndex = 0; tempIndex<[sequenceArray count]; tempIndex++) {
					sequence[tempIndex] = [[sequenceArray objectAtIndex:tempIndex] intValue];
				}
				
				
				double** fwd = [self forwardProcedure:sequenceArray];
				double** bwd = [self backwardProcedure:sequenceArray];
				double prob = [self getProbability:sequenceArray];
				
				double numerator_innersum=0;
				double denominator_innersum=0;
				
				
				for(int t=0; t<[sequenceArray count]-1; t++) {
					if(sequence[t]==j) {
						numerator_innersum+=fwd[i][t]*bwd[i][t];
					}
					denominator_innersum+=fwd[i][t]*bwd[i][t];
				}
				numerator+=(1/prob)*numerator_innersum;
				denominator+=(1/prob)*denominator_innersum;
			} // k
			
			b_new[i][j] = numerator/denominator;
		} // j
	} // i
	
	
	a=a_new;
	b=b_new;
	
}
 */

-(void)preprocessData:(NSArray*)oneSequenceDataArray{
    //nothing
}

-(NSString*)toString{
	NSString* returnValue = [NSString stringWithFormat:@"- Model Probability : %g ; \n", modelProbability];
	for (int i=0; i<numberOfStates; i++) {
		returnValue = [returnValue stringByAppendingFormat:@"%d - %g | ",i, pi[i]];
		for (int j=0; j<numberOfStates; j++) {
			returnValue = [returnValue stringByAppendingFormat:@"%g ,",a[i][j]];
		}
		returnValue = [returnValue stringByAppendingString:@"\n"];
	}
	return returnValue;
}



-(void) dealloc{
	
	free(pi);
	
	for(int i = 0; i < numberOfStates; i++)
		free(a[i]);
	free(a);
	
	for(int i = 0; i < numberOfStates; i++)
		free(b[i]);
	free(b);
	
	[super dealloc];
}

@end
