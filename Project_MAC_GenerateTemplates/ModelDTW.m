//
//  ModelDTW.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/24/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "ModelDTW.h"


@implementation ModelDTW

@synthesize minDistance, averageDistance, maxDistance, distanceDTW;

-(id)initWithSampleSize:(int)sampleSizeValue{
    self = [super init];
    if (self) {
        numberOfElements = sampleSizeValue;
        templateT = [self getNewDoubleArray:numberOfElements];
        templateX = [self getNewDoubleArray:numberOfElements];
        templateY = [self getNewDoubleArray:numberOfElements];
        templateZ = [self getNewDoubleArray:numberOfElements];
        templateCluster = [self getNewDoubleArray:numberOfElements];
        varianceAll = [self getNewDoubleArray:4 andSecondDimension:numberOfElements];
        rangeValueForEnvelope = [self getNewDoubleArray:numberOfElements];
        
        upperLimit = [self getNewDoubleArray:4 andSecondDimension:numberOfElements];
        lowerLimit = [self getNewDoubleArray:4 andSecondDimension:numberOfElements];
        
        variance = [self getNewDoubleArray:4];
        mean = [self getNewDoubleArray:4];
        length = 0.0;
        limitRange = 3;
        warpingWindowSize = [self getNewIntegerArray:4 andSecondDimension:numberOfElements];
        //warpingWindowSize = [self getNewIntegerArray:4];
        distanceDTW = [self getNewDoubleArray:4 andSecondDimension:3];
        minDistance = 0.0;
        averageDistance = 0.0;
        maxDistance = 0.0;
    }
    return self;
}

-(void)initialize{
    for (int i=0; i<numberOfElements; i++) {
        templateT[i]=0.0;
        templateX[i]=0.0;
        templateY[i]=0.0;
        templateZ[i]=0.0;
        templateCluster[i]=0.0;
        rangeValueForEnvelope[i]=0.0;
    }
    for (int i=0; i<4; i++) {
        variance[i]=0.0;
        mean[i]=0.0;
        //warpingWindowSize[i]=(numberOfElements /10); // in the first time we make euclidean distance !!!
        for (int j=0; j<numberOfElements; j++) {
            varianceAll[i][j]=0.0;
            upperLimit[i][j]=0.0;
            lowerLimit[i][j]=0.0;
            warpingWindowSize[i][j]=(numberOfElements / 10);
        }
        for (int j=0; j<3; j++) {
            distanceDTW[i][j] = 0.0;
        }
    }
    length = 0.0;
    minDistance = 0.0;
    averageDistance = 0.0;
    maxDistance = 0.0;
}

-(void)traingGestureData:(NSArray*)gestureDataArray{
    
    numberOfsequences = [gestureDataArray count]; // number of all training observation sequences
    
    // Calculating the mean points
    for(int i=0; i<numberOfsequences; i++) {
        NSArray* dataArray = [gestureDataArray objectAtIndex:i];
        if (dataArray!= nil &&  [dataArray count]>0 && [(NSMutableArray*)[dataArray objectAtIndex:0] count] > 0) {
            NSMutableArray* timeArray = [dataArray objectAtIndex:0];
            NSMutableArray* xArray = [dataArray objectAtIndex:1];
            NSMutableArray* yArray = [dataArray objectAtIndex:2];
            NSMutableArray* zArray = [dataArray objectAtIndex:3];
            NSMutableArray* clusterArray = [dataArray objectAtIndex:4];
            
            for(int j=0; j<[timeArray count]; j++) {    // the length of observations
                // we are taking the average of x, y, z, cluster values to make a template....
                templateT[j] += ([[timeArray objectAtIndex:j]doubleValue] / numberOfsequences);
                templateX[j] += ([[xArray objectAtIndex:j]doubleValue] / numberOfsequences);
                templateY[j] += ([[yArray objectAtIndex:j]doubleValue] / numberOfsequences);
                templateZ[j] += ([[zArray objectAtIndex:j]doubleValue] / numberOfsequences);
                templateCluster[j] += ([[clusterArray objectAtIndex:j]doubleValue] / numberOfsequences);
                
                mean[0] += [[xArray objectAtIndex:j]doubleValue] / [timeArray count];
                mean[1] += [[yArray objectAtIndex:j]doubleValue] / [timeArray count];
                mean[2] += [[zArray objectAtIndex:j]doubleValue] / [timeArray count];
                mean[3] += [[clusterArray objectAtIndex:j]doubleValue] / [timeArray count];
            }
            length += [[timeArray lastObject]doubleValue] / numberOfsequences;
        } 
    }
    
    mean[0] = mean[0] /  numberOfsequences;
    mean[1] = mean[1] /  numberOfsequences;
    mean[2] = mean[2] /  numberOfsequences;
    mean[3] = mean[3] /  numberOfsequences;
    
    // Calculating the variance values 
    for(int i=0; i<numberOfsequences; i++) {
        NSArray* dataArray = [gestureDataArray objectAtIndex:i];
        if (dataArray!= nil &&  [dataArray count]>0 && [(NSMutableArray*)[dataArray objectAtIndex:0] count] > 0) {
            NSMutableArray* timeArray = [dataArray objectAtIndex:0];
            NSMutableArray* xArray = [dataArray objectAtIndex:1];
            NSMutableArray* yArray = [dataArray objectAtIndex:2];
            NSMutableArray* zArray = [dataArray objectAtIndex:3];
            NSMutableArray* clusterArray = [dataArray objectAtIndex:4];
            
            for(int j=0; j<[timeArray count]; j++) {    // the length of observations
                varianceAll[0][j] += pow([[xArray objectAtIndex:j]doubleValue] - templateX[j], 2) ;
                varianceAll[1][j] += pow([[yArray objectAtIndex:j]doubleValue] - templateY[j], 2) ;
                varianceAll[2][j] += pow([[zArray objectAtIndex:j]doubleValue] - templateZ[j], 2) ;
                varianceAll[3][j] += pow([[clusterArray objectAtIndex:j]doubleValue] - templateCluster[j], 2) ;
                // we are taking the average of x, y, z, cluster values to make a template....
                variance[0] += pow([[xArray objectAtIndex:j]doubleValue] - mean[0], 2) / [timeArray count] ; // X variance
                variance[1] += pow([[yArray objectAtIndex:j]doubleValue] - mean[1], 2) / [timeArray count]; // Y variance
                variance[2] += pow([[zArray objectAtIndex:j]doubleValue] - mean[2], 2) / [timeArray count]; // Z variance
                variance[3] += pow([[clusterArray objectAtIndex:j]doubleValue] - mean[3], 2) / [timeArray count]; // Amplitute variance
                
                upperLimit[0][j] += [self getUpperLimitValue:xArray andPointIndex:j] / numberOfsequences;
                upperLimit[1][j] += [self getUpperLimitValue:yArray andPointIndex:j] / numberOfsequences;
                upperLimit[2][j] += [self getUpperLimitValue:zArray andPointIndex:j] / numberOfsequences;
                upperLimit[3][j] += [self getUpperLimitValue:clusterArray andPointIndex:j] / numberOfsequences;
                
                lowerLimit[0][j] += [self getLowerLimitValue:xArray andPointIndex:j] / numberOfsequences;
                lowerLimit[1][j] += [self getLowerLimitValue:yArray andPointIndex:j] / numberOfsequences;
                lowerLimit[2][j] += [self getLowerLimitValue:zArray andPointIndex:j] / numberOfsequences;
                lowerLimit[3][j] += [self getLowerLimitValue:clusterArray andPointIndex:j] / numberOfsequences;
            }
        } 
    }
    for (int i=0; i<4; i++) {
        for (int j=0; j<numberOfElements; j++) {
             //varianceAll[i][j] = sqrt(varianceAll[i][j] / numberOfsequences);
             varianceAll[i][j] = varianceAll[i][j] / numberOfsequences;
        }
    }
    
    //variance[0] = sqrt(variance[0] / numberOfsequences ); 
    //variance[1] = sqrt(variance[1] / numberOfsequences ); 
    //variance[2] = sqrt(variance[2] / numberOfsequences ); 
    //variance[3] = sqrt(variance[3] / numberOfsequences ); 
    
    variance[0] = variance[0] / numberOfsequences; 
    variance[1] = variance[1] / numberOfsequences; 
    variance[2] = variance[2] / numberOfsequences; 
    variance[3] = variance[3] / numberOfsequences; 
    
    [self traingDTWDistances:gestureDataArray];
}

-(void)traingDTWDistances:(NSArray*)gestureDataArray{
    
    numberOfsequences = [gestureDataArray count]; 
    // Finding min - max - average distance values
    double tempMinDistance = FLT_MAX;
    double tempAverageDistance = 0.0;
    double tempMaxDistance = FLT_MIN;
    
    double tempDistance = 0.0;
    
    for(int i=0; i<numberOfsequences; i++) {
        NSArray* dataArray = [gestureDataArray objectAtIndex:i];
        if (dataArray!= nil &&  [dataArray count]>0 && [(NSMutableArray*)[dataArray objectAtIndex:0] count] > 0) {
            tempDistance = [self calculateDTWDistance:dataArray];
            if (tempMinDistance > tempDistance ) {
                tempMinDistance = tempDistance;
            }
            if (tempMaxDistance < tempDistance) {
                tempMaxDistance = tempDistance;
            }
            tempAverageDistance += tempDistance / numberOfsequences;
        } 
    }
    
    minDistance = tempMinDistance;
    averageDistance = tempAverageDistance;
    maxDistance = tempMaxDistance;

    
    for (int j=0; j<4; j++) {
        tempMinDistance = FLT_MAX;
        tempAverageDistance = 0.0;
        tempMaxDistance = FLT_MIN;
        for(int i=0; i<numberOfsequences; i++) {
            NSArray* dataArray = [gestureDataArray objectAtIndex:i];
            if (dataArray!= nil &&  [dataArray count]>0 && [(NSMutableArray*)[dataArray objectAtIndex:0] count] > 0) {
                if (j==0) { //distanceDTWX
                     tempDistance = [self calculateDTWDistance:[dataArray objectAtIndex:1] andTemplate:templateX andDimension:0];
                }
                else if (j==1) { //distanceDTWY
                    tempDistance = [self calculateDTWDistance:[dataArray objectAtIndex:2] andTemplate:templateY andDimension:1];
                }
                else if (j==2) { //distanceDTWZ
                    tempDistance = [self calculateDTWDistance:[dataArray objectAtIndex:3] andTemplate:templateZ andDimension:2];
                }
                else if (j==3) { //distanceDTWC
                    tempDistance = [self calculateDTWDistance:[dataArray objectAtIndex:4] andTemplate:templateCluster andDimension:3];
                }
                else{
                    // do nothing
                }
            
                
                if (tempMinDistance > tempDistance ) {
                    tempMinDistance = tempDistance;
                }
                if (tempMaxDistance < tempDistance) {
                    tempMaxDistance = tempDistance;
                }
                tempAverageDistance += tempDistance / numberOfsequences;
            } 
        }
        distanceDTW[j][0] = tempMinDistance;
        distanceDTW[j][1] = tempAverageDistance;
        distanceDTW[j][2] = tempMaxDistance;
    }

}

-(double)getUpperLimitValue:(NSArray*)oneSequenceDataArray andPointIndex:(int)pointIndex{
    double returnValue = INT_MIN ;
    for (int i=pointIndex - limitRange; i<= pointIndex+limitRange ; i++) {
        if (i>=0 && i<[oneSequenceDataArray count]) {
            if (returnValue < [[oneSequenceDataArray objectAtIndex:i]doubleValue]) {
                returnValue = [[oneSequenceDataArray objectAtIndex:i]doubleValue];
            }
        }
    }
    return returnValue;
}

-(double)getLowerLimitValue:(NSArray*)oneSequenceDataArray andPointIndex:(int)pointIndex{
    double returnValue = FLT_MAX ;
    for (int i=pointIndex - limitRange; i<= pointIndex+limitRange ; i++) {
        if (i>=0 && i<[oneSequenceDataArray count]) {
            if (returnValue > [[oneSequenceDataArray objectAtIndex:i]doubleValue]) {
                returnValue = [[oneSequenceDataArray objectAtIndex:i]doubleValue];
            }
        }
    }
    return returnValue;
}

-(double)calculateLBKeoghDistance:(NSArray*)oneGestureDataArray{
    return  [self calculateLBKeoghDistance:[oneGestureDataArray objectAtIndex:1] andDimension:0]+
            [self calculateLBKeoghDistance:[oneGestureDataArray objectAtIndex:2] andDimension:1]+
            [self calculateLBKeoghDistance:[oneGestureDataArray objectAtIndex:3] andDimension:2];
 
}


-(double)calculateLBKeoghDistance:(NSArray*)oneSequenceArray andDimension:(int)dimension{
    
    double returnValue = 0.0;
    double pointValue =0.0;
    for (int i=0; i<numberOfElements; i++) {
        pointValue = [[oneSequenceArray objectAtIndex:i]doubleValue];
        if (pointValue > upperLimit[dimension][i]) {
            returnValue += pow(pointValue - upperLimit[dimension][i], 2);
        }
        else if(pointValue < lowerLimit[dimension][i]) {
            returnValue += pow(pointValue - lowerLimit[dimension][i], 2);
        }
        else{
            //do nothing - the data is in range -> cost is 0
        }
    }
    return returnValue;
}

-(void)preprocessData:(NSArray*)oneSequenceDataArray andDimension:(int)dimension{
    
    double currentMean = 0.0;
    double currentVariance= 0.0;
    double currentLength= 0.0;
    
    double factorVarianceData  = 0.0;
    double pointValue = 0.0;
    
    // Calculating the mean points
    NSArray* dataArray = oneSequenceDataArray;
    if (dataArray!= nil &&  [dataArray count]>0 && [(NSMutableArray*)[dataArray objectAtIndex:0] count] > 0) {
        NSMutableArray* oneSequence = [dataArray objectAtIndex:dimension];
        for(int j=0; j<[oneSequence count]; j++) {    // the length of observations
            // we are taking the average of x, y, z, cluster values to make a template....
            currentMean += ([[oneSequence objectAtIndex:j]doubleValue] / [oneSequence count]);
        }
        // Calculating the variance values 
        for(int j=0; j<[oneSequence count]; j++) {    // the length of observations
            currentVariance += pow([[oneSequence objectAtIndex:j]doubleValue] - currentMean, 2) / [oneSequence count] ; // data variance
        }
        currentLength = [[(NSArray*)[dataArray objectAtIndex:0] lastObject]doubleValue];
        factorVarianceData =  sqrt(currentLength / length);
        
        //The variances and mean will be equal
        for(int j=0; j<[oneSequence count]; j++) {    // the length of observations
            pointValue = [[oneSequence objectAtIndex:j]doubleValue];
            if (factorVarianceData!=0.0) {
                pointValue = currentMean + (factorVarianceData * (pointValue - currentMean));
            }
            [oneSequence replaceObjectAtIndex:j withObject:[[NSNumber alloc]initWithDouble:pointValue]];
        }
        
        
    } 
    
    
}

-(void)preprocessData:(NSArray*)oneSequenceDataArray{
    [self preprocessData:oneSequenceDataArray andDimension:1];
    [self preprocessData:oneSequenceDataArray andDimension:2];
    [self preprocessData:oneSequenceDataArray andDimension:3];
}

-(double)calculateDistance:(NSArray*)oneGestureDataArray{
    double returnValueDistance = 0.0;
    NSArray* xArray = [oneGestureDataArray objectAtIndex:1];
    NSArray* yArray = [oneGestureDataArray objectAtIndex:2];
    NSArray* zArray = [oneGestureDataArray objectAtIndex:3];
    
    for (int i=0; i<[xArray count]; i++) {
        returnValueDistance += sqrt(pow([[xArray objectAtIndex:i] doubleValue]-templateX[i], 2) +  
                                    pow([[yArray objectAtIndex:i] doubleValue]-templateY[i], 2) +  
                                    pow([[zArray objectAtIndex:i] doubleValue]-templateZ[i], 2)) / [xArray count];
    }
    return returnValueDistance;
}

-(double)calculateDistance:(NSArray*)oneSequenceArray andTemplate:(double*)templateArray{
    double returnValueDistance = 0.0;
    for (int i=0; i<[oneSequenceArray count]; i++) {
        returnValueDistance += fabs([[oneSequenceArray objectAtIndex:i] doubleValue]-templateArray[i]);
    }
    return returnValueDistance;
}

/*-(void)setWrapingWindowSize:(int)sizeOfWindow andDimension:(int)dimension{
    warpingWindowSize[dimension] = sizeOfWindow;
}

-(int)getWrapingWindowSize:(int)dimension{
    return  warpingWindowSize[dimension];
}
*/

-(void)setWrapingWindowSize:(int*)arraySizeOfWindow andDimension:(int)dimension{
    for (int i=0; i<numberOfElements; i++) {
         warpingWindowSize[dimension][i] = arraySizeOfWindow[i];
    }
   
}

-(int*)getWrapingWindowSize:(int)dimension{
    return  warpingWindowSize[dimension];
}

-(double)calculateDTWDistance:(NSArray*)oneGestureDataArray{
    double returnValue = 0;
    
    double distanceDTWX = [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:templateX andDimension:0];
    double distanceDTWY = [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:templateY andDimension:1];
    double distanceDTWZ = [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:templateZ andDimension:2];
    
    /*double minDistance = MIN(MIN(distanceDTWX,distanceDTWY),distanceDTWZ);
    double middleDistance =0.0;
    double maxDistance = MAX(MAX(distanceDTWX,distanceDTWY),distanceDTWZ);
    
    if ((minDistance==distanceDTWX || minDistance==distanceDTWY) && (maxDistance==distanceDTWX || maxDistance==distanceDTWY) ) {
        middleDistance = distanceDTWZ;
    }
    else if ((minDistance==distanceDTWZ || minDistance==distanceDTWY) && (maxDistance==distanceDTWZ || maxDistance==distanceDTWY) ) {
        middleDistance = distanceDTWX;
    }
    else{
        middleDistance = distanceDTWY;
    }
    */
    
    //returnValue = minDistance + middleDistance + maxDistance;
    //returnValue = sqrt( distanceDTWX*distanceDTWX + distanceDTWY*distanceDTWY + distanceDTWZ*distanceDTWZ ) ;//+ distanceCluster;
    returnValue = distanceDTWX + distanceDTWY + distanceDTWZ ;//+ distanceCluster;
    
    return returnValue;
}

-(double)getDistanceFromThreshold:(double)value andMinValue:(double)minValue andAvgValue:(double)avgValue andMaxValue:(double)maxValue{
    double returnValue= 0.0;
    
    if(value < minValue){
        returnValue = minValue - value;
    }
    else if(value > maxValue){
        returnValue = value - maxValue;
    }
    else{
        returnValue = value - avgValue; 
    }
    
    return returnValue;
}

-(double)calculateClassificationDistance:(GestureData*)oneGestureData{
    
    double returnValue = 0.0;
    
    NSArray* oneGestureDataArray = oneGestureData.gestureData;
    double allDistance = [self calculateDTWDistance:oneGestureDataArray];
    double distanceDTWX = [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:templateX andDimension:0];
    double distanceDTWY = [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:templateY andDimension:1];
    double distanceDTWZ = [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:templateZ andDimension:2];
    
    //

    //returnValue = [self getDistanceFromThreshold:allDistance andMinValue:minDistance andAvgValue:averageDistance andMaxValue:maxDistance];
    //returnValue += [self getDistanceFromThreshold:distanceDTWX andMinValue:distanceDTW[0][0] andAvgValue:distanceDTW[0][1] andMaxValue:distanceDTW[0][2]];
    //returnValue += [self getDistanceFromThreshold:distanceDTWY andMinValue:distanceDTW[1][0] andAvgValue:distanceDTW[1][1] andMaxValue:distanceDTW[1][2]];
    //returnValue += [self getDistanceFromThreshold:distanceDTWZ andMinValue:distanceDTW[2][0] andAvgValue:distanceDTW[2][1] andMaxValue:distanceDTW[2][2]];
    
    returnValue += [self calculateDTWDistance:oneGestureData.gestureData];
    
    /*double varianceTotalOfSample = oneGestureData.variance[0] + oneGestureData.variance[1] + oneGestureData.variance[2];
    double factorVarianceOfSample = 1 / varianceTotalOfSample;
    
    double varianceTotalOfModel = variance[0] + variance[1] + variance[2];
    double factorVarianceOfModel = 1 / varianceTotalOfModel;
    
    double varianceDiff = fabs( factorVarianceOfSample*oneGestureData.variance[0] - factorVarianceOfModel*variance[0]);
    varianceDiff += fabs(factorVarianceOfSample*oneGestureData.variance[1] - factorVarianceOfModel*variance[1]);
    varianceDiff += fabs(factorVarianceOfSample*oneGestureData.variance[2] - factorVarianceOfModel*variance[2]);
    */
    
    return returnValue;
}

-(double)calculateDTWDistance:(NSArray*)oneSequenceArray andTemplate:(double*)templateArray andDimension:(int)dimension{
    double returnValueDistance = 0.0;
    double** distanceArray = [self getNewDoubleArray:[oneSequenceArray count] andSecondDimension:numberOfElements];
    double cost = 0.0;
    
    for(int i=1;i<numberOfElements;i++){
        distanceArray[0][i] = MAXFLOAT;
    }
    for (int i=1; i<[oneSequenceArray count]; i++) {
        distanceArray[i][0] = MAXFLOAT;
    }
    
    distanceArray[0][0] = 0.0;
    
    for (int i=1; i<[oneSequenceArray count]; i++) {
       for(int j=1;j<numberOfElements;j++){
           
           /*if(i==j){
               if ([[oneSequenceArray objectAtIndex:i] doubleValue] > upperLimit[dimension][j]) {
                   cost = fabs([[oneSequenceArray objectAtIndex:i] doubleValue] - upperLimit[dimension][j]);
               }
               else if([[oneSequenceArray objectAtIndex:i] doubleValue] < lowerLimit[dimension][j]) {
                   cost = fabs([[oneSequenceArray objectAtIndex:i] doubleValue]- lowerLimit[dimension][j]);
               }
               else{
                   cost = 0;
                   //do nothing - the data is in range -> cost is 0
               }
           }
           else{
               cost = fabs([[oneSequenceArray objectAtIndex:i] doubleValue]-templateArray[j]);
           }
           */

           cost = fabs([[oneSequenceArray objectAtIndex:i] doubleValue]-templateArray[j]);
           
           //if (abs(i-j)<=warpingWindowSize[dimension]) {
           if (abs(i-j)<=warpingWindowSize[dimension][MAX(i, j)]) { 
               distanceArray[i][j] = cost + MIN( MIN(distanceArray[i-1][j], distanceArray[i][j-1]), distanceArray[i-1][j-1]);
           }
           else{
               distanceArray[i][j] = MAXFLOAT;
           }
       }
    }
     
    returnValueDistance = distanceArray[[oneSequenceArray count]-1][numberOfElements-1];
    [self freeArray:distanceArray andFirstDimension:[oneSequenceArray count]];
    
    //double varianceTotal = variance[0] + variance[1] + variance[2];
    //double factorVariance = 1 / varianceTotal;
    
    return returnValueDistance;
}

-(double)getMean:(NSArray*)oneGestureDataArray andDimension:(int)dimension{
    double meanValue = 0.0;
   
    NSArray* dataArray = oneGestureDataArray;
    if (dataArray!= nil &&  [dataArray count]>0 && [(NSMutableArray*)[dataArray objectAtIndex:0] count] > 0) {
        NSMutableArray* oneSequence = [dataArray objectAtIndex:dimension];
        for(int j=0; j<[oneSequence count]; j++) {    // the length of observations
            meanValue += ([[oneSequence objectAtIndex:j]doubleValue] / [oneSequence count]);
        }
    }
    return  meanValue;
}

-(double)getSumMeanDifference:(NSArray*)oneGestureDataArray{
    return  fabs([self getMean:oneGestureDataArray andDimension:1] - mean[0])+
            fabs([self getMean:oneGestureDataArray andDimension:2] - mean[1])+
            fabs([self getMean:oneGestureDataArray andDimension:3] - mean[2]);
    //+fabs([self getMean:oneGestureDataArray andDimension:3] - mean[3]);
}

-(double)getVariance:(NSArray*)oneGestureDataArray andDimension:(int)dimension{
    
    double currentVariance= 0.0;
    double currentMean = [self getMean:oneGestureDataArray andDimension:dimension];
    
    // Calculating the mean points
    NSArray* dataArray = oneGestureDataArray;
    if (dataArray!= nil &&  [dataArray count]>0 && [(NSMutableArray*)[dataArray objectAtIndex:0] count] > 0) {
        NSMutableArray* oneSequence = [dataArray objectAtIndex:dimension];
        
        // Calculating the variance values 
        for(int j=0; j<[oneSequence count]; j++) {    // the length of observations
            currentVariance += pow([[oneSequence objectAtIndex:j]doubleValue] - currentMean, 2) / [oneSequence count] ; // data variance
        }
        
        //currentVariance = sqrt(currentVariance);
        currentVariance = currentVariance;
    }
    return  currentVariance;
}

-(double)getSumVarianceDifference:(NSArray*)oneGestureDataArray{
    return  fabs([self getVariance:oneGestureDataArray andDimension:1] - variance[0])+
    fabs([self getVariance:oneGestureDataArray andDimension:2] - variance[1])+
    fabs([self getVariance:oneGestureDataArray andDimension:3] - variance[2]);
    //+fabs([self getVariance:oneGestureDataArray andDimension:3] - variance[3]);
}

-(double)getLengthDifference:(NSArray*)oneGestureDataArray{
    return fabs(length - [[(NSArray*)[oneGestureDataArray objectAtIndex:0]lastObject]doubleValue]);
}

-(BOOL)isGestureInRange:(NSArray*)oneGestureDataArray{
    BOOL returnValue = NO;
    
    double allDistance = [self calculateDTWDistance:oneGestureDataArray];
    double distanceDTWX = [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:templateX andDimension:0];
    double distanceDTWY = [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:templateY andDimension:1];
    double distanceDTWZ = [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:templateZ andDimension:2];
    
    double lowerLimitTolerance = 0.9;
    double upperLimitTolerance = 1.1;
    
    
    if ( allDistance > (lowerLimitTolerance * minDistance) && allDistance < (upperLimitTolerance * maxDistance)) {
        if (distanceDTWX > (lowerLimitTolerance * distanceDTW[0][0]) && distanceDTWX < (upperLimitTolerance * distanceDTW[0][2])) {
            if (distanceDTWY > (lowerLimitTolerance * distanceDTW[1][0]) && distanceDTWY < (upperLimitTolerance * distanceDTW[1][2])) {
                if (distanceDTWZ > (lowerLimitTolerance * distanceDTW[2][0]) && distanceDTWZ < (upperLimitTolerance * distanceDTW[2][2])) {
                    returnValue = YES;
                }
            }
        }
    }
    
    return returnValue;
}

-(double)getProbability:(NSArray*)oneGestureDataArray{
    
    double returnValue = 0;
    
    //double distanceCluster = [self calculateDistance:[oneGestureDataArray objectAtIndex:4] andTemplate:templateCluster];
    //double sumOrVariance = variance[0] + variance[1] +  variance[2];
    
    //double maxVariance =MAX( MAX(variance[0], variance[1]),variance[2]);
    //double factorVariance = 1 / maxVariance;
    //returnValue = variance[0] * distanceDTWX + variance[1] * distanceDTWY + variance[2] *distanceDTWZ ;//+ distanceCluster;
    
    //distanceDTWX += [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:upperLimit[0] andDimension:0];
    //distanceDTWX += [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:lowerLimit[0] andDimension:0];
    //distanceDTWY += [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:upperLimit[1] andDimension:1];
    //distanceDTWY += [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:lowerLimit[1] andDimension:1];
    //distanceDTWZ += [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:upperLimit[2] andDimension:2];
    //distanceDTWZ += [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:lowerLimit[2] andDimension:2];
    
    returnValue = [self calculateDTWDistance:oneGestureDataArray];//+ distanceCluster;
    //double distanceDTWX = MIN(MIN([self calculateDTWDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:templateX andDimension:0], [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:upperLimit[0] andDimension:0]), [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:lowerLimit[0] andDimension:0]);
    
    //double distanceDTWY = MIN(MIN([self calculateDTWDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:templateY andDimension:1], [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:upperLimit[1] andDimension:1]), [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:lowerLimit[1] andDimension:1]);
    
    //double distanceDTWZ = MIN(MIN([self calculateDTWDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:templateZ andDimension:2], [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:upperLimit[2] andDimension:2]), [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:lowerLimit[2] andDimension:2]);
    
    //double distanceX = MIN(MIN([self calculateDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:templateX], [self calculateDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:upperLimit[0]] ), [self calculateDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:lowerLimit[0]] );
    
    //double distanceY = MIN(MIN([self calculateDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:templateY], [self calculateDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:upperLimit[1]] ), [self calculateDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:lowerLimit[1]] );
    
    //double distanceZ = MIN(MIN([self calculateDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:templateZ], [self calculateDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:upperLimit[2]] ), [self calculateDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:lowerLimit[2]] );
    
    
    //returnValue += distanceX + distanceY + distanceZ ;
    //returnValue = (variance[0]/sumOrVariance * distanceDTWX) + (variance[1]/sumOrVariance * distanceDTWY) + (variance[2]/sumOrVariance *distanceDTWZ) ;
    //returnValue = (factorVariance * variance[0] * distanceDTWX) + (factorVariance * variance[1]* distanceDTWY) + (factorVariance * variance[2] * distanceDTWZ) ;
    //returnValue += [self getSumMeanDifference:oneGestureDataArray] * 1 ; 
    //returnValue += [self getSumVarianceDifference:oneGestureDataArray] * 1;
    //returnValue += pow([self getLengthDifference:oneGestureDataArray]+1,2);
    //returnValue += [self calculateDistance:oneGestureDataArray];
    //double distanceX = [self calculateDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:templateX];
    //double distanceY = [self calculateDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:templateY];
    //double distanceZ = [self calculateDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:templateZ];
    //returnValue += [self calculateLBKeoghDistance:oneGestureDataArray];
    
    //returnValue += distanceX + distanceY + distanceZ ;
    //returnValue += (variance[0]/sumOrVariance * distanceX) + (variance[1]/sumOrVariance * distanceY) + (variance[2]/sumOrVariance *distanceZ) ;
    
    /*NSLog(@"distanceX: %g,distanceX: %g,distanceX: %g,Mean Difference Sum: %g, Variance Difference Sum: %g, Length Difference: %g", distanceX, distanceY, distanceZ,[self getSumMeanDifference:oneGestureDataArray], [self getSumVarianceDifference:oneGestureDataArray], [self getLengthDifference:oneGestureDataArray]);
    NSString* logString = [NSString stringWithFormat:@"- Model Probability : %g ; \n", modelProbability];
    for (int i=0; i<4; i++) {
        logString = [logString stringByAppendingFormat:@"Dimension: %d, Variance: %g, Mean: %g \n",i, variance[i], mean[i]];
    }
    NSLog(@"%@", logString);
     */
    
    
    //if (returnValue < minDistance || returnValue > maxDistance) {
    //    returnValue = MAXFLOAT;
    //}
    
    //returnValue = 1/returnValue;
    returnValue = (100 - returnValue)/100;
    if (returnValue<0) {
        //NSLog(@"%g", returnValue);
    }
    return returnValue;
}

-(double)calculateDTWDistance:(NSArray*)oneGestureDataArray andDimension:(int)dimension{
    double returnValue = 0;
    
    if (dimension==0) {
        returnValue = [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:templateX andDimension:0];
    }
    else if (dimension==1) {
        returnValue = [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:templateY andDimension:1];
    }
    else if (dimension==2) {
        returnValue = [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:templateZ andDimension:2];
    }
    else if (dimension==3) {
        returnValue = [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:4] andTemplate:templateCluster andDimension:3];
    }
    else{
        returnValue = 0;
    }
    return returnValue;
}

-(NSString*)getShortString:(NSArray*)oneGestureDataArray{
    NSString* returnValue = [NSString stringWithFormat:@"Length :%g, Distances %g-%g-%g \n", length, minDistance, averageDistance, maxDistance];
    double varianceTotal = variance[0] + variance[1] + variance[2];
    double factorVariance = 1 / varianceTotal;
    
    for (int i=0; i<4; i++) {
        
        double distanceDTWValue = [self calculateDTWDistance:oneGestureDataArray andDimension:i];
        returnValue = [returnValue stringByAppendingFormat:@" D: %d, Variance: %g (unit variance: %g), M: %g = DTW: %g, MD:%g, VD:%g, LD:%g, Distances %g-%g-%g \n",
                       i,
                       variance[i],
                       factorVariance * variance[i], 
                       mean[i],
                       distanceDTWValue, 
                       fabs([self getMean:oneGestureDataArray andDimension:i+1]-mean[i]),
                       fabs([self getVariance:oneGestureDataArray andDimension:i+1] - variance[i]),
                       [self getLengthDifference:oneGestureDataArray],
                       distanceDTW[i][0],
                       distanceDTW[i][1],
                       distanceDTW[i][2]];
    }
    return returnValue;
}

-(NSString*)toString{
	NSString* returnValue = [NSString stringWithFormat:@"- Model Probability : %g ; \n", modelProbability];
    for (int i=0; i<4; i++) {
        returnValue = [returnValue stringByAppendingFormat:@"Dimension: %d, Variance: %g, Mean: %g \n",i, variance[i], mean[i]];
    }
    returnValue = [returnValue stringByAppendingString:@"\nTemplate X ;"];
    for (int j=0; j<numberOfElements; j++) {
        returnValue = [returnValue stringByAppendingFormat:@"%g ,",templateX[j]];
    }
    returnValue = [returnValue stringByAppendingString:@"\nTemplate Y ;"];
    for (int j=0; j<numberOfElements; j++) {
        returnValue = [returnValue stringByAppendingFormat:@"%g ,",templateY[j]];
    }
    returnValue = [returnValue stringByAppendingString:@"\nTemplate Z ;"];
    for (int j=0; j<numberOfElements; j++) {
        returnValue = [returnValue stringByAppendingFormat:@"%g ,",templateZ[j]];
    }
    returnValue = [returnValue stringByAppendingString:@"\nTemplate Cluster ;"];
    for (int j=0; j<numberOfElements; j++) {
        returnValue = [returnValue stringByAppendingFormat:@"%g ,",templateCluster[j]];
    }
    
    returnValue = [returnValue stringByAppendingString:@"\nVariance for all time ;"];
    
	for (int i=0; i<4; i++) {
        returnValue = [returnValue stringByAppendingFormat:@"\n%d | ",i];
		for (int j=0; j<numberOfElements; j++) {
			returnValue = [returnValue stringByAppendingFormat:@"%g ,",varianceAll[i][j]];
		}
	}
	return returnValue;
}

-(NSDictionary*)getConfiguration{
    
    NSMutableDictionary* classifierConfiguration = [[NSMutableDictionary alloc]init];
    
    NSNumber* valueModelProbability = [NSNumber numberWithDouble:modelProbability];
    
     
    NSMutableArray* arrayVariance = [NSMutableArray arrayWithCapacity:4];
    NSMutableArray* arrayMean = [NSMutableArray arrayWithCapacity:4];
    NSNumber* valueLength = [NSNumber numberWithDouble:length];
    NSMutableArray* arrayTemplateT = [NSMutableArray arrayWithCapacity:numberOfElements];
    NSMutableArray* arrayTemplateX = [NSMutableArray arrayWithCapacity:numberOfElements];
    NSMutableArray* arrayTemplateY = [NSMutableArray arrayWithCapacity:numberOfElements];
    NSMutableArray* arrayTemplateZ = [NSMutableArray arrayWithCapacity:numberOfElements];
    NSMutableArray* arrayTemplateC = [NSMutableArray arrayWithCapacity:numberOfElements];
    NSNumber* valueLimitRange = [NSNumber numberWithDouble:limitRange];
    NSNumber* valueMinDistance = [NSNumber numberWithDouble:minDistance];
    NSNumber* valueAverageDistance = [NSNumber numberWithDouble:averageDistance];
    NSNumber* valueMaxDistance = [NSNumber numberWithDouble:maxDistance];
    
    NSMutableArray* arrayVarianceAll = [NSMutableArray arrayWithCapacity:4];
    for (int i=0; i<4; i++) {
         NSMutableArray* arrayVarianceValues = [NSMutableArray arrayWithCapacity:numberOfElements];
        for (int j=0; j<numberOfElements; j++) {
            [arrayVarianceValues addObject:[NSNumber numberWithDouble:varianceAll[i][j]]];
        }
        [arrayVarianceAll addObject:arrayVarianceValues];
    }
    NSMutableArray* arrayUpperLimitAll = [NSMutableArray arrayWithCapacity:4];
    for (int i=0; i<4; i++) {
        NSMutableArray* arrayUpperLimitValues = [NSMutableArray arrayWithCapacity:numberOfElements];
        for (int j=0; j<numberOfElements; j++) {
            [arrayUpperLimitValues addObject:[NSNumber numberWithDouble:upperLimit[i][j]]];
        }
        [arrayUpperLimitAll addObject:arrayUpperLimitValues];
    }
    NSMutableArray* arrayLowerLimitAll = [NSMutableArray arrayWithCapacity:4];
    for (int i=0; i<4; i++) {
        NSMutableArray* arrayLowerLimitValues = [NSMutableArray arrayWithCapacity:numberOfElements];
        for (int j=0; j<numberOfElements; j++) {
            [arrayLowerLimitValues addObject:[NSNumber numberWithDouble:lowerLimit[i][j]]];
        }
        [arrayLowerLimitAll addObject:arrayLowerLimitValues];
    }
    NSMutableArray* arrayWarpingWindowAll = [NSMutableArray arrayWithCapacity:4];
    for (int i=0; i<4; i++) {
        NSMutableArray* arrayWarpingWindow = [NSMutableArray arrayWithCapacity:numberOfElements];
        for (int j=0; j<numberOfElements; j++) {
            [arrayWarpingWindow addObject:[NSNumber numberWithInt:warpingWindowSize[i][j]]];
        }
        [arrayWarpingWindowAll addObject:arrayWarpingWindow];
    }
    
    NSMutableArray* arrayDistanceDTWAll = [NSMutableArray arrayWithCapacity:4];
    for (int i=0; i<4; i++) {
        NSMutableArray* arrayDistanceDTW = [NSMutableArray arrayWithCapacity:3];
        for (int j=0; j<3; j++) {
            [arrayDistanceDTW addObject:[NSNumber numberWithDouble:distanceDTW[i][j]]];
        }
        [arrayDistanceDTWAll addObject:arrayDistanceDTW];
    }
    
    for (int i=0; i<4; i++) {
        [arrayVariance addObject:[NSNumber numberWithDouble:variance[i]]];
        [arrayMean addObject:[NSNumber numberWithDouble:mean[i]]];
    }
   
    for (int i=0; i<numberOfElements; i++) {
        [arrayTemplateT addObject:[NSNumber numberWithDouble:templateT[i]]];
        [arrayTemplateX addObject:[NSNumber numberWithDouble:templateX[i]]];
        [arrayTemplateY addObject:[NSNumber numberWithDouble:templateY[i]]];
        [arrayTemplateZ addObject:[NSNumber numberWithDouble:templateZ[i]]];
        [arrayTemplateC addObject:[NSNumber numberWithDouble:templateCluster[i]]];
    }
    
    [classifierConfiguration setValue:valueModelProbability forKey:@"valueModelProbability"];
    [classifierConfiguration setValue:arrayVariance forKey:@"arrayVariance"];
    [classifierConfiguration setValue:arrayMean forKey:@"arrayMean"];
    [classifierConfiguration setValue:valueLength forKey:@"valueLength"];
    [classifierConfiguration setValue:arrayTemplateT forKey:@"arrayTemplateT"];
    [classifierConfiguration setValue:arrayTemplateX forKey:@"arrayTemplateX"];
    [classifierConfiguration setValue:arrayTemplateY forKey:@"arrayTemplateY"];
    [classifierConfiguration setValue:arrayTemplateZ forKey:@"arrayTemplateZ"];
    [classifierConfiguration setValue:arrayTemplateC forKey:@"arrayTemplateC"];
    [classifierConfiguration setValue:arrayUpperLimitAll forKey:@"arrayUpperLimitAll"];
    [classifierConfiguration setValue:arrayLowerLimitAll forKey:@"arrayLowerLimitAll"];
    [classifierConfiguration setValue:valueLimitRange forKey:@"valueLimitRange"];
    [classifierConfiguration setValue:arrayWarpingWindowAll forKey:@"arrayWarpingWindowAll"];
    [classifierConfiguration setValue:valueMinDistance forKey:@"valueMinDistance"];
    [classifierConfiguration setValue:valueAverageDistance forKey:@"valueAverageDistance"];
    [classifierConfiguration setValue:valueMaxDistance forKey:@"valueMaxDistance"];
    [classifierConfiguration setValue:arrayDistanceDTWAll forKey:@"arrayDistanceDTWAll"];
    
    return classifierConfiguration;
}

-(void)loadDTWConfiguration:(NSDictionary*)configurationFile{
    //minDistance = [[configurationFile objectForKey:@"valueMinDistance"] doubleValue];
    //averageDistance = [[configurationFile objectForKey:@"valueAverageDistance"] doubleValue];
    //maxDistance = [[configurationFile objectForKey:@"valueMaxDistance"] doubleValue];
    
    NSMutableArray* arrayWarpingWindowAll = [configurationFile objectForKey:@"arrayWarpingWindowAll"];
    for (int i=0; i<4; i++) {
        NSMutableArray* arrayWarpingWindow = [arrayWarpingWindowAll objectAtIndex:i];
        for (int j=0; j<numberOfElements; j++) {
            warpingWindowSize[i][j] = [[arrayWarpingWindow objectAtIndex:j] intValue];
        }
    }
}

-(void)loadConfiguration:(NSDictionary*)configurationFile{
    
    modelProbability = [[configurationFile objectForKey:@"valueModelProbability"] doubleValue];
    
    NSMutableArray* arrayVariance = [configurationFile objectForKey:@"arrayVariance"];
    NSMutableArray* arrayMean = [configurationFile objectForKey:@"arrayMean"];
    length = [[configurationFile objectForKey:@"valueLength"] doubleValue];
    limitRange = [[configurationFile objectForKey:@"valueLimitRange"] doubleValue];
    minDistance = [[configurationFile objectForKey:@"valueMinDistance"] doubleValue];
    averageDistance = [[configurationFile objectForKey:@"valueAverageDistance"] doubleValue];
    maxDistance = [[configurationFile objectForKey:@"valueMaxDistance"] doubleValue];
    
    NSMutableArray* arrayTemplateT = [configurationFile objectForKey:@"arrayTemplateT"];
    NSMutableArray* arrayTemplateX = [configurationFile objectForKey:@"arrayTemplateX"];
    NSMutableArray* arrayTemplateY = [configurationFile objectForKey:@"arrayTemplateY"];
    NSMutableArray* arrayTemplateZ = [configurationFile objectForKey:@"arrayTemplateZ"];
    NSMutableArray* arrayTemplateC = [configurationFile objectForKey:@"arrayTemplateC"];
    
    NSMutableArray* arrayVarianceAll = [configurationFile objectForKey:@"arrayVarianceAll"];
    for (int i=0; i<4; i++) {
        NSMutableArray* arrayVarianceValues = [arrayVarianceAll objectAtIndex:i];
        for (int j=0; j<numberOfElements; j++) {
            varianceAll[i][j] = [[arrayVarianceValues objectAtIndex:j] doubleValue];
        }
    }
    
    NSMutableArray* arrayUpperLimitAll = [configurationFile objectForKey:@"arrayUpperLimitAll"];
    for (int i=0; i<4; i++) {
        NSMutableArray* arrayUpperLimitValues = [arrayUpperLimitAll objectAtIndex:i];
        for (int j=0; j<numberOfElements; j++) {
            upperLimit[i][j] = [[arrayUpperLimitValues objectAtIndex:j] doubleValue];
        }
    }
    
    NSMutableArray* arrayLowerLimitAll = [configurationFile objectForKey:@"arrayLowerLimitAll"];
    for (int i=0; i<4; i++) {
        NSMutableArray* arrayLowerLimitValues = [arrayLowerLimitAll objectAtIndex:i];
        for (int j=0; j<numberOfElements; j++) {
            lowerLimit[i][j] = [[arrayLowerLimitValues objectAtIndex:j] doubleValue];
        }
    }
   
    NSMutableArray* arrayWarpingWindowAll = [configurationFile objectForKey:@"arrayWarpingWindowAll"];
    for (int i=0; i<4; i++) {
        NSMutableArray* arrayWarpingWindow = [arrayWarpingWindowAll objectAtIndex:i];
        for (int j=0; j<numberOfElements; j++) {
            warpingWindowSize[i][j] = [[arrayWarpingWindow objectAtIndex:j] intValue];
        }
    }
    
    NSMutableArray* arrayDistanceDTWAll = [configurationFile objectForKey:@"arrayDistanceDTWAll"];
    for (int i=0; i<4; i++) {
        NSMutableArray* arrayDistanceDTW = [arrayDistanceDTWAll objectAtIndex:i];
        for (int j=0; j<3; j++) {
            distanceDTW[i][j] = [[arrayDistanceDTW objectAtIndex:j] doubleValue];
        }
    }
    
    for (int i=0; i<4; i++) {
        variance[i] =  [[arrayVariance objectAtIndex:i] doubleValue];
        mean[i] =  [[arrayMean objectAtIndex:i] doubleValue];
    }
    
    for (int i=0; i<numberOfElements; i++) {
        templateT[i] = [[arrayTemplateT objectAtIndex:i]doubleValue];
        templateX[i] = [[arrayTemplateX objectAtIndex:i]doubleValue];
        templateY[i] = [[arrayTemplateY objectAtIndex:i]doubleValue];
        templateZ[i] = [[arrayTemplateZ objectAtIndex:i]doubleValue];
        templateCluster[i] = [[arrayTemplateC objectAtIndex:i]doubleValue];
    }
    
}


@end



/*
-(double)getProbability:(NSArray*)oneGestureDataArray{
    
    double returnValue = 0;
    
    double distanceDTWX = [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:templateX andDimension:0];
    double distanceDTWY = [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:templateY andDimension:1];
    double distanceDTWZ = [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:templateZ andDimension:2];
    //double distanceCluster = [self calculateDistance:[oneGestureDataArray objectAtIndex:4] andTemplate:templateCluster];
    //double sumOrVariance = variance[0] + variance[1] +  variance[2];
    
    //double maxVariance =MAX( MAX(variance[0], variance[1]),variance[2]);
    //double factorVariance = 1 / maxVariance;
    //returnValue = variance[0] * distanceDTWX + variance[1] * distanceDTWY + variance[2] *distanceDTWZ ;//+ distanceCluster;
    
    //distanceDTWX += [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:upperLimit[0] andDimension:0];
    //distanceDTWX += [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:lowerLimit[0] andDimension:0];
    //distanceDTWY += [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:upperLimit[1] andDimension:1];
    //distanceDTWY += [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:lowerLimit[1] andDimension:1];
    //distanceDTWZ += [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:upperLimit[2] andDimension:2];
    //distanceDTWZ += [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:lowerLimit[2] andDimension:2];
    
    returnValue = distanceDTWX + distanceDTWY + distanceDTWZ ;//+ distanceCluster;
    //double distanceDTWX = MIN(MIN([self calculateDTWDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:templateX andDimension:0], [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:upperLimit[0] andDimension:0]), [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:lowerLimit[0] andDimension:0]);
    
    //double distanceDTWY = MIN(MIN([self calculateDTWDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:templateY andDimension:1], [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:upperLimit[1] andDimension:1]), [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:lowerLimit[1] andDimension:1]);
    
    //double distanceDTWZ = MIN(MIN([self calculateDTWDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:templateZ andDimension:2], [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:upperLimit[2] andDimension:2]), [self calculateDTWDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:lowerLimit[2] andDimension:2]);
    
    //double distanceX = MIN(MIN([self calculateDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:templateX], [self calculateDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:upperLimit[0]] ), [self calculateDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:lowerLimit[0]] );
    
    //double distanceY = MIN(MIN([self calculateDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:templateY], [self calculateDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:upperLimit[1]] ), [self calculateDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:lowerLimit[1]] );
    
    //double distanceZ = MIN(MIN([self calculateDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:templateZ], [self calculateDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:upperLimit[2]] ), [self calculateDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:lowerLimit[2]] );
    
    
    //returnValue += distanceX + distanceY + distanceZ ;
    //returnValue = (variance[0]/sumOrVariance * distanceDTWX) + (variance[1]/sumOrVariance * distanceDTWY) + (variance[2]/sumOrVariance *distanceDTWZ) ;
    //returnValue = (factorVariance * variance[0] * distanceDTWX) + (factorVariance * variance[1]* distanceDTWY) + (factorVariance * variance[2] * distanceDTWZ) ;
    //returnValue += [self getSumMeanDifference:oneGestureDataArray] * 1 ; 
    //returnValue += [self getSumVarianceDifference:oneGestureDataArray] * 1;
    //returnValue += [self getLengthDifference:oneGestureDataArray] * 1;
    //returnValue += [self calculateDistance:oneGestureDataArray];
    //double distanceX = [self calculateDistance:[oneGestureDataArray objectAtIndex:1] andTemplate:templateX];
    //double distanceY = [self calculateDistance:[oneGestureDataArray objectAtIndex:2] andTemplate:templateY];
    //double distanceZ = [self calculateDistance:[oneGestureDataArray objectAtIndex:3] andTemplate:templateZ];
    //returnValue += [self calculateLBKeoghDistance:oneGestureDataArray];
    
    //returnValue += distanceX + distanceY + distanceZ ;
    //returnValue += (variance[0]/sumOrVariance * distanceX) + (variance[1]/sumOrVariance * distanceY) + (variance[2]/sumOrVariance *distanceZ) ;
    
    NSLog(@"distanceX: %g,distanceX: %g,distanceX: %g,Mean Difference Sum: %g, Variance Difference Sum: %g, Length Difference: %g", distanceX, distanceY, distanceZ,[self getSumMeanDifference:oneGestureDataArray], [self getSumVarianceDifference:oneGestureDataArray], [self getLengthDifference:oneGestureDataArray]);
     NSString* logString = [NSString stringWithFormat:@"- Model Probability : %g ; \n", modelProbability];
     for (int i=0; i<4; i++) {
     logString = [logString stringByAppendingFormat:@"Dimension: %d, Variance: %g, Mean: %g \n",i, variance[i], mean[i]];
     }
     NSLog(@"%@", logString);
     
    if (returnValue==0.0) {
        returnValue = 1;
    }
    
    //returnValue = 1/returnValue;
    returnValue = (500000 - returnValue)/500000;
    if (returnValue<0) {
        NSLog(@"%g", returnValue);
    }
    return returnValue;
}


-(double)calculateDTWDistance:(NSArray*)oneSequenceArray andTemplate:(double*)templateArray andDimension:(int)dimension{
    double returnValueDistance = 0.0;
    double** distanceArray = [self getNewDoubleArray:[oneSequenceArray count] andSecondDimension:numberOfElements];
    double cost = 0.0;
    
    double slopeSequence = 0.0;
    double slopeTemplate = 0.0;
    
    for(int i=1;i<numberOfElements;i++){
        distanceArray[0][i] = MAXFLOAT;
    }
    for (int i=1; i<[oneSequenceArray count]; i++) {
        distanceArray[i][0] = MAXFLOAT;
    }
    
    distanceArray[0][0] = 0.0;
    
    for (int i=1; i<[oneSequenceArray count]; i++) {
        for(int j=1;j<numberOfElements;j++){
            slopeSequence = [[oneSequenceArray objectAtIndex:i] doubleValue] - [[oneSequenceArray objectAtIndex:i-1] doubleValue];
            slopeTemplate = templateArray[j] - templateArray[j-1];
            
            
            cost = fabs([[oneSequenceArray objectAtIndex:i] doubleValue]-templateArray[j]);
            //cost = pow([[oneSequenceArray objectAtIndex:i] doubleValue]-templateArray[j], 2);
            //cost = pow([[oneSequenceArray objectAtIndex:i] doubleValue]-templateArray[j], 2);
            //if (cost<=2) {
            //    cost=0;
            //}
            //cost *= fabs(slopeSequence - slopeTemplate);
            //cost = cost + (fabs(slopeSequence - slopeTemplate) * 5); // 1:.32, 2:.23
            
            if (slopeSequence!=0.0 && isgreater(slopeSequence, 0) == isgreater(slopeTemplate, 0) && fabs(slopeSequence-slopeTemplate)>1  && cost < 4) {
                //cost=0;
                //cost = cost*15; // 2:.77, 3:.75, 4:.77, 5:.77, 10:.79, 15:.77 
                //cost = cost + (cost * fabs(slopeSequence - slopeTemplate) * 10);
                //cost =  cost + (cost * (fabs(slopeSequence - slopeTemplate)+1));
            }
            else if(i==j && cost < varianceAll[dimension][j]) { // variance[dimension]  
                //cost = 0;
            }
            if (abs(i-j)<=warpingWindowSize[dimension]) {
                distanceArray[i][j] = cost + MIN( MIN(distanceArray[i-1][j], distanceArray[i][j-1]), distanceArray[i-1][j-1]);
            }
            else{
                distanceArray[i][j] = MAXFLOAT;
            }
            //distanceArray[i][j] = cost + MIN( MIN(distanceArray[i-1][j], distanceArray[i][j-1]), distanceArray[i-1][j-1]);
            //distanceArray[i][j] = cost + MIN( MIN(distanceArray[i-1][j]+4, distanceArray[i][j-1]+4), distanceArray[i-1][j-1]);
        }
    }
    // NSLog(@"DTW matrix: %@",[self toStringDoubleArray:distanceCluster andFirstDimension:[oneSequenceArray count] andSecondDimension:numberOfElements]);
    returnValueDistance = distanceArray[[oneSequenceArray count]-1][numberOfElements-1];
    [self freeArray:distanceArray andFirstDimension:[oneSequenceArray count]];
    return returnValueDistance;
}

 -(void)preprocessData:(NSArray*)oneSequenceDataArray andDimension:(int)dimension{
 
 double currentMean = 0.0;
 double currentVariance= 0.0;
 
 double diffMeanData  = 0.0;
 double factorVarianceData  = 0.0;
 
 double pointValue = 0.0;
 
 // Calculating the mean points
 NSArray* dataArray = oneSequenceDataArray;
 if (dataArray!= nil &&  [dataArray count]>0 && [(NSMutableArray*)[dataArray objectAtIndex:0] count] > 0) {
 NSMutableArray* oneSequence = [dataArray objectAtIndex:dimension];
 for(int j=0; j<[oneSequence count]; j++) {    // the length of observations
 // we are taking the average of x, y, z, cluster values to make a template....
 currentMean += ([[oneSequence objectAtIndex:j]doubleValue] / [oneSequence count]);
 }
 
 // Calculating the variance values 
 for(int j=0; j<[oneSequence count]; j++) {    // the length of observations
 currentVariance += pow([[oneSequence objectAtIndex:j]doubleValue] - currentMean, 2) / [oneSequence count] ; // data variance
 }
 
 //currentVariance = sqrt(currentVariance); 
 currentVariance = currentVariance; 
 
 
 diffMeanData = mean[dimension] - currentMean;
 //factorVarianceData = sqrt(fabs(pow(variance[dimension], 2) / pow(currentVariance, 2)));
 
 // Test to see that we make right :) 
 //NSLog(@"1- Dimension:%d - REAL Mean: %g, Variance: %g", dimension, mean[dimension], variance[dimension]);
 //NSLog(@"1- Dimension:%d - Previous Mean: %g, Variance: %g", dimension,currentMean, currentVariance);
 
 //The variances and mean will be equal
 for(int j=0; j<[oneSequence count]; j++) {    // the length of observations
 pointValue = [[oneSequence objectAtIndex:j]doubleValue];
 if (factorVarianceData!=0.0) {
 //pointValue = factorVarianceData * (pointValue + diffMeanData);
 pointValue = mean[dimension] + (factorVarianceData * (pointValue - currentMean));
 }
 
 [oneSequence replaceObjectAtIndex:j withObject:[NSNumber numberWithDouble:pointValue]];
 }
 
 // Test to see that we make right :) 
 NSLog(@"2- Dimension:%d - REAL Mean: %g, Variance: %g", dimension, mean[dimension], variance[dimension]);
 NSLog(@"2- Dimension:%d - Previous Mean: %g, Variance: %g", dimension,currentMean, currentVariance);
 currentMean = 0.0;
 currentVariance = 0.0;
 for(int j=0; j<[oneSequence count]; j++) {    // the length of observations
 // we are taking the average of x, y, z, cluster values to make a template....
 currentMean += ([[oneSequence objectAtIndex:j]doubleValue] / [oneSequence count]);
 }
 // Calculating the variance values 
 for(int j=0; j<[oneSequence count]; j++) {    // the length of observations
 currentVariance += pow([[oneSequence objectAtIndex:j]doubleValue] - currentMean, 2) / [oneSequence count]; // data variance
 }
 currentVariance = sqrt(currentVariance); 
 NSLog(@"2- Dimension:%d - Current Mean: %g, Variance: %g", dimension,currentMean, currentVariance);
 
 
 
 } 
 
 
 }
 */
