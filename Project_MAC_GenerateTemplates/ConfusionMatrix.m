//
//  ConfusionMatrix.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/5/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "ConfusionMatrix.h"


@implementation ConfusionMatrix

-(id)initWithNumberOfClass:(int)numberOfClassValue{
    self=[super init];
	if (self) {
		
		numberOfClass = numberOfClassValue;
		numberOfClassified = 0;
		numberOfNonClassified = 0;
        
		// allocate memory for confusionMatrix
		if ((confusionMatrix = malloc(numberOfClass * sizeof(int *))) == NULL)
		{
			fprintf(stderr,"Memory allocation error (numberOfClassValue 1)\n");
		}
		else {
			for (int i=0; i < numberOfClass; i++){
				if ((confusionMatrix[i] = malloc(numberOfClass * sizeof(int))) == NULL)
				{
					fprintf(stderr,"Memory allocation error (confusionMatrix 2)\n");
				}
				else {
					for(int j=0; j < numberOfClassValue; j++){
						confusionMatrix[i][j] = 0;
					}
				}
			}
		}
		
	}
	return self;
	
}

-(void)addValue:(int)actualClassIndex andPredictedClassIndes:(int)predictedClassIndex{
	if (confusionMatrix && predictedClassIndex>=0) {
		confusionMatrix[actualClassIndex][predictedClassIndex] += 1;
		numberOfClassified ++;
	}
    else if(predictedClassIndex < 0){
        numberOfNonClassified ++;
    }
	else {
		//do nothing 
		NSLog(@"ERROR - Confusion matrix is NULL");
	}

	
}


-(double)getRecallOfAll{
    int totalElement = 0;
    int totalTP = 0;
    
    for (int i=0; i<numberOfClass; i++) {
        for (int j=0; j<numberOfClass; j++) {
            totalElement += confusionMatrix[i][j];
        }
		totalTP += confusionMatrix[i][i]; // sum all diagonal -> total true positive values
	}
    return 100.0 * (double)totalTP / totalElement;
}

-(double)getRecallOfClass:(int)classIndex{
    double returnValue = 0.0;
	
    double TP=0.0;
    double FN=0.0;
    
    for (int i=0; i<numberOfClass; i++) {
        if (i==classIndex) {
            TP = confusionMatrix[i][i];
        }
        else{
            FN += confusionMatrix[classIndex][i];
        }
	}
	returnValue = 100 * TP / (TP + FN);
    
    return returnValue;
}

-(double)getPrecisionOfClass:(int)classIndex{
    double returnValue = 0.0;
	
    double TP=0.0;
    double FP=0.0;
    
    for (int i=0; i<numberOfClass; i++) {
        if (i==classIndex) {
            TP = confusionMatrix[i][i];
        }
        else{
            FP += confusionMatrix[i][classIndex];
        }
	}
	returnValue = 100 * TP / (TP + FP);
    
    return returnValue;
}

-(NSString*)toString{
	NSString* returnObject = [NSString stringWithFormat:@"Confusion Matrix -> Recall : %g, (non classified : %d, classified: %d ) \n", [self getRecallOfAll], numberOfNonClassified, numberOfClassified];
	for (int i=0; i<numberOfClass; i++) {
		for (int j=0; j<numberOfClass; j++) {
			returnObject = [returnObject stringByAppendingFormat:@"%d,", confusionMatrix[i][j]];
		}
        returnObject = [returnObject stringByAppendingFormat:@" | %d Precision: %g, Recall: %g \n", i+1 , [self getPrecisionOfClass:i], [self getRecallOfClass:i]];
		//returnObject = [returnObject stringByAppendingString:@"\n"];
	}
	
	return returnObject;
}

-(void) dealloc{
	
	free(confusionMatrix);
	[super dealloc];
}

@end
