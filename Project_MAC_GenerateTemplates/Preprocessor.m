//
//  Preprocessor.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 4/5/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "Preprocessor.h"


static Preprocessor* instanceObjectPreprocessor; //singleton object

@implementation Preprocessor

@synthesize meanString, varianceString;

+(void)preprocessTrainingDataSet:(DataSet*)currentDataSet{
    if (!instanceObjectPreprocessor) {
		instanceObjectPreprocessor = [[Preprocessor alloc]init];
        instanceObjectPreprocessor.meanString = @"";
        instanceObjectPreprocessor.varianceString = @"";
	}
    for (NSArray* gestureDataArray in currentDataSet.gestureDataArray) {
        [instanceObjectPreprocessor makeSameMean:gestureDataArray];
        [instanceObjectPreprocessor makeSameVariance:gestureDataArray];
    }
    
    NSError* error;
    [instanceObjectPreprocessor.meanString writeToFile:[[K_PATH_GESTUREDATASET stringByAppendingString:@"CorrectedData/"] stringByAppendingString:@"AVERAGE_MEAN.txt"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
     [instanceObjectPreprocessor.varianceString writeToFile:[[K_PATH_GESTUREDATASET stringByAppendingString:@"CorrectedData/"] stringByAppendingString:@"AVERAGE_VARIANCE.txt"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    
}
+(void)preprocessTrainingDataSet:(DataSet*)currentDataSet andMakeSameMean:(BOOL)makeSameMean andMakeSameVariance:(BOOL)makeSameVariance{
    if (!instanceObjectPreprocessor) {
		instanceObjectPreprocessor = [[Preprocessor alloc]init];
        instanceObjectPreprocessor.meanString = @"";
        instanceObjectPreprocessor.varianceString = @"";
	}
    for (NSArray* gestureDataArray in currentDataSet.gestureDataArray) {
        if (makeSameMean) {
            [instanceObjectPreprocessor makeSameMean:gestureDataArray];
        }
        if (makeSameVariance) {
            [instanceObjectPreprocessor makeSameVariance:gestureDataArray];
        }
    }
    
    NSError* error;
    [instanceObjectPreprocessor.meanString writeToFile:[[K_PATH_GESTUREDATASET stringByAppendingString:@"CorrectedData/"] stringByAppendingString:@"AVERAGE_MEAN.txt"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [instanceObjectPreprocessor.varianceString writeToFile:[[K_PATH_GESTUREDATASET stringByAppendingString:@"CorrectedData/"] stringByAppendingString:@"AVERAGE_VARIANCE.txt"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

+(void)postProcessTrainingDataSet:(DataSet*)currentDataSet{
    int i=0;
    for (NSArray* gestureDataArray in currentDataSet.gestureDataArray) {
      
        double** arrayMean = [instanceObjectPreprocessor getMean:gestureDataArray];
        if (arrayMean) {
            for(GestureData* gestureData in gestureDataArray){
                [instanceObjectPreprocessor makeDTW:gestureData.gestureData andTemplate:arrayMean]; // First Change according to mean
                //double** arrayMean2 = [instanceObjectPreprocessor getMean:gestureDataArray];
                //[instanceObjectPreprocessor makeDTW:gestureData.gestureData andTemplate:arrayMean2]; // Second change according to mean after first change
                //free(arrayMean2);
            }
            
           NSString* meanString= @"";
            for (int i=0; i<(int)[ConfigurationManager getParameterValue:KPN_SAMPLE_SIZE]; i++) {
                meanString = [meanString stringByAppendingFormat:@"%g,%g,%g,%g\n",arrayMean[0][i],arrayMean[1][i],arrayMean[2][i],arrayMean[3][i]];
            }
            NSError* error;
            [meanString writeToFile:[[K_PATH_GESTUREDATASET stringByAppendingString:@"CorrectedData/"] stringByAppendingFormat:@"MEAN_%d.txt",i+1] atomically:YES encoding:NSUTF8StringEncoding error:&error];
            i++;
            
             free(arrayMean);
        }
        else{
            NSLog(@"Error - nul pointer exception");
        }
    }
   
}

-(void)freeArray:(double**)array andFirstDimension:(int)firstDimension{
	for(int i = 0; i < firstDimension; i++)
		free(array[i]);
	free(array);
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

-(int*)getNewIntArray:(int)firstDimension{
	
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

-(double**)getMean:(NSArray*)gestureDataArray{
    double** meanArray = nil;

    if (gestureDataArray && [gestureDataArray objectAtIndex:0]) {
        meanArray = [self getNewDoubleArray:4 andSecondDimension:[ConfigurationManager getParameterValue:KPN_SAMPLE_SIZE]];
        for(GestureData* gestureData in gestureDataArray){
            NSArray* dataArray = gestureData.gestureData;
            NSArray* tArray = [dataArray objectAtIndex:0];
            NSArray* xArray = [dataArray objectAtIndex:1];
            NSArray* yArray = [dataArray objectAtIndex:2];
            NSArray* zArray = [dataArray objectAtIndex:3];
            NSArray* cArray = [dataArray objectAtIndex:4];
            for (int i=0; i<[tArray count]; i++) {
                meanArray[0][i] += [[xArray objectAtIndex:i] doubleValue] / [gestureDataArray count];    //x mean
                meanArray[1][i] += [[yArray objectAtIndex:i] doubleValue] / [gestureDataArray count];    //y mean
                meanArray[2][i] += [[zArray objectAtIndex:i] doubleValue] / [gestureDataArray count];    //z mean
                meanArray[3][i] += [[cArray objectAtIndex:i] doubleValue] / [gestureDataArray count];    //c mean
            }
        }
    }
    return meanArray;
	
}

-(void)makeDTWOneSequence:(NSMutableArray*)oneSequenceArray andTemplate:(double*)templateArray{
    int numberOfElements = [ConfigurationManager getParameterValue:KPN_SAMPLE_SIZE];
    double** distanceArray = [self getNewDoubleArray:numberOfElements andSecondDimension:numberOfElements];
    double cost = 0.0;
    
    for(int i=1;i<numberOfElements;i++){
        distanceArray[0][i] = MAXFLOAT;
    }
    for (int i=1; i<numberOfElements; i++) {
        distanceArray[i][0] = MAXFLOAT;
    }
    
    distanceArray[0][0] = 0.0;
    
    for (int i=1; i<[oneSequenceArray count]; i++) {
        for(int j=1;j<numberOfElements;j++){
            cost = fabs([[oneSequenceArray objectAtIndex:i] doubleValue]-templateArray[j]);
            distanceArray[i][j] = cost + MIN( MIN(distanceArray[i-1][j], distanceArray[i][j-1]), distanceArray[i-1][j-1]);
        }
    }
    
    int* timePath = [self getNewIntArray:numberOfElements*20];
    for(int i=0;i<numberOfElements*2;i++){
        timePath[i]= INT_MIN;
    }
    int xIndex = numberOfElements-1; int yIndex = numberOfElements-1;
    //For finding minimum path and calculate the time shift on horizontally ! 
    for (int i=numberOfElements*2-1; (xIndex!=0 && yIndex!=0 ); i--) {
        
        double valueFromPrevious = MIN( MIN(distanceArray[xIndex-1][yIndex], distanceArray[xIndex][yIndex-1]), distanceArray[xIndex-1][yIndex-1]);
       
        if(valueFromPrevious == distanceArray[xIndex-1][yIndex-1]){
            timePath[i] = 0;
            xIndex--;
            yIndex--;
        }
        else if(valueFromPrevious == distanceArray[xIndex][yIndex-1]){
            timePath[i] = -1; //horizontal
            yIndex--;
        }
        else{
            timePath[i] = +1;  //vertical
            xIndex--;
        }
    }
    
    
    
   /* NSString* logString = @"";
    for (NSNumber* numberValue in oneSequenceArray) {
        logString = [logString stringByAppendingFormat:@"%g,", [numberValue doubleValue]];
    }
     logString = [logString stringByAppendingString:@"\n Path:"];
    for (int i=0; i<numberOfElements*2; i++) {
        if(timePath[i] >= -1){
            logString = [logString stringByAppendingFormat:@"%d,", timePath[i]];
        }
    }
    NSLog(@"Before : %@", logString);
    */
    
    //Reshape oneSequenceArray according to timePath
    int startingIndex = 0;
    for (int i=0; i<numberOfElements*2; i++) {
        if ( timePath[i]>=-1) {
            break;
        }
        else{
            startingIndex++;
        }
    }
    
    int elementIndex = 0;
    double currentValue = [[oneSequenceArray objectAtIndex:0] doubleValue];
    NSMutableArray* tempMutableArray = [[NSMutableArray alloc]initWithCapacity:numberOfElements];
    for (int i=startingIndex; i<numberOfElements*2 && elementIndex<[oneSequenceArray count]; i++) {
        
        if (timePath[i]==0) {
            currentValue = [[oneSequenceArray objectAtIndex:elementIndex] doubleValue];
            [tempMutableArray addObject:[NSNumber numberWithDouble:currentValue]];
            elementIndex++;
        }
        else if(timePath[i]==-1){ //horizontal
            int addingNumber = 1;
            for (int j=i+1; j<numberOfElements*2; j++) {
                if (timePath[j]!=-1) {
                    break;
                }else{
                    addingNumber++;
                }
            }
            i = i+ addingNumber - 1;
            for (int j=0; j<addingNumber; j++) {
                currentValue = [[oneSequenceArray objectAtIndex:elementIndex] doubleValue];
                [tempMutableArray addObject:[NSNumber numberWithDouble:currentValue]];
            }
        }
        else{ //vertical
            int skippingNumber = 1;
            for (int j=i+1; j<numberOfElements*2; j++) {
                if (timePath[j]!=1) {
                    break;
                }else{
                    skippingNumber++;
                }
            }
            elementIndex = elementIndex + skippingNumber;
            i = i+ skippingNumber - 1;
            for (int j=0; j<skippingNumber; j++) {
                if(elementIndex>=[oneSequenceArray count]){
                    elementIndex = [oneSequenceArray count] - 1;
                }
                currentValue = [[oneSequenceArray objectAtIndex:elementIndex] doubleValue];
                [tempMutableArray addObject:[NSNumber numberWithDouble:currentValue]];
            }
        }
        
    }
    
    
    for (int i=0; i<numberOfElements; i++) {
        if(i>=[tempMutableArray count]){
            [oneSequenceArray replaceObjectAtIndex:i withObject:[[NSNumber alloc]initWithDouble:[[tempMutableArray lastObject]doubleValue]]];
        }else{
            [oneSequenceArray replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithDouble:[[tempMutableArray objectAtIndex:i]doubleValue]]];
        }
    }
    [tempMutableArray release];
    
    
    /*logString = @"";
    for (NSNumber* numberValue in oneSequenceArray) {
        logString = [logString stringByAppendingFormat:@"%g,", [numberValue doubleValue]];
    }
    NSLog(@"After : %@", logString);
    */
    
    free(timePath);
    [self freeArray:distanceArray andFirstDimension:numberOfElements];
}
// All the data sequences will change according to DTW to minimiza the error
-(void)makeDTW:(NSArray*)gestureDataArray andTemplate:(double**)arrayTemplate{
    
    [self makeDTWOneSequence:[gestureDataArray objectAtIndex:1] andTemplate:arrayTemplate[0]];
    [self makeDTWOneSequence:[gestureDataArray objectAtIndex:2] andTemplate:arrayTemplate[1]];
    [self makeDTWOneSequence:[gestureDataArray objectAtIndex:3] andTemplate:arrayTemplate[2]];
    [self makeDTWOneSequence:[gestureDataArray objectAtIndex:4] andTemplate:arrayTemplate[3]];
}


// Making the one class of elements with same mean
-(void)makeSameMean:(NSArray*)gestureDataArray{
    
    int numberOfsequences = [gestureDataArray count]; // number of all training observation sequences
    double meanX = 0.0;double meanY = 0.0;double meanZ = 0.0;double meanCluster = 0.0;
    
    // Calculating the mean points
    for(int i=0; i<numberOfsequences; i++) {
        NSArray* dataArray = [(GestureData*)[gestureDataArray objectAtIndex:i] gestureData];
        if (dataArray!= nil &&  [dataArray count]>0 && [(NSMutableArray*)[dataArray objectAtIndex:0] count] > 0) {
            NSMutableArray* timeArray = [dataArray objectAtIndex:0];
            NSMutableArray* xArray = [dataArray objectAtIndex:1];
            NSMutableArray* yArray = [dataArray objectAtIndex:2];
            NSMutableArray* zArray = [dataArray objectAtIndex:3];
            NSMutableArray* clusterArray = [dataArray objectAtIndex:4];
            
            for(int j=0; j<[timeArray count]; j++) {    // the length of observations
                // we are taking the average of x, y, z, cluster values to make a template....
                meanX += [[xArray objectAtIndex:j]doubleValue] / [timeArray count];
                meanY += [[yArray objectAtIndex:j]doubleValue] / [timeArray count];
                meanZ += [[zArray objectAtIndex:j]doubleValue] / [timeArray count];
                meanCluster += [[clusterArray objectAtIndex:j]doubleValue] / [timeArray count];
            }
        } 
    }
    
    
    meanX = meanX /  numberOfsequences;
    meanY = meanY /  numberOfsequences;
    meanZ = meanZ /  numberOfsequences;
    meanCluster = meanCluster /  numberOfsequences;
    
    meanString = [meanString stringByAppendingFormat:@"%g,%g,%g,%g\n",meanX,meanY,meanZ,meanCluster];
    //===========
    double currentMeanX = 0.0;double currentMeanY = 0.0;double currentMeanZ = 0.0;double currentMeanCluster = 0.0;
    double diffMeanX  = 0.0;double diffMeanY  = 0.0;double diffMeanZ  = 0.0;double diffMeanCluster  = 0.0;
    
    for(int i=0; i<numberOfsequences; i++) {
        NSArray* dataArray = [(GestureData*)[gestureDataArray objectAtIndex:i] gestureData];
        if (dataArray!= nil &&  [dataArray count]>0 && [(NSMutableArray*)[dataArray objectAtIndex:0] count] > 0) {
            NSMutableArray* timeArray = [dataArray objectAtIndex:0];
            NSMutableArray* xArray = [dataArray objectAtIndex:1];
            NSMutableArray* yArray = [dataArray objectAtIndex:2];
            NSMutableArray* zArray = [dataArray objectAtIndex:3];
            NSMutableArray* clusterArray = [dataArray objectAtIndex:4];
            
            currentMeanX = 0.0;currentMeanY = 0.0;currentMeanZ = 0.0;currentMeanCluster = 0.0;
            for(int j=0; j<[timeArray count]; j++) {    // the length of observations
                // we are taking the average of x, y, z, cluster values ....
                currentMeanX += [[xArray objectAtIndex:j]doubleValue] / [timeArray count];
                currentMeanY += [[yArray objectAtIndex:j]doubleValue] / [timeArray count];
                currentMeanZ += [[zArray objectAtIndex:j]doubleValue] / [timeArray count];
                currentMeanCluster += [[clusterArray objectAtIndex:j]doubleValue] / [timeArray count];
            }
            
            diffMeanX = meanX - currentMeanX;
            diffMeanY = meanY - currentMeanY;
            diffMeanZ = meanZ - currentMeanZ;
            diffMeanCluster = meanCluster - currentMeanCluster;
            
            for(int j=0; j<[timeArray count]; j++) {    // the length of observations
                [xArray replaceObjectAtIndex:j withObject:[NSNumber numberWithDouble:[[xArray objectAtIndex:j]doubleValue]+diffMeanX]];
                [yArray replaceObjectAtIndex:j withObject:[NSNumber numberWithDouble:[[yArray objectAtIndex:j]doubleValue]+diffMeanY]];
                [zArray replaceObjectAtIndex:j withObject:[NSNumber numberWithDouble:[[zArray objectAtIndex:j]doubleValue]+diffMeanZ]];
                [clusterArray replaceObjectAtIndex:j withObject:[NSNumber numberWithDouble:[[clusterArray objectAtIndex:j]doubleValue]+diffMeanCluster]];
            }
        }
        
    }

}

// Making the one class of elements with same variance
-(void)makeSameVariance:(NSArray*)gestureDataArray{
    int numberOfsequences = [gestureDataArray count]; // number of all training observation sequences
    double meanX = 0.0;double meanY = 0.0;double meanZ = 0.0;double meanCluster = 0.0;
    double varianceX = 0.0;double varianceY = 0.0;double varianceZ = 0.0;double varianceCluster = 0.0;
    
    // Calculating the mean points
    for(int i=0; i<numberOfsequences; i++) {
        NSArray* dataArray = [(GestureData*)[gestureDataArray objectAtIndex:i] gestureData];
        if (dataArray!= nil &&  [dataArray count]>0 && [(NSMutableArray*)[dataArray objectAtIndex:0] count] > 0) {
            NSMutableArray* timeArray = [dataArray objectAtIndex:0];
            NSMutableArray* xArray = [dataArray objectAtIndex:1];
            NSMutableArray* yArray = [dataArray objectAtIndex:2];
            NSMutableArray* zArray = [dataArray objectAtIndex:3];
            NSMutableArray* clusterArray = [dataArray objectAtIndex:4];
            
            for(int j=0; j<[timeArray count]; j++) {    // the length of observations
                // we are taking the average of x, y, z, cluster values to make a template....
                meanX += [[xArray objectAtIndex:j]doubleValue] / [timeArray count];
                meanY += [[yArray objectAtIndex:j]doubleValue] / [timeArray count];
                meanZ += [[zArray objectAtIndex:j]doubleValue] / [timeArray count];
                meanCluster += [[clusterArray objectAtIndex:j]doubleValue] / [timeArray count];
            }
        } 
    }
    
    meanX = meanX /  numberOfsequences;
    meanY = meanY /  numberOfsequences;
    meanZ = meanZ /  numberOfsequences;
    meanCluster = meanCluster /  numberOfsequences;
    
    // Calculating the variance points
    for(int i=0; i<numberOfsequences; i++) {
        NSArray* dataArray = [(GestureData*)[gestureDataArray objectAtIndex:i] gestureData];
        if (dataArray!= nil &&  [dataArray count]>0 && [(NSMutableArray*)[dataArray objectAtIndex:0] count] > 0) {
            NSMutableArray* timeArray = [dataArray objectAtIndex:0];
            NSMutableArray* xArray = [dataArray objectAtIndex:1];
            NSMutableArray* yArray = [dataArray objectAtIndex:2];
            NSMutableArray* zArray = [dataArray objectAtIndex:3];
            NSMutableArray* clusterArray = [dataArray objectAtIndex:4];
            
            for(int j=0; j<[timeArray count]; j++) {    // the length of observations
                // we are taking the average of x, y, z, cluster values to make a template....
                varianceX += pow([[xArray objectAtIndex:j]doubleValue] - meanX, 2)  / [timeArray count];
                varianceY += pow([[yArray objectAtIndex:j]doubleValue] - meanY, 2)  / [timeArray count];
                varianceZ += pow([[zArray objectAtIndex:j]doubleValue] - meanZ, 2)  / [timeArray count];
                varianceCluster += pow([[clusterArray objectAtIndex:j]doubleValue] - meanCluster, 2)  / [timeArray count];
            }
        } 
    }
    
    //varianceX = sqrt(varianceX /  numberOfsequences);
    //varianceY = sqrt(varianceY /  numberOfsequences);
    //varianceZ = sqrt(varianceZ /  numberOfsequences);
    //varianceCluster = sqrt(varianceCluster /  numberOfsequences);
    
    varianceX = varianceX /  numberOfsequences;
    varianceY = varianceY /  numberOfsequences;
    varianceZ = varianceZ /  numberOfsequences;
    varianceCluster = varianceCluster /  numberOfsequences;
    
     varianceString = [varianceString stringByAppendingFormat:@"%g,%g,%g,%g\n",varianceX,varianceY,varianceX,varianceCluster];
    //===========
    double currentMeanX = 0.0;double currentMeanY = 0.0;double currentMeanZ = 0.0;double currentMeanCluster = 0.0;
    double currentvarianceX = 0.0;double currentvarianceY = 0.0;double currentvarianceZ = 0.0;double currentvarianceCluster = 0.0;
    double factorVarianceX  = 0.0;double factorVarianceY  = 0.0;double factorVarianceZ  = 0.0;double factorVarianceCluster  = 0.0;
    double currentX = 0.0; double currentY = 0.0; double currentZ = 0.0; double currentCluster  = 0.0; 
    
    for(int i=0; i<numberOfsequences; i++) {
        NSArray* dataArray = [(GestureData*)[gestureDataArray objectAtIndex:i] gestureData];
        if (dataArray!= nil &&  [dataArray count]>0 && [(NSMutableArray*)[dataArray objectAtIndex:0] count] > 0) {
            NSMutableArray* timeArray = [dataArray objectAtIndex:0];
            NSMutableArray* xArray = [dataArray objectAtIndex:1];
            NSMutableArray* yArray = [dataArray objectAtIndex:2];
            NSMutableArray* zArray = [dataArray objectAtIndex:3];
            NSMutableArray* clusterArray = [dataArray objectAtIndex:4];
            
            currentMeanX = 0.0;currentMeanY = 0.0;currentMeanZ = 0.0;currentMeanCluster = 0.0;
            for(int j=0; j<[timeArray count]; j++) {    // the length of observations
                // we are taking the average of x, y, z, cluster values ....
                currentMeanX += [[xArray objectAtIndex:j]doubleValue] / [timeArray count];
                currentMeanY += [[yArray objectAtIndex:j]doubleValue] / [timeArray count];
                currentMeanZ += [[zArray objectAtIndex:j]doubleValue] / [timeArray count];
                currentMeanCluster += [[clusterArray objectAtIndex:j]doubleValue] / [timeArray count];
            }
            
            currentvarianceX = 0.0;currentvarianceY = 0.0;currentvarianceZ = 0.0;currentvarianceCluster = 0.0;
            for(int j=0; j<[timeArray count]; j++) {    // the length of observations
                currentvarianceX += pow([[xArray objectAtIndex:j]doubleValue] - currentMeanX, 2) / [timeArray count];
                currentvarianceY += pow([[yArray objectAtIndex:j]doubleValue] - currentMeanY, 2) / [timeArray count];
                currentvarianceZ += pow([[zArray objectAtIndex:j]doubleValue] - currentMeanZ, 2)  / [timeArray count];
                currentvarianceCluster += pow([[clusterArray objectAtIndex:j]doubleValue] - currentMeanCluster, 2) / [timeArray count];
            }
            
            //currentvarianceX = sqrt(currentvarianceX);
            //currentvarianceY = sqrt(currentvarianceY);
            //currentvarianceZ = sqrt(currentvarianceZ);
            //currentvarianceCluster = sqrt(currentvarianceCluster);
            
            currentvarianceX = currentvarianceX;
            currentvarianceY = currentvarianceY;
            currentvarianceZ = currentvarianceZ;
            currentvarianceCluster = currentvarianceCluster;
            
            
            //factorVarianceX =  (currentvarianceX!=0.0) ? sqrt(fabs(pow(varianceX, 2) / pow(currentvarianceX, 2))) : 1;
            //factorVarianceY =  (currentvarianceY!=0.0) ? sqrt(fabs(pow(varianceY, 2) / pow(currentvarianceY, 2))) : 1;
            //factorVarianceZ =  (currentvarianceZ!=0.0) ?  sqrt(fabs(pow(varianceZ, 2) / pow(currentvarianceZ, 2))) : 1;
            //factorVarianceCluster =  (currentvarianceCluster!=0.0) ? sqrt(fabs(pow(varianceCluster, 2) / pow(currentvarianceCluster, 2))) : 1;
            factorVarianceX =  (currentvarianceX!=0.0) ? sqrt(varianceX / currentvarianceX) : 1;
            factorVarianceY =  (currentvarianceY!=0.0) ? sqrt(varianceY / currentvarianceY) : 1;
            factorVarianceZ =  (currentvarianceZ!=0.0) ? sqrt(varianceZ / currentvarianceZ) : 1;
            factorVarianceCluster =  (currentvarianceCluster!=0.0) ? sqrt(varianceCluster / currentvarianceCluster) : 1;
            
            for(int j=0; j<[timeArray count]; j++) {    // the length of observations
                currentX = [[xArray objectAtIndex:j] doubleValue];
                currentY = [[yArray objectAtIndex:j] doubleValue];
                currentZ = [[zArray objectAtIndex:j] doubleValue];
                currentCluster = [[clusterArray objectAtIndex:j] doubleValue];
                
                currentX = currentMeanX + (factorVarianceX * (currentX - currentMeanX));
                currentY = currentMeanY + (factorVarianceY * (currentY - currentMeanY));
                currentZ = currentMeanZ + (factorVarianceZ * (currentZ - currentMeanZ));
                currentCluster = currentMeanCluster + (factorVarianceCluster * (currentCluster - currentMeanCluster));
                
                [xArray replaceObjectAtIndex:j withObject:[NSNumber numberWithDouble:currentX]];
                [yArray replaceObjectAtIndex:j withObject:[NSNumber numberWithDouble:currentY]];                
                [zArray replaceObjectAtIndex:j withObject:[NSNumber numberWithDouble:currentZ]];
                [clusterArray replaceObjectAtIndex:j withObject:[NSNumber numberWithDouble:currentCluster]];
            }
            
            /*NSLog(@"For X - REAL Mean: %g, Variance: %g", meanX, varianceX);
            NSLog(@"For X - Previous Mean: %g, Variance: %g", currentMeanX, currentvarianceX);
            double currentMean = 0.0;
            double currentVariance = 0.0;
            for(int j=0; j<[xArray count]; j++) {    // the length of observations
                // we are taking the average of x, y, z, cluster values to make a template....
                currentMean += ([[xArray objectAtIndex:j]doubleValue] / [xArray count]);
            }
            
            // Calculating the variance values 
            for(int j=0; j<[xArray count]; j++) {    // the length of observations
                currentVariance += pow([[xArray objectAtIndex:j]doubleValue] - currentMean, 2) / [xArray count]; // data variance
            }
            //currentVariance = sqrt(currentVariance); 
            currentVariance = currentVariance; 
            NSLog(@"For X - Current Mean: %g, Variance: %g", currentMean, currentVariance);
            */
        }
    }


}

// Making the elements with given mean value
-(void)makeSameMean:(NSArray*)gestureDataArray andMeanValue:(double)mean{
    
}

// Making the elements with given variance value
-(void)makeSameVariance:(NSArray*)gestureDataArray andVarianceValue:(double)variance{
    
}

- (void)dealloc
{
    [super dealloc];
}

@end
