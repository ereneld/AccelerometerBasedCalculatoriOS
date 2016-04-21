//
//  ModelHMM.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/22/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "ModelHMM.h"

@implementation ModelHMM

-(id)initWithStateNumber:(int)sNumber andObservationNumber:(int)oNumber andMaxIterationNumber:(int)maxIterationValue andDimensionToClassify:(int)dimensionIndex{
	self = [super init];
    if(self)
	{
		numberOfStates = sNumber;
		numberOfObservation = oNumber;
		maxIteration = maxIterationValue;
        dimenstionToClassify = dimensionIndex;
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
		
		[self initialize];
	}
	return self;
}

-(void)initialize{
	//int jumplimit = 2;
	
	/*
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
	*/
	
	// set startup probability
	for(int i=0; i<numberOfStates; i++) {
		pi[i] = 1.0/(double)numberOfStates;
	}
	
	// state change probabilities
	for(int i=0; i<numberOfStates; i++) {
		for(int j=0; j<numberOfStates; j++) {
			a[i][j] = 1.0/(double)numberOfStates;
		}
	}
	
	
	// emission probability & forward & backward variables
	for(int i=0; i<numberOfStates; i++) {
		for(int j=0; j<numberOfObservation; j++) {
			b[i][j] = 1.0/(double)numberOfObservation;
		}
	}
	
}

-(void)traingGestureData:(NSArray*)gestureDataArray{	
    
    numberOfsequences = [gestureDataArray count]; // number of all training observation sequences
    NSMutableArray* gestureSequenceDataArray=[[NSMutableArray alloc]initWithCapacity:numberOfsequences];
    for (NSArray* tempDataArray in gestureDataArray) {
        [gestureSequenceDataArray addObject:[tempDataArray objectAtIndex:dimenstionToClassify]];
    }
    
	observationsequenceLength = [(NSArray*)[gestureSequenceDataArray objectAtIndex:0] count]; // the length of observations
	
	for(int i=0; i<maxIteration; i++) {
		//NSLog(@"iteration %d",i);
		//NSLog(@"A: \n%@", [self toString]);
		//NSLog(@"B: \n%@", [self toStringDoubleArray:b andFirstDimension:numberOfStates andSecondDimension:numberOfStates]);
		
		// gamma[observation sequence index][state index][time index]
		double*** gamma = [self getNewDoubleArray:numberOfsequences andSecondDimension:numberOfStates andThirdDimension:observationsequenceLength]; 
		// xi[observation sequence index][previous state index][next state index][time index]
		double**** xi = [self getNewDoubleArray:numberOfsequences andSecondDimension:numberOfStates andThirdDimension:numberOfStates andFourthDimension:observationsequenceLength]; 
		
		for(int k=0; k<numberOfsequences; k++) {
			NSArray* sequenceArray = [gestureSequenceDataArray objectAtIndex:k];
			
			double** alpha= [self forwardProcedure:sequenceArray]; //alpha[state index][time]
			double** beta= [self backwardProcedure:sequenceArray]; //beta[state index][time]
			
			[self calculateGamma:gamma andAlpha:alpha andBeta:beta andK:k];
			[self calculateXi:xi andAlpha:alpha andBeta:beta andK:k andObservationSequence:sequenceArray];
			
			[self freeArray:alpha andFirstDimension:numberOfStates];
			[self freeArray:beta andFirstDimension:numberOfStates];
		}
		[self calculateNewA:gamma andXi:xi];
		[self calculateNewB:gamma andGestureSequenceData:gestureSequenceDataArray];
		[self calculateNewPI:gamma];
		
		[self freeArray:gamma andFirstDimension:numberOfsequences andSecondDimension:numberOfStates];
		[self freeArray:xi andFirstDimension:numberOfsequences andSecondDimension:numberOfStates andThirdDimension:numberOfStates];
	}
	
	//NSLog(@"A: \n%@", [self toString]);
	//NSLog(@"B: \n%@", [self toStringDoubleArray:b andFirstDimension:numberOfStates andSecondDimension:numberOfStates]);
	[gestureSequenceDataArray release];
    gestureSequenceDataArray = nil;
}

-(void)calculateGamma:(double***)gamma andAlpha:(double**)alpha andBeta:(double**)beta andK:(int)k{
	double tempSum = 0.0;
	for (int time = 0; time < observationsequenceLength; time++) {
		for (int stateIndex = 0; stateIndex < numberOfStates; stateIndex++) {
			tempSum = 0.0;
			for (int i = 0; i < numberOfStates; i++) {
				tempSum += ( alpha[i][time] * beta[i][time]);
			}
			
			if (tempSum!=0.0) {
				gamma[k][stateIndex][time] = (alpha[stateIndex][time] * beta[stateIndex][time]) / tempSum;
			}
			else {
				gamma[k][stateIndex][time] = 0.0;
			}
		}
	}
}

-(void)calculateXi:(double****)xi andAlpha:(double**)alpha andBeta:(double**)beta andK:(int)k andObservationSequence:(NSArray*)sequenceArray{
	double tempSum = 0.0;
	for (int time = 0; time < observationsequenceLength-1; time++) {
		for (int i = 0; i < numberOfStates; i++) {
			for (int j = 0; j < numberOfStates; j++) {
				tempSum = 0.0;
				for (int k = 0; k < numberOfStates; k++) {
					for (int l = 0; l < numberOfStates; l++) {
						tempSum += alpha[k][time] * a[k][l] * b[l][[[sequenceArray objectAtIndex:time+1] intValue]- 1] * beta[l][time+1] ;
					}
				}
				
				if (tempSum!=0.0) {
					xi[k][i][j][time] = (alpha[i][time] * a[i][j] * b[j][[[sequenceArray objectAtIndex:time+1] intValue]- 1] * beta[j][time+1]) / tempSum;
				}
				else {
					xi[k][i][j][time] = 0;
				}	
			}
		}
	}
}

-(void)calculateNewA:(double***)gamma andXi:(double****)xi{
	double sumXi=0.0;
	double sumGamma =0.0;
	for (int i = 0; i < numberOfStates; i++) {
		for (int j = 0; j < numberOfStates; j++) {
			sumXi=0.0;
			sumGamma =0.0;
			for(int k=0;k<numberOfsequences;k++){
				for(int t=0;t<observationsequenceLength;t++){
					sumXi += xi[k][i][j][t];
					sumGamma += gamma[k][i][t];
				}
			}
			if (sumGamma!=0.0) {
				a[i][j]= sumXi/ sumGamma;
			}
			else {
				a[i][j]= 0;
			}

			
		}
	}
	
}

-(void)calculateNewB:(double***)gamma andGestureSequenceData:(NSArray*)gesturesequenceDataArray{
	double sumGammaNumerator =0.0;
	double sumGammaDenominator =0.0;
	for (int j = 0; j < numberOfStates; j++) {
		for(int m=0;m<numberOfObservation;m++){
			sumGammaNumerator =0.0;
			sumGammaDenominator =0.0;
			for(int k=0;k<numberOfsequences;k++){
				for(int t=0;t<observationsequenceLength;t++){
					NSArray* sequenceArray = [gesturesequenceDataArray objectAtIndex:k];
					if (([[sequenceArray objectAtIndex:t] intValue]-1)==m) {
						sumGammaNumerator += gamma[k][j][t];
					}
					sumGammaDenominator += gamma[k][j][t];
				}
			}
			
			if (sumGammaDenominator!=0.0) {
				b[j][m]= sumGammaNumerator/ sumGammaDenominator;
			}
			else {
				b[j][m]= 0;
			}
		}
	}
}


-(void)calculateNewPI:(double***)gamma{
	double sumGammaNumerator =0.0;
	double sumGammaDenominator = observationsequenceLength;
	
	for (int i = 0; i < numberOfStates; i++) {
		sumGammaNumerator =0.0;
		for(int k=0;k<numberOfsequences;k++){
			sumGammaNumerator = gamma[k][i][0];
		}
		
		if (sumGammaDenominator!=0.0) {
			pi[i] = sumGammaNumerator / sumGammaDenominator;
		}
		else {
			pi[i] = 0.0;
		}

	}
	
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
				alpha[i][0] = pi[i] * b[i][[[observationSequenceArray objectAtIndex:0]intValue]- 1];
			}
		}
		else {
			//For each state - Looping for each STATE to calculate the forward variable
			for (int stateIndex = 0; stateIndex < numberOfStates; stateIndex++) {
				sumOfAllProbabilitiesComingFromPrevious = 0.0;
				
				//To sum the probability of coming from each state we are looping each STATE
				for (int i = 0; i < numberOfStates; i++) {
					sumOfAllProbabilitiesComingFromPrevious += alpha[i][time-1] * a[i][stateIndex];
				}
				
				alpha[stateIndex][time] = sumOfAllProbabilitiesComingFromPrevious * b[stateIndex][[[observationSequenceArray objectAtIndex:time]intValue]- 1];
			}
		}
		
		//NSLog(@"Alpha Array: \n%@",[self toStringDoubleArray:alpha andFirstDimension:numberOfStates andSecondDimension:T]);
		
		//Normalization
		ct[time] = 0.0;
		for (int stateIndex = 0; stateIndex < numberOfStates; stateIndex++) {
			ct[time] += alpha[stateIndex][time];
		}
		
		for (int stateIndex = 0; stateIndex < numberOfStates; stateIndex++) {
			//NSLog(@"%d - %g", time, ct[time]);
			if (ct[time]!=0.0) {
				alpha[stateIndex][time] = alpha[stateIndex][time] / ct[time];
			}
			else {
                NSLog(@"time:%d -state:%d - ct[time]:%g", time, stateIndex, ct[time]);
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
        for (int i = 0; i < numberOfStates; i++) {
		
			if (time==T-1) {	// Basisfall
				beta[i][T - 1] = 1;
			}
			else {			// Induktion 
				beta[i][time] = 0;
				for (int j = 0; j < numberOfStates; j++){
					beta[i][time] += (beta[j][time + 1] * a[i][j] * b[j][[[observationSequenceArray objectAtIndex:(time+1)]intValue]- 1]);
				}
			}
        }
        //NSLog(@"Beta Array: \n%@",[self toStringDoubleArray:beta andFirstDimension:numberOfStates andSecondDimension:T]);
        
        //Normalization
        ct[time] = 0.0;
        for (int stateIndex = 0; stateIndex < numberOfStates; stateIndex++) {
            ct[time] += beta[stateIndex][time];
        }
        
        for (int stateIndex = 0; stateIndex < numberOfStates; stateIndex++) {
            //NSLog(@"%d - %g", time, ct[time]);
            if (ct[time]!=0.0) {
                beta[stateIndex][time] = beta[stateIndex][time] / ct[time];
            }
            else {
                NSLog(@"time:%d -state:%d - ct[time]:%g", time, stateIndex, ct[time]);
                beta[stateIndex][time] = 0;
            }
        }
		
	}
	
	return beta;
}

// Returning forward variable array - [State Value Index][Observation Index]
-(double**)forwardProcedureWithoutNormalization:(NSArray*) observationSequenceArray{
	int T = [observationSequenceArray count];
	double** alpha = [self getNewDoubleArray:numberOfStates andSecondDimension:T];
	double sumOfAllProbabilitiesComingFromPrevious = 0.0;

	//For each observation index (except that the Observation 0) starting from 1 - Looping in TIME
	for (int time = 0; time < T; time++) {
		if (time==0) {
			//The initial condition - for first observation (the 0 index) the forward variable value of state i = PI(i) x B[i][ Observation[0] ]
			for (int i = 0; i < numberOfStates; i++) {
				alpha[i][0] = pi[i] * b[i][[[observationSequenceArray objectAtIndex:0]intValue]- 1];
			}
		}
		else {
			//For each state - Looping for each STATE to calculate the forward variable
			for (int stateIndex = 0; stateIndex < numberOfStates; stateIndex++) {
				sumOfAllProbabilitiesComingFromPrevious = 0.0;
				
				//To sum the probability of coming from each state we are looping each STATE
				for (int i = 0; i < numberOfStates; i++) {
					sumOfAllProbabilitiesComingFromPrevious += alpha[i][time-1] * a[i][stateIndex];
				}
				
				alpha[stateIndex][time] = sumOfAllProbabilitiesComingFromPrevious * b[stateIndex][[[observationSequenceArray objectAtIndex:time]intValue]- 1];
			}
		}
	}
	
	return alpha;
}

-(double)getProbability:(NSArray*)oneGestureDataArray{
	double prob = 0.0;
    
    NSMutableArray* oneSequenceArray=[oneGestureDataArray objectAtIndex:dimenstionToClassify];
    
	//double** alpha=[self forwardProcedure:oneSequenceArray];
	double** alpha= [self forwardProcedureWithoutNormalization:oneSequenceArray];
	//	add probabilities
	for (int i = 0; i <numberOfStates; i++) { // for every state
		prob += alpha[i][[oneSequenceArray count] - 1];
	}
    
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


-(NSDictionary*)getConfiguration{
    
    NSMutableDictionary* classifierConfiguration = [[NSMutableDictionary alloc]init];
    
    
    NSNumber* valueModelProbability = [NSNumber numberWithDouble:modelProbability];
    NSNumber* valueDimenstionToClassify = [NSNumber numberWithInt:dimenstionToClassify];
    
    NSMutableArray* arrayPI = [NSMutableArray arrayWithCapacity:numberOfStates];
    for (int i=0; i<numberOfStates; i++) {
        [arrayPI addObject:[NSNumber numberWithDouble:pi[i]]];
    }
    
    NSMutableArray* arrayA = [NSMutableArray arrayWithCapacity:numberOfStates];
    for (int i=0; i<numberOfStates; i++) {
        NSMutableArray* arrayAValues = [NSMutableArray arrayWithCapacity:numberOfStates];
        for (int j=0; j<numberOfStates; j++) {
            [arrayAValues addObject:[NSNumber numberWithDouble:a[i][j]]];
        }
        [arrayA addObject:arrayAValues];
    }

    NSMutableArray* arrayB = [NSMutableArray arrayWithCapacity:numberOfStates];
    for (int i=0; i<numberOfStates; i++) {
        NSMutableArray* arrayBValues = [NSMutableArray arrayWithCapacity:numberOfObservation];
        for (int j=0; j<numberOfObservation; j++) {
            [arrayBValues addObject:[NSNumber numberWithDouble:b[i][j]]];
        }
        [arrayB addObject:arrayBValues];
    }
    
    
    [classifierConfiguration setValue:valueModelProbability forKey:@"valueModelProbability"];
    [classifierConfiguration setValue:valueDimenstionToClassify forKey:@"valueDimenstionToClassify"];
    [classifierConfiguration setValue:arrayPI forKey:@"arrayPI"];
    [classifierConfiguration setValue:arrayA forKey:@"arrayA"];
    [classifierConfiguration setValue:arrayB forKey:@"arrayB"];
    
    return classifierConfiguration;
}

-(void)loadConfiguration:(NSDictionary*)configurationFile{
    
    modelProbability = [[configurationFile objectForKey:@"valueModelProbability"] doubleValue];
    dimenstionToClassify = [[configurationFile objectForKey:@"valueDimenstionToClassify"] intValue];
    
    NSMutableArray* arrayPI = [configurationFile objectForKey:@"arrayPI"];
    NSMutableArray* arrayA = [configurationFile objectForKey:@"arrayA"];
    NSMutableArray* arrayB = [configurationFile objectForKey:@"arrayB"];
    
    for (int i=0; i<numberOfStates; i++) {
        pi[i] = [[arrayPI objectAtIndex:i]doubleValue];
        NSMutableArray* arrayAValues = [arrayA objectAtIndex:i];
        for (int j=0; j<numberOfStates; j++) {
            a[i][j] = [[arrayAValues objectAtIndex:j]doubleValue];
        }
        NSMutableArray* arrayBValues = [arrayB objectAtIndex:i];
        for (int j=0; j<numberOfObservation; j++) {
            b[i][j] = [[arrayBValues objectAtIndex:j]doubleValue];
        }
    }
    
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
