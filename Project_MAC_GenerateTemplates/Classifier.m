//
//  Classifier.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/21/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "Classifier.h"

#import "ConfigurationManager.h"
#import "Constants.h"

#import "ModelHMM.h"
#import "ModelMM.h"
#import "ModelDTW.h"
#import "Model3DHMM.h"
//#include "hmm.hpp"

static NSMutableArray* instanceObjectModelArray; //singleton object -> stores the array of model

//Hidden methods ! -> to use for instance object
@interface Classifier (PrivateMethods)

-(void)initialize;
-(void)traingGestureData:(NSArray*)gestureSequenceDataArray;
-(double)getProbability:(NSArray*)oneSequenceArray;
-(void)preprocessData:(NSArray*)oneSequenceDataArray;

-(NSString*)toString;
-(NSString*)toStringDoubleArray:(double**)array andFirstDimension:(int)firstDimension andSecondDimension:(int)secondDimension;
-(void)setModelProbabilityValue:(NSArray*)gestureSequenceDataArray;

-(NSDictionary*)getConfiguration;
-(void)loadConfiguration:(NSDictionary*)configurationFile;

@end

@implementation Classifier

@synthesize classNumberActual, modelProbability;

+(NSMutableArray*) getClassifierModelArray:(int)numberOfModel{
	
	if(!instanceObjectModelArray){
		switch ((int)[ConfigurationManager getParameterValue:KPN_CLASSIFIER_TYPE]) {
			case ClassifierTypeNONE:
				instanceObjectModelArray = nil;
				break;
			case ClassifierTypeObservableMM:
				instanceObjectModelArray = [[NSMutableArray alloc]initWithCapacity:numberOfModel];
				for (int i= 0; i<numberOfModel; i++) {
					[instanceObjectModelArray addObject:[[ModelMM alloc]
														 initWithStateNumber:[ConfigurationManager getParameterValue:KPN_CLASSIFIER_OBSERVATION_NUMBER]]];
				}
				
				break;
			case ClassifierTypeHMM:
				instanceObjectModelArray = [[NSMutableArray alloc]initWithCapacity:numberOfModel];
				for (int i= 0; i<numberOfModel; i++) {
					[instanceObjectModelArray addObject:[[ModelHMM alloc]
														 initWithStateNumber:[ConfigurationManager getParameterValue:KPN_CLASSIFIER_STATE_NUMBER]
														 andObservationNumber:[ConfigurationManager getParameterValue:KPN_CLASSIFIER_OBSERVATION_NUMBER]
														 andMaxIterationNumber:[ConfigurationManager getParameterValue:KPN_CLASSIFIER_MAX_ITERATION] andDimensionToClassify:4]];
				}
								
				break;
            case ClassifierType3DHMM:
				instanceObjectModelArray = [[NSMutableArray alloc]initWithCapacity:numberOfModel];
				for (int i= 0; i<numberOfModel; i++) {
					[instanceObjectModelArray addObject:[[Model3DHMM alloc]
														 initWithStateNumber:[ConfigurationManager getParameterValue:KPN_CLASSIFIER_STATE_NUMBER]
														 andObservationNumber:[ConfigurationManager getParameterValue:KPN_CLASSIFIER_OBSERVATION_NUMBER]
														 andMaxIterationNumber:[ConfigurationManager getParameterValue:KPN_CLASSIFIER_MAX_ITERATION]]];
				}
                
				break;
			case ClassifierTypeDTW:
                instanceObjectModelArray = [[NSMutableArray alloc]initWithCapacity:numberOfModel];
				for (int i=0; i<numberOfModel; i++) {
					[instanceObjectModelArray addObject:[[ModelDTW alloc]
                                                         initWithSampleSize:[ConfigurationManager getParameterValue:KPN_SAMPLE_SIZE]]];
				}
                
				break;
			default:
				instanceObjectModelArray = nil;
				break;
		}
		
		
		
	}
	return instanceObjectModelArray;
}

+(void) reset{
	[instanceObjectModelArray removeAllObjects];
	[instanceObjectModelArray release];
	instanceObjectModelArray = nil;
}

+(double)getModelProbability:(int)modelIndex{
    double returnValue = 0.0;
    int numberOfModel = [[ConfigurationManager getConfigurationValue:@"numberOfModel"] intValue];
    NSMutableArray* currentModelArray = [Classifier getClassifierModelArray:numberOfModel];
    Classifier* currentModel = [currentModelArray objectAtIndex:modelIndex];
    [currentModel loadConfiguration:[ConfigurationManager getConfiguration:[NSString stringWithFormat:@"%@_%d",KC_CLASSIFIER,modelIndex]]];
    returnValue = currentModel.modelProbability;
    return returnValue;
}
+(double)getSequenceProbability:(GestureData*)currentGestureData andModelIndex:(int)modelIndex{
    double returnValue = 0.0;
    int numberOfModel = [[ConfigurationManager getConfigurationValue:@"numberOfModel"] intValue];
    NSMutableArray* currentModelArray = [Classifier getClassifierModelArray:numberOfModel];
    Classifier* currentModel = [currentModelArray objectAtIndex:modelIndex];
    [currentModel loadConfiguration:[ConfigurationManager getConfiguration:[NSString stringWithFormat:@"%@_%d",KC_CLASSIFIER,modelIndex]]];
    returnValue = [currentModel getProbability:currentGestureData.gestureData];
    return returnValue;
}

+(int)classifyGestureData:(GestureData*)currentGestureData{
    //return arc4random()%20;
    //!!!: bak buraya
    
    int numberOfModel = [[ConfigurationManager getConfigurationValue:@"numberOfModel"] intValue];
    NSMutableArray* currentModelArray = [Classifier getClassifierModelArray:numberOfModel];
	
    double probabilityOfBelongingTheGivenClass = 0.0;
    double probabilityOfSequence = 0.0;
    int maxPossibleClassNumber = -1;
    double tempMinValue = FLT_MIN;
    for (int i=0; i<numberOfModel; i++) {
        Classifier* currentModel = [currentModelArray objectAtIndex:i];
        [currentModel loadConfiguration:[ConfigurationManager getConfiguration:[NSString stringWithFormat:@"%@_%d",KC_CLASSIFIER,i]]];
        //[currentModel preprocessData:currentGestureData.gestureData];
        probabilityOfSequence = [currentModel getProbability:currentGestureData.gestureData];
        //probabilityOfBelongingTheGivenClass = currentModel.modelProbability * probabilityOfSequence;
        probabilityOfBelongingTheGivenClass = probabilityOfSequence;
        
       // NSLog(@"Predicted : %d | P-model: %g , P-sequence: %g , P-result: %g \n",i,currentModel.modelProbability,probabilityOfSequence, probabilityOfBelongingTheGivenClass);
        
        if(i==0 || tempMinValue < probabilityOfBelongingTheGivenClass){
            tempMinValue = probabilityOfBelongingTheGivenClass;
            maxPossibleClassNumber = i;
        }
    }
    
   return maxPossibleClassNumber;
}

+(int)classifyGestureDataWithDTW:(GestureData*)currentGestureData andThresholdControl:(BOOL)thresholdControl{
    
    int numberOfModel = [[ConfigurationManager getConfigurationValue:@"numberOfModel"] intValue];
    NSMutableArray* currentModelArray = [Classifier getClassifierModelArray:numberOfModel];
	
    double distance = 0.0;
    
    int maxPossibleClassNumber = -1;
    double tempMinDistance = FLT_MAX;
    for (int i=0; i<numberOfModel; i++) {
        ModelDTW* currentModel = (ModelDTW*)[currentModelArray objectAtIndex:i];
        [currentModel loadConfiguration:[ConfigurationManager getConfiguration:[NSString stringWithFormat:@"%@_%d",KC_CLASSIFIER,i]]];
       
        distance = [currentModel calculateDTWDistance:currentGestureData.gestureData];
        //distance = [currentModel calculateClassificationDistance:currentGestureData];
        
        if(tempMinDistance > distance && (!thresholdControl || [currentModel isGestureInRange:currentGestureData.gestureData])){
            tempMinDistance = distance;
            maxPossibleClassNumber = i;
        }
        
    }
    
    return maxPossibleClassNumber;
}

+(BOOL)evaluateDTWWithNewWrapWindowSize:(DataSet*)validationDataSet andPreviousBestDistance:(double*)previousBestDistance andPreviousBestTrueClassification:(int*)previousTrueClassification{
     BOOL improvement = NO;
    
    int numberOfModel = [[ConfigurationManager getConfigurationValue:@"numberOfModel"] intValue];
    NSMutableArray* currentModelArray = [Classifier getClassifierModelArray:numberOfModel];
    double bestDistance = FLT_MAX;
    double currentBestDistance = 0.0;
    
    double trueTotalDistance = 0.0;
    double wrongTotalDistance = 0.0;
    int numberOfTrueClassify = 0;
    int numberOfFalseClassify = 0;
    int predictedClassIndex = -1;
    
    double distmetric = 0.0;
    
    ConfusionMatrix* classificationResult = [[ConfusionMatrix alloc]initWithNumberOfClass:numberOfModel];
    for(int actualClassIndex=0;actualClassIndex<numberOfModel;actualClassIndex++){
        NSArray* gestureDataArray = [validationDataSet.gestureDataArray objectAtIndex:actualClassIndex];
        for (GestureData* gestureData in gestureDataArray) {
            bestDistance = FLT_MAX;
            predictedClassIndex = -1;
            //------cheking improvement
            for(int i=0;i<numberOfModel;i++){
                Classifier* currentModel = [currentModelArray objectAtIndex:i];
                
                currentBestDistance = [(ModelDTW*)currentModel calculateLBKeoghDistance:gestureData.gestureData];
                if (currentBestDistance < bestDistance) {
                    currentBestDistance = [(ModelDTW*)currentModel calculateDTWDistance:gestureData.gestureData];
                    if (currentBestDistance < bestDistance) {
                        bestDistance = currentBestDistance; 
                        predictedClassIndex = i;
                    }
                }
            }
            
            [classificationResult addValue:actualClassIndex andPredictedClassIndes:predictedClassIndex];
            Classifier* currentModel = [currentModelArray objectAtIndex:predictedClassIndex];
            if (predictedClassIndex == actualClassIndex) {
                numberOfTrueClassify ++;
                trueTotalDistance += [(ModelDTW*)currentModel calculateDTWDistance:gestureData.gestureData];
            }
            else{
                numberOfFalseClassify++;
                wrongTotalDistance += [(ModelDTW*)currentModel calculateDTWDistance:gestureData.gestureData];
            }
        }
    }
    
    NSLog(@"ClassificationResult : \n%@", [classificationResult toString]);
    [classificationResult release];
    
    distmetric = (trueTotalDistance*numberOfFalseClassify)/(wrongTotalDistance * numberOfTrueClassify);
    
    if (numberOfTrueClassify >= *previousTrueClassification && (distmetric < *previousBestDistance || numberOfTrueClassify >= *previousTrueClassification) ) {
        improvement = YES;
        *previousBestDistance = distmetric;
        *previousTrueClassification = numberOfTrueClassify;
    }
    else{
        improvement = NO;
    }
    
    return improvement;
}

+(void)findBestDTWrapPath:(DataSet*)validationDataSet andModel:(ModelDTW*)currentModel andDimension:(int)dimension andStartPoint:(int)startPoint andEndPoint:(int)endPoint andWrapWindowSize:(int)wrapWindowSize  andPreviousBestDistance:(double*)previousBestDistance andPreviousBestTrueClassification:(int*)previousTrueClassification{
    
    int numberOfElements = [ConfigurationManager getParameterValue:KPN_SAMPLE_SIZE];
    
    
    if (wrapWindowSize < numberOfElements && (endPoint - startPoint) >= 1) {
        
        NSLog(@"Classificationdimension: [%d] WrapingSize: %d - start %d - end %d", dimension, wrapWindowSize, startPoint, endPoint);
        
        int numberOfElementsChange = (endPoint - startPoint+1);
        
        
        int* currentDTWWindowSizeArray = [currentModel getWrapingWindowSize:dimension];
        int* previousDTWWindowSizeArray;
        if ((previousDTWWindowSizeArray = malloc(numberOfElementsChange * sizeof(int))) == NULL)
        {
            fprintf(stderr,"Memory allocation error (returnArray 1)\n");
        }
        else {
            for(int i=0; i < numberOfElementsChange; i++){
                previousDTWWindowSizeArray[i] = currentDTWWindowSizeArray[startPoint+i];
            }
        }
        
        //int currentWindowSize = previousDTWWindowSizeArray[0];
        for (int i=startPoint; i<=endPoint; i++) {
            currentDTWWindowSizeArray[i] = wrapWindowSize;
        }
        
        BOOL improvement = [Classifier evaluateDTWWithNewWrapWindowSize:validationDataSet andPreviousBestDistance:previousBestDistance andPreviousBestTrueClassification:previousTrueClassification];
        
        if (improvement) {
             free(previousDTWWindowSizeArray);
            // we set the new windows size already so we don't need to change anything
            [Classifier findBestDTWrapPath:validationDataSet andModel:currentModel andDimension:dimension andStartPoint:startPoint andEndPoint:endPoint andWrapWindowSize:wrapWindowSize+1 andPreviousBestDistance:previousBestDistance andPreviousBestTrueClassification:previousTrueClassification];
        }
        else{
            // undo the new set value !
            for (int i=0; i< numberOfElementsChange; i++) {
                currentDTWWindowSizeArray[startPoint+i] = previousDTWWindowSizeArray[i];
            }
            
            free(previousDTWWindowSizeArray);
            if (numberOfElementsChange >= 4 ) { 
                // divide and search the improvement
                int middle = (endPoint + startPoint) / 2;
                [Classifier findBestDTWrapPath:validationDataSet andModel:currentModel andDimension:dimension andStartPoint:startPoint andEndPoint:middle andWrapWindowSize:wrapWindowSize andPreviousBestDistance:previousBestDistance andPreviousBestTrueClassification:previousTrueClassification];
                [Classifier findBestDTWrapPath:validationDataSet andModel:currentModel andDimension:dimension andStartPoint:middle+1 andEndPoint:endPoint andWrapWindowSize:wrapWindowSize andPreviousBestDistance:previousBestDistance andPreviousBestTrueClassification:previousTrueClassification];
            }
            else{
                // we reach the minimum for each element
            }
            
        }
       
    }
    else{
        return;
    }
    
}

+(void)findDTWBestWithValidationDataSet:(DataSet*)validationDataSet andNumberOfModel:(int)numberOfModel{
    int numberOfElements = [ConfigurationManager getParameterValue:KPN_SAMPLE_SIZE];
    
     NSMutableArray* currentModelArray = [Classifier getClassifierModelArray:numberOfModel];
    for(int actualClassIndex=0;actualClassIndex<numberOfModel;actualClassIndex++){
        
        ModelDTW* currentModel = (ModelDTW*)[currentModelArray objectAtIndex:actualClassIndex];
        double bestDistance = FLT_MAX;
        int numberOfTrueClassify = 0;
        
        double bestDistanceForEachDimension = FLT_MAX;
        int numberOfTrueClassifyForEachDimension = 0;
        
        for (int dimension=0; dimension<3; dimension++) { //make best for x-y-z and cluster, because we are not using cluster in DTW
            bestDistance = FLT_MAX;
            numberOfTrueClassify = 0;
            
            bestDistanceForEachDimension = FLT_MAX;
            numberOfTrueClassifyForEachDimension = 0;
            int* currentDTWWindowSizeArray = [currentModel getWrapingWindowSize:dimension];
            int* previousDTWWindowSizeArray;
            if ((previousDTWWindowSizeArray = malloc(numberOfElements * sizeof(int))) == NULL)
            {
                fprintf(stderr,"Memory allocation error (returnArray 1)\n");
            }
            else {
                for(int i=0; i < numberOfElements; i++){
                    previousDTWWindowSizeArray[i] = currentDTWWindowSizeArray[i];
                }
            }
            [self evaluateDTWWithNewWrapWindowSize:validationDataSet andPreviousBestDistance:&bestDistanceForEachDimension andPreviousBestTrueClassification:&numberOfTrueClassifyForEachDimension];
            
            NSLog(@"FindBestDTWrapPath of model: %d, dimension:%d ---------- ",actualClassIndex, dimension);
            [Classifier findBestDTWrapPath:validationDataSet andModel:currentModel andDimension:dimension andStartPoint:0 andEndPoint:[ConfigurationManager getParameterValue:KPN_SAMPLE_SIZE]-1 andWrapWindowSize:0 andPreviousBestDistance:&bestDistance andPreviousBestTrueClassification:&numberOfTrueClassify];
            
            BOOL improvement = [self evaluateDTWWithNewWrapWindowSize:validationDataSet andPreviousBestDistance:&bestDistanceForEachDimension andPreviousBestTrueClassification:&numberOfTrueClassifyForEachDimension];
            if (improvement) {
                //do nothing - continue
                 NSLog(@"----------- IMPROVED wrap window sizes of model : %d, dimension:%d",actualClassIndex, dimension);
            }
            else{
                NSLog(@"----------- Undo all wrap values of model : %d, dimension:%d",actualClassIndex, dimension);
                //undo all wrap size operations in dimension 
                for(int i=0; i < numberOfElements; i++){
                    currentDTWWindowSizeArray[i] = previousDTWWindowSizeArray[i];
                }
            }
            /*for (int wrapWindowSize = 0; wrapWindowSize< [ConfigurationManager getParameterValue:KPN_SAMPLE_SIZE]; wrapWindowSize++) {
                
                previousWindowSize = [(ModelDTW*)currentModel getWrapingWindowSize:dimension];
                NSLog(@"Classification Model:%d,  dimension: [%d] WrapingSize: %d;",actualClassIndex, dimension, wrapWindowSize);
                
                [(ModelDTW*)currentModel setWrapingWindowSize:wrapWindowSize andDimension:dimension];
                
                BOOL improvement = [Classifier evaluateDTWWithNewWrapWindowSize:validationDataSet andPreviousBestDistance:&bestDistance andPreviousBestTrueClassification:&numberOfTrueClassify];
                
                if (improvement) {
                    // we set the new windows size already so we don't need to change anything
                }
                else{
                    // undo the new set value !
                    [(ModelDTW*)currentModel setWrapingWindowSize:previousWindowSize andDimension:dimension];
                    break;
                }
            }
             */
        }
        
        //save the best till get memory overflow error :)
        for (int i=0; i<numberOfModel; i++) {
            Classifier* tempCurrentModel = [currentModelArray objectAtIndex:i];
            [ConfigurationManager addConfiguration:[tempCurrentModel getConfiguration] andName:[NSString stringWithFormat:@"%@_%d",KC_CLASSIFIER,i]];
        }
        [ConfigurationManager saveConfigurationList];
        
    }

}

    
+(void)makeDTWBestWithValidationDataSet:(DataSet*)validationDataSet{
    int numberOfModel = [[ConfigurationManager getConfigurationValue:@"numberOfModel"] intValue];
    NSMutableArray* currentModelArray = [Classifier getClassifierModelArray:numberOfModel];
	
    for(int i=0;i<numberOfModel;i++){
        Classifier* currentModel = [currentModelArray objectAtIndex:i];
        [currentModel loadConfiguration:[ConfigurationManager getConfiguration:[NSString stringWithFormat:@"%@_%d",KC_CLASSIFIER,i]]];
         //[(ModelDTW*)currentModel setWrapingWindowSize:0 andDimension:0];
         //[(ModelDTW*)currentModel setWrapingWindowSize:0 andDimension:1];
         //[(ModelDTW*)currentModel setWrapingWindowSize:0 andDimension:2];
    }
    
    int maxIterationForDTW = 3;
    for(int i=0;i < maxIterationForDTW; i++){
        NSLog(@"------------------ ITERATION DTW %d -------------------- ", i);
        [Classifier findDTWBestWithValidationDataSet:validationDataSet andNumberOfModel:numberOfModel];
        
        //save the best till get memory overflow error :)
        for (int i=0; i<numberOfModel; i++) {
            Classifier* currentModel = [currentModelArray objectAtIndex:i];
            [ConfigurationManager addConfiguration:[currentModel getConfiguration] andName:[NSString stringWithFormat:@"%@_%d",KC_CLASSIFIER,i]];
        }
        [ConfigurationManager saveConfigurationList];
    }
        
    
}

+(void)trainingForDTWDistances:(DataSet*)currentDataSet{
    int numberOfModel = [[ConfigurationManager getConfigurationValue:@"numberOfModel"] intValue];
    NSMutableArray* currentModelArray = [Classifier getClassifierModelArray:numberOfModel];
	
    [currentDataSet makeAllDataAsTraining];
    [currentDataSet setupTrainingAndValidationData];
    
    for(int i=0;i<numberOfModel;i++){
         NSArray* trainingGestureDataArray = [currentDataSet.trainingDataArray objectAtIndex:i];
        Classifier* currentModel = [currentModelArray objectAtIndex:i];
        [currentModel loadConfiguration:[ConfigurationManager getConfiguration:[NSString stringWithFormat:@"%@_%d",KC_CLASSIFIER,i]]];
        [(ModelDTW*)currentModel traingDTWDistances:trainingGestureDataArray];
        [ConfigurationManager addConfiguration:[currentModel getConfiguration] andName:[NSString stringWithFormat:@"%@_%d",KC_CLASSIFIER,i]];
    }
    
    //[ConfigurationManager saveConfigurationList];
}


+(void)trainingWithAllDataSet:(DataSet*)currentDataSet{
    
    int numberOfModel = [currentDataSet.gestureDataArray count];
    [ConfigurationManager addConfigurationValue:[NSNumber numberWithInt:numberOfModel] andName:@"numberOfModel"];

	NSMutableArray* currentModelArray = [Classifier getClassifierModelArray:numberOfModel];
	[currentDataSet makeAllDataAsTraining];
    [currentDataSet setupTrainingAndValidationData];
    
    for (int i=0; i<numberOfModel; i++) {
        NSArray* trainingGestureDataArray = [currentDataSet.trainingDataArray objectAtIndex:i];
        Classifier* currentModel = [currentModelArray objectAtIndex:i];
        currentModel.classNumberActual = i;
       
        [currentModel initialize];
        [currentModel loadDTWConfiguration:[ConfigurationManager getConfiguration:[NSString stringWithFormat:@"%@_%d",KC_CLASSIFIER,i]]];
        
        [currentModel traingGestureData:trainingGestureDataArray];
    }
    for (int i=0; i<numberOfModel; i++) {
        NSArray* trainingGestureDataArray = [currentDataSet.trainingDataArray objectAtIndex:i];
        Classifier* currentModel = [currentModelArray objectAtIndex:i];
        [currentModel setModelProbabilityValue:trainingGestureDataArray];
        [ConfigurationManager addConfiguration:[currentModel getConfiguration] andName:[NSString stringWithFormat:@"%@_%d",KC_CLASSIFIER,i]];
    }
}

+(ConfusionMatrix*)classifyHeuristic:(DataSet*)currentDataSet andThresholdControl:(BOOL)thresholdControl;{
    int numberOfModel = [currentDataSet.gestureDataArray count];
    ConfusionMatrix* classificationResult = [[[ConfusionMatrix alloc]initWithNumberOfClass:numberOfModel] autorelease];
    for (int i=0;i< [currentDataSet.gestureDataArray count]; i++) {
        NSArray* gestureDataArray = [currentDataSet.gestureDataArray objectAtIndex:i];
        for (GestureData* gestureData in gestureDataArray) {
            
            //int maxPossibleClassNumber = [Classifier classifyGestureData:gestureData];
            int maxPossibleClassNumber = [Classifier classifyGestureDataWithDTW:gestureData andThresholdControl:thresholdControl];
            
            [classificationResult addValue:i andPredictedClassIndes:maxPossibleClassNumber];
            //NSLog(@"Actual:%d ,Predicted:%d | %@",i,maxPossibleClassNumber, [Classifier getsequenceString:gestureData.gestureData]);
            /*if (i!=maxPossibleClassNumber && maxPossibleClassNumber>=0) {
                NSMutableArray* currentModelArray = [Classifier getClassifierModelArray:numberOfModel];
                
                NSLog(@"Actual: %d, Predicted:%d, %@, \n Actual Gesture :%@",i, maxPossibleClassNumber, [gestureData gestureFullPath], [gestureData getGestureDataInfoString]);
                Classifier* actualModel = [currentModelArray objectAtIndex:i];
                double distanceFromActual = [(ModelDTW*)actualModel calculateDTWDistance:gestureData.gestureData];
                Classifier* predictedModel = [currentModelArray objectAtIndex:maxPossibleClassNumber];
                double distanceFromPredicted = [(ModelDTW*)predictedModel calculateDTWDistance:gestureData.gestureData];
                
                for (int j=0; j<numberOfModel; j++) {
                    Classifier* currentModel = [currentModelArray objectAtIndex:j];
                    double tempDistance = [(ModelDTW*)currentModel calculateDTWDistance:gestureData.gestureData];
                    if (fabs(tempDistance-distanceFromActual) <= fabs(distanceFromPredicted-distanceFromActual)) {
                        NSLog(@"DTW Distance From %d : %g - %@", j, [(ModelDTW*)currentModel calculateDTWDistance:gestureData.gestureData], [(ModelDTW*)currentModel getShortString:gestureData.gestureData]);
                    }
                    
                }
            }
             */
             
             
        }
    }
    
    return classificationResult;
}

+(ConfusionMatrix*)classifyDataSet:(DataSet*)currentDataSet{
	
	int numberOfModel = [currentDataSet.gestureDataArray count];
	NSMutableArray* currentModelArray = [Classifier getClassifierModelArray:numberOfModel];
	ConfusionMatrix* classificationResult = [[[ConfusionMatrix alloc]initWithNumberOfClass:numberOfModel] autorelease];
	
	
	if(currentModelArray && [currentModelArray count]==numberOfModel){
		
		do{
			[CrossValidator determineTrainingAndValidationSet:currentDataSet];
			[currentDataSet setupTrainingAndValidationData];
			
			for (int i=0; i<numberOfModel; i++) {
				NSArray* trainingGestureDataArray = [currentDataSet.trainingDataArray objectAtIndex:i];
				Classifier* currentModel = [currentModelArray objectAtIndex:i];
				currentModel.classNumberActual = i;
				[currentModel initialize];
				[currentModel traingGestureData:trainingGestureDataArray];
				//NSLog(@"Model Number : %d , %@", i, [currentModel toString]);
			}
            for (int i=0; i<numberOfModel; i++) {
				NSArray* trainingGestureDataArray = [currentDataSet.trainingDataArray objectAtIndex:i];
				Classifier* currentModel = [currentModelArray objectAtIndex:i];
				[currentModel setModelProbabilityValue:trainingGestureDataArray];
                [ConfigurationManager addConfiguration:[currentModel getConfiguration] andName:[NSString stringWithFormat:@"%@_%d",KC_CLASSIFIER,i]];
			}
            
			//!!: Here training and validation array should be same size according to number of classes
			double probabilityOfBelongingTheGivenClass = 0.0;
			double probabilityOfSequence = 0.0;
			int maxPossibleClassNumber = -1;
			double tempMinValue = FLT_MIN;
			
			for (int i=0; i<numberOfModel; i++) {
				// the actual class is the i and we are making prediction
				NSArray* validationGestureDataArray = [currentDataSet.validationDataArray objectAtIndex:i];
				for (NSArray* validationGestureData in validationGestureDataArray) {
					//NSLog([Classifier getsequenceString:validationSequenceArray]);
					
					probabilityOfBelongingTheGivenClass = 0.0;
					probabilityOfSequence = 0.0;
					maxPossibleClassNumber = -1;
					tempMinValue = FLT_MIN;
					for (int j=0; j<numberOfModel; j++) {
						Classifier* currentModel = [currentModelArray objectAtIndex:j];
                        //[currentModel preprocessData:validationSequenceArray];
						probabilityOfSequence = [currentModel getProbability:validationGestureData];
						probabilityOfBelongingTheGivenClass = currentModel.modelProbability * probabilityOfSequence;
						//NSLog(@"Actual : %d , Predicted : %d | P-model: %g , P-sequence: %g , P-result: %g \n",i,j,currentModel.modelProbability,probabilityOfSequence, probabilityOfBelongingTheGivenClass);
						if(j==0 || tempMinValue < probabilityOfBelongingTheGivenClass){
							tempMinValue = probabilityOfBelongingTheGivenClass;
							maxPossibleClassNumber = j;
						}
					}
					//NSLog(@"Actual:%d ,Predicted:%d | %@",i,maxPossibleClassNumber, [Classifier getsequenceString:validationSequenceArray]);
					[classificationResult addValue:i andPredictedClassIndes:maxPossibleClassNumber];
				}
			}
			//NSLog(@"classificationResult : %@",[classificationResult toString]);
		}while ([CrossValidator hasNextValidation]);
		
		
		[currentDataSet.operationsequenceArray addObject:K_OPERATION_CLASSIFICATION];
	}
	else {
		[currentDataSet.operationsequenceArray addObject:K_OPERATION_NONCLASSIFICATION];
	}
	
	
	[CrossValidator reset];
	[Classifier reset];
	
	return classificationResult;

}

+(NSString*)getsequenceString:(NSArray*)sequenceDataArray{
	NSString* returnValue = @"The sequence is ";
    for (NSArray* sequenceArray in sequenceDataArray) {
        for (NSNumber* sequenceItem in sequenceArray) {
            returnValue = [returnValue stringByAppendingFormat:@"%g, ",[sequenceItem doubleValue] ];
        }
        returnValue = [returnValue stringByAppendingString:@"\n"];
    }
	
	return returnValue;
}

-(void)setModelProbabilityValue:(NSArray*)gestureSequenceDataArray{
	modelProbability = 0.0;
	for (NSArray* tempGestureData in gestureSequenceDataArray) {
		modelProbability += [self getProbability:tempGestureData];
	}
	modelProbability = modelProbability / [gestureSequenceDataArray count];
}

-(void)preprocessData:(NSArray*)oneSequenceDataArray{
    //nothing
}


-(double****)getNewDoubleArray:(int)firstDimension andSecondDimension:(int)secondDimension andThirdDimension:(int)thirdDimension andFourthDimension:(int)fourthDimension{
	double**** returnArray;
	if ((returnArray = malloc(firstDimension * sizeof(double ***))) == NULL)
	{
		fprintf(stderr,"Memory allocation error (returnArray 1)\n");
	}
	else {
		for (int i=0; i < firstDimension; i++){
			if ((returnArray[i] = malloc(secondDimension * sizeof(double**))) == NULL)
			{
				fprintf(stderr,"Memory allocation error (returnArray 2)\n");
			}
			else {
				for(int j=0; j < secondDimension; j++){
					if ((returnArray[i][j] = malloc(thirdDimension * sizeof(double*))) == NULL)
					{
						fprintf(stderr,"Memory allocation error (returnArray 3)\n");
					}
					else {
						for(int k=0; k < thirdDimension; k++){
							if ((returnArray[i][j][k] = malloc(fourthDimension * sizeof(double))) == NULL)
							{
								fprintf(stderr,"Memory allocation error (returnArray 4)\n");
							}
							else {
								for(int l=0; l < fourthDimension; l++){
									returnArray[i][j][k][l] = 0.0;
								}
							}
						}
					}
				}
			}
		}
	}
	return returnArray;
}


-(double***)getNewDoubleArray:(int)firstDimension andSecondDimension:(int)secondDimension andThirdDimension:(int)thirdDimension{
	
	double*** returnArray;
	if ((returnArray = malloc(firstDimension * sizeof(double **))) == NULL)
	{
		fprintf(stderr,"Memory allocation error (returnArray 1)\n");
	}
	else {
		for (int i=0; i < firstDimension; i++){
			if ((returnArray[i] = malloc(secondDimension * sizeof(double*))) == NULL)
			{
				fprintf(stderr,"Memory allocation error (returnArray 2)\n");
			}
			else {
				for(int j=0; j < secondDimension; j++){
					if ((returnArray[i][j] = malloc(thirdDimension * sizeof(double))) == NULL)
					{
						fprintf(stderr,"Memory allocation error (returnArray 3)\n");
					}
					else {
						for(int k=0; k < thirdDimension; k++){
							returnArray[i][j][k] = 0.0;
						}
					}
				}
			}
		}
	}
	return returnArray;
}

-(double**)getNewDoubleArray:(int)firstDimension andSecondDimension:(int)secondDimension{
	
	double** returnArray;
	if ((returnArray = malloc(firstDimension * sizeof(double *))) == NULL)
	{
		fprintf(stderr,"Memory allocation error (returnArray 1)\n");
	}
	else {
		for (int i=0; i < firstDimension; i++){
			if ((returnArray[i] = malloc(secondDimension * sizeof(double))) == NULL)
			{
				fprintf(stderr,"Memory allocation error (returnArray 2)\n");
			}
			else {
				for(int j=0; j < secondDimension; j++){
					returnArray[i][j] = 0.0;
				}
			}
		}
	}
	return returnArray;
}

-(int**)getNewIntegerArray:(int)firstDimension andSecondDimension:(int)secondDimension{
	
	int** returnArray;
	if ((returnArray = malloc(firstDimension * sizeof(int *))) == NULL)
	{
		fprintf(stderr,"Memory allocation error (returnArray 1)\n");
	}
	else {
		for (int i=0; i < firstDimension; i++){
			if ((returnArray[i] = malloc(secondDimension * sizeof(int))) == NULL)
			{
				fprintf(stderr,"Memory allocation error (returnArray 2)\n");
			}
			else {
				for(int j=0; j < secondDimension; j++){
					returnArray[i][j] = 0;
				}
			}
		}
	}
	return returnArray;
}

-(double*)getNewDoubleArray:(int)firstDimension{
	
	double* returnArray;
	if ((returnArray = malloc(firstDimension * sizeof(double))) == NULL)
	{
		fprintf(stderr,"Memory allocation error (returnArray 1)\n");
	}
	else {
		for(int i=0; i < firstDimension; i++){
			returnArray[i] = 0.0;
		}
	}
	return returnArray;
}

-(int*)getNewIntegerArray:(int)firstDimension{
	
	int* returnArray;
	if ((returnArray = malloc(firstDimension * sizeof(int))) == NULL)
	{
		fprintf(stderr,"Memory allocation error (returnArray 1)\n");
	}
	else {
		for(int i=0; i < firstDimension; i++){
			returnArray[i] = 0;
		}
	}
	return returnArray;
}

-(void)freeArray:(double****)array andFirstDimension:(int)firstDimension andSecondDimension:(int)secondDimension andThirdDimension:(int)thirdDimension{
	for (int i=0; i<firstDimension; i++) {
		for(int j = 0; j<secondDimension; j++){
			for(int k = 0; k<thirdDimension; k++){
				free(array[i][j][k]);
			}			
			free(array[i][j]);
		}
		free(array[i]);
	}
	free(array);
}

-(void)freeArray:(double***)array andFirstDimension:(int)firstDimension andSecondDimension:(int)secondDimension{
	for (int i=0; i<firstDimension; i++) {
		for(int j = 0; j < secondDimension; j++){
			free(array[i][j]);
		}
		free(array[i]);
	}
	free(array);
}

-(void)freeArray:(double**)array andFirstDimension:(int)firstDimension{
	for(int i = 0; i < firstDimension; i++)
		free(array[i]);
	free(array);
}

-(void)freeIntArray:(int**)array andFirstDimension:(int)firstDimension{
	for(int i = 0; i < firstDimension; i++)
		free(array[i]);
	free(array);
}


-(NSString*)toStringDoubleArray:(double**)array andFirstDimension:(int)firstDimension andSecondDimension:(int)secondDimension{
	
	NSString* returnValue = @"";
	for (int i=0; i<firstDimension; i++) {
		returnValue = [returnValue stringByAppendingFormat:@"%d - | ",i];
		for (int j=0; j<secondDimension; j++) {
			returnValue = [returnValue stringByAppendingFormat:@"%g ,",array[i][j]];
		}
		returnValue = [returnValue stringByAppendingString:@"\n"];
	}
	return returnValue;
}

/*
+(void)testHMM{
	Hmm hmm;
	hmm.loadProbs("phone");
	
	//Generates sequence
	std::ostream* fp;
	hmm.genSeqs(*fp, 4);
	
	//
	
	hmm.loadProbs("phone-init1");
	//const char* output = "phone-result1";
	//ifstream istrm("deneme");
	int maxIterations = 10;
	
	//phone.train 
	
	vector<vector<unsigned long>*> trainingSequences;
	//hmm.readSeqs(istrm, trainingSequences);
	//hmm.baumWelch(trainingSequences, maxIterations);
	//zhmm.saveProbs(output);
}
*/
/*
+(void)testHMM{
	int N = 2;
	int M = 3;
	int K = 3;
	/*
	 http://en.wikipedia.org/wiki/Viterbi_algorithm
	 states = ('Rainy', 'Sunny')
	 observations = ('walk', 'shop', 'clean')
	 
	 start_probability = {'Rainy': 0.6, 'Sunny': 0.4}
	 
	 transition_probability = {
	 'Rainy' : {'Rainy': 0.7, 'Sunny': 0.3},
	 'Sunny' : {'Rainy': 0.4, 'Sunny': 0.6},
	 }
	 
	 emission_probability = {
	 'Rainy' : {'walk': 0.1, 'shop': 0.4, 'clean': 0.5},
	 'Sunny' : {'walk': 0.6, 'shop': 0.3, 'clean': 0.1},
	 }
	 
	FArr1D P0(N);
	P0(1) = 0.6;
	P0(2) = 0.4;
	
	FArr2D A(N,N);
	A(1,1) = 0.7; A(1,2) = 0.3;
	A(2,1) = 0.4; A(2,2) = 0.6;
	
	FArr2D B(N,M);
	B(1,1) = 0.1; B(1,2) = 0.4; B(1,3) = 0.5;
	B(2,1) = 0.6; B(2,2) = 0.3; B(2,3) = 0.1;
	
	// ('walk', 'shop', 'clean')
	IArr1D Idxs(K);
	Idxs(1) = 1; Idxs(2) = 2; Idxs(3) = 3;
	
	HMM * hmm = new HMM(A, B, P0);
	Label1->Caption = "Forward: "+FloatToStr(hmm->GetProbabilityF(Idxs));
	Label2->Caption = "Backward: "+FloatToStr(hmm->GetProbabilityB(Idxs));
	
	IArr1D S = hmm->ViterbiStateIdxs(Idxs);
	AnsiString ss = "Viterbi States: ";
	for (int i = S.L1(); i <= S.H1(); i++)
		ss += IntToStr(S(i)) +",";
	Label3->Caption = ss;
	//Output:  ("Sunny", "Rainy", "Rainy")
	
	S = hmm->PosteriorDecodingIdxs(Idxs);
	ss = "Posterior States: ";
	for (int i = S.L1(); i <= S.H1(); i++)
		ss += IntToStr(S(i)) +",";
	Label5->Caption = ss;
	
	delete hmm;
	
	
}
+(void)testHMM:(DataSet*)currentDataSet{
	int numberOfModel = [currentDataSet.trainingSequenceDataArray count];
	NSMutableArray* currentModelArray = [Classifier getClassifierModelArray:numberOfModel];
	
	if(currentModelArray && [currentModelArray count]==numberOfModel){
		for (int i=0; i<numberOfModel; i=i+4) {
			NSArray* trainingGestureDataArray = [currentDataSet.sequenceDataArray objectAtIndex:i];
			Classifier* currentModel = [currentModelArray objectAtIndex:i];
			currentModel.classNumberActual = i;
			[currentModel traingGestureData:trainingGestureDataArray];
			[currentModel setModelProbabilityValue:trainingGestureDataArray];
			NSLog(@"Training finish for Class : %d", i);
		}
		
		int tempDataNumber = 0;
		for (int testClassIndex = 0; testClassIndex < numberOfModel; testClassIndex++) {
			tempDataNumber = arc4random() % 10;
			NSArray* validationsequenceDataArray = [(NSArray*)[currentDataSet.sequenceDataArray objectAtIndex:testClassIndex] objectAtIndex:tempDataNumber];
			for (int i=0; i<numberOfModel; i++) {
				Classifier* currentModel = [currentModelArray objectAtIndex:i];
				double probability = 	currentModel.modelProbability * [currentModel getProbability:validationsequenceDataArray]; 
				NSLog(@"actual: class = %d and data= %d  , predicted: model = %d , prob: %g",testClassIndex, tempDataNumber, i, probability);
			}
		}
		
	}
}
*/
@end
