//
//  ModelPreciseHMM.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/24/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "ModelPreciseHMM.h"


@implementation ModelPreciseHMM

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
				
				double* scalingFactor = [self calculateScalingFactor:sequenceArray];
				double** alpha= [self scaledForwardProcedure:sequenceArray];
				double** beta= [self scaledBackwardProcedure:sequenceArray andScalingFactor:scalingFactor];
				
				double numerator_innersum=0;
				double denominator_innersum=0;
				
				for(int t=0; t<[sequenceArray count]-1; t++) {
					numerator_innersum += alpha[i][t]*a[i][j]*b[j][[[sequenceArray objectAtIndex:t+1] intValue]-1]*beta[j][t+1]*scalingFactor[t+1];
					denominator_innersum += alpha[i][t]*beta[i][t];
				}
				
				numerator += numerator_innersum;
				denominator += denominator_innersum;
				
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
				
				double* scalingFactor = [self calculateScalingFactor:sequenceArray];
				double** alpha= [self forwardProcedure:sequenceArray];
				double** beta= [self scaledBackwardProcedure:sequenceArray andScalingFactor:scalingFactor];
				
				double numerator_innersum=0;
				double denominator_innersum=0;
				
				
				for(int t=0; t<[sequenceArray count]-1; t++) {
					if([[sequenceArray objectAtIndex:t] intValue] ==j) {
						numerator_innersum+=alpha[i][t]*beta[i][t]*scalingFactor[t];
					}
					denominator_innersum+=alpha[i][t]*beta[i][t]*scalingFactor[t];
				}
				numerator+= numerator_innersum;
				denominator+=denominator_innersum;
				
			} // k
			
			if (denominator!=0) {
				b_new[i][j] = numerator/denominator;
			}
			else {
				b_new[i][j] = 0;
			}
			
		} // j
	} // i
	
	a=a_new;
	b=b_new;
	
    [gestureSequenceDataArray release];
    gestureSequenceDataArray = nil;
}

-(double*)calculateScalingFactor:(NSArray*) observationSequence{
	int T = [observationSequence count];
	// for all indexing: [state][time]
	double** fwd = [self forwardProcedure:observationSequence]; // normal
	double** help = [self getNewDoubleArray:numberOfStates andSecondDimension:T];
	double** scaled =[self getNewDoubleArray:numberOfStates andSecondDimension:T];
	double* sf = [self getNewDoubleArray:T];
	
	// ************** BASIS *************
	// Basis, fixed t=0
	// setup, because needed for further calculations
	for(int i=0; i<numberOfStates; i++) {
		help[i][0] = fwd[i][0];
	}
	
	// setup initial scaled array
	double sum0 = 0;
	for(int i=0; i<numberOfStates; i++) {
		sum0+=help[i][0];
	}
	
	for(int i=0; i<numberOfStates; i++) {
		if (sum0!=0) {
			scaled[i][0] = help[i][0] / sum0;
		}
		else {
			scaled[i][0] = 0;
		}

		
	}
	
	// calculate scaling factor
	if (sum0!=0) {
		sf[0] = 1/sum0;
	}
	else {
		sf[0] = 0;
	}
	// **************** INDUCTION ***************
	// end of fixed t = 0
	// starting with t>1 to sequence.length
	// induction, further calculations
	for(int time=1; time<T; time++) {
		// calculate help
		for(int i=0; i<numberOfStates; i++) {
			for(int j=0; j<numberOfStates; j++) {
				help[i][time]+=scaled[j][time-1]*a[j][i]*b[i][[[observationSequence objectAtIndex:time]intValue]-1];
			}
		}
		
		double sum = 0;
		for(int i=0; i<numberOfStates; i++) {
			sum+=help[i][time];
		}
		
		for(int i=0; i<numberOfStates; i++) {
			if (sum!=0) {
				scaled[i][time] = help[i][time] / sum;
			}
			else {
				scaled[i][time] = 0;
			}
		}
		
		// calculate scaling factor
		if (sum!=0) {
			sf[time] = 1 / sum;
		}
		else {
			sf[time] = 0;
		}
		
	} // t
	
	return sf;
	
}


// Returning forward variable array - [State Value Index][Observation Index]
-(double**)scaledForwardProcedure:(NSArray*) observationSequence{
	int T = [observationSequence count];
	double** alpha = [self forwardProcedure:observationSequence];
	double** outAlpha = [self getNewDoubleArray:numberOfStates andSecondDimension:T];
	double sumOfAllProbabilitiesComingFromPrevious = 0.0;
	
	//For each state - Looping for each STATE to calculate the forward variable
	for (int stateIndex = 0; stateIndex < numberOfStates; stateIndex++) {
		//For each observation index (except that the Observation 0) starting from 1 - Looping in TIME
		for (int time = 0; time < T; time++) {
			sumOfAllProbabilitiesComingFromPrevious = 0.0;
			
			//To sum the probability of coming from each state we are looping each STATE
			for (int i = 0; i < numberOfStates; i++) {
				sumOfAllProbabilitiesComingFromPrevious += alpha[i][time];
			}
			
			if (sumOfAllProbabilitiesComingFromPrevious!=0) {
				outAlpha[stateIndex][time] = alpha[stateIndex][time] / sumOfAllProbabilitiesComingFromPrevious;
			}
			else {
				outAlpha[stateIndex][time] = 0;
			}

			
		}
	}
	return outAlpha;
}


// Returning backward variable array - [State Value Index][Observation Index]
-(double**)scaledBackwardProcedure:(NSArray*) observationSequence andScalingFactor:(double*)scalingFactor{
	int T = [observationSequence count];
	double** beta = [self backwardProcedure:observationSequence];
	double** outBeta = [self getNewDoubleArray:numberOfStates andSecondDimension:T];
	
	// Induktion 
	for (int time = 0; time < T; time++) {
		for (int i = 0; i < numberOfStates; i++) {
			outBeta[i][time] = 1;
			for (int j = time+1; j < numberOfStates; j++)
				outBeta[i][time] *= scalingFactor[j]*beta[i][time];
		}
	}
	return outBeta;
}

-(void)preprocessData:(NSArray*)oneSequenceDataArray{
    //nothing
}

-(double)getProbability:(NSArray*)gestureDataArray{

    int numberOfsequences = [gestureDataArray count]; // number of all training observation sequences
    NSMutableArray* observationSequence=[[NSMutableArray alloc]initWithCapacity:numberOfsequences];
    for (NSArray* tempDataArray in gestureDataArray) {
        [observationSequence addObject:[tempDataArray objectAtIndex:4]];
    }

    
	int T = [observationSequence count];
	double** phi = [self getNewDoubleArray:numberOfStates andSecondDimension:T]; //phi[states][oseq]
	// init
	for(int i=0; i<numberOfStates; i++) {
		phi[i][0] = log(pi[i]) + log(b[i][[[observationSequence objectAtIndex:0]intValue]-1]);
	}
	
	// induction
	for(int time=1; time<T; time++) {
		for(int j=0; j<numberOfStates; j++) {
			double max = FLT_MIN;
			for(int i=0; i<numberOfStates; i++) {
				double val = phi[i][time-1] + log(a[i][j]);
				if(val>max) {
					max = val;
				}
			}			
			
			phi[j][time] = max + log(b[j][[[observationSequence objectAtIndex:time] intValue]-1]);
		}
	}
	// conclusion
	double lp = FLT_MIN;
	for(int i=0; i< numberOfStates; i++) {
		if(phi[i][T-1]>lp) {
			lp = phi[i][T-1];
		}
	}
	
    [observationSequence release];
	return exp(lp);
}


@end
