//
//  NoiseEliminator.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/11/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "NoiseEliminator.h"

static NoiseEliminator* instanceObjectNoiseEliminator; //singleton object

static int numberOfNoiseAmplituteMin = 0;
static int numberOfNoiseAmplituteMax = 0;
static int numberOfNoiseLengthMin = 0;
static int numberOfNoiseLengthMax = 0;

static BOOL showNoiseLengthLog = YES;

@implementation NoiseEliminator


+(void)eliminateNoiseFromDataSet:(DataSet*)currentDataSet{
	if (!instanceObjectNoiseEliminator) {
		instanceObjectNoiseEliminator = [[NoiseEliminator alloc]init];
	}

    int totalElementNumber = 0;
	if ([ConfigurationManager getParameterValue:KPN_NOISEELIMINATOR_DATAAVERAGEAMPLITUTE]) {
        for(NSArray* gestureDataArray in currentDataSet.gestureDataArray){
             totalElementNumber += [gestureDataArray count];
            [instanceObjectNoiseEliminator eliminateAverageAmplituteNoise:gestureDataArray];
        }
	}
	if ([ConfigurationManager getParameterValue:KPN_NOISEELIMINATOR_DATALENGTH]) {
        for(NSArray* gestureDataArray in currentDataSet.gestureDataArray){
           [instanceObjectNoiseEliminator eliminateSampleLengthNoise:gestureDataArray];
        }
	}
     if (showNoiseLengthLog) {
    NSLog(@"Noise Elimination Result (%d) : %d - %d Amplitute, %d - %d length", totalElementNumber, numberOfNoiseAmplituteMin, numberOfNoiseAmplituteMax, numberOfNoiseLengthMin, numberOfNoiseLengthMax);
     }
    
    numberOfNoiseAmplituteMin = 0;
    numberOfNoiseAmplituteMax = 0;
    numberOfNoiseLengthMin = 0;
    numberOfNoiseLengthMax = 0;
}


+(void)eliminateNoiseFromGestureData:(GestureData*)currentGestureData{
    if (!instanceObjectNoiseEliminator) {
		instanceObjectNoiseEliminator = [[NoiseEliminator alloc]init];
	}
    NSMutableArray* tempArray = [[NSMutableArray alloc]initWithCapacity:1];
    [tempArray addObject:currentGestureData];
    
	if ([ConfigurationManager getParameterValue:KPN_NOISEELIMINATOR_DATAAVERAGEAMPLITUTE]) {
		[instanceObjectNoiseEliminator eliminateAverageAmplituteNoise:tempArray];
	}
	if ([ConfigurationManager getParameterValue:KPN_NOISEELIMINATOR_DATALENGTH]) {
		[instanceObjectNoiseEliminator eliminateSampleLengthNoise:tempArray];
	}
    
    if ([tempArray count]==0) { //the data is eliminated 
        [[currentGestureData.gestureData objectAtIndex:0]removeAllObjects];
        [[currentGestureData.gestureData objectAtIndex:1]removeAllObjects];
        [[currentGestureData.gestureData objectAtIndex:2]removeAllObjects];
        [[currentGestureData.gestureData objectAtIndex:3]removeAllObjects];
        [[currentGestureData.gestureData objectAtIndex:4]removeAllObjects];
    }
    
    [tempArray removeAllObjects];
    [tempArray release];
    tempArray = nil;
    
}

//The data with average amplitute lower than given value (min limit) or greater than given value (max limit) will be eliminated
-(void)eliminateAverageAmplituteNoise:(NSMutableArray*)gestureDataArray{
	
	double amplitudeValue=0.0;
	double totalAvergeAmplitudeValue=0.0;
	double amplituteMinValue = [ConfigurationManager getParameterValue:KPN_NOISEELIMINATOR_MIN_AVERAGE_AMP];
	double amplituteMaxValue = [ConfigurationManager getParameterValue:KPN_NOISEELIMINATOR_MAX_AVERAGE_AMP];
	
	
	NSMutableArray* timeArray = nil;
	NSMutableArray* xArray = nil;
	NSMutableArray* yArray = nil;
	NSMutableArray* zArray = nil;
	NSMutableArray* clusterArray = nil;
	
	for (int i=0; i<[gestureDataArray count]; i++) {
        GestureData* tempGestureData = ((GestureData*)[gestureDataArray objectAtIndex:i]);
		NSArray* dataArray = tempGestureData.gestureData;
		timeArray = [dataArray objectAtIndex:0];
		xArray = [dataArray objectAtIndex:1];
		yArray = [dataArray objectAtIndex:2];
		zArray = [dataArray objectAtIndex:3];
		clusterArray = [dataArray objectAtIndex:4];
		
		totalAvergeAmplitudeValue = 0.0;
		for (int j=0; j<[timeArray count]; j++) {
			amplitudeValue  = [[xArray objectAtIndex:j] doubleValue] * [[xArray objectAtIndex:j] doubleValue]  ;
			amplitudeValue += [[yArray objectAtIndex:j] doubleValue] * [[yArray objectAtIndex:j] doubleValue]  ;
			amplitudeValue += [[zArray objectAtIndex:j] doubleValue] * [[zArray objectAtIndex:j] doubleValue]  ;
			amplitudeValue = sqrt(amplitudeValue);
			totalAvergeAmplitudeValue += (amplitudeValue / [timeArray count]);
		}
		if (totalAvergeAmplitudeValue >= amplituteMinValue && totalAvergeAmplitudeValue <= amplituteMaxValue) {
			//do nothing -> the average amplitute is in range
		}
		else {
            if(totalAvergeAmplitudeValue >= amplituteMinValue){
                numberOfNoiseAmplituteMax++;
            }
            else if(totalAvergeAmplitudeValue <= amplituteMinValue){
                numberOfNoiseAmplituteMin++;
            }
            
			[gestureDataArray removeObjectAtIndex:i];
			i--; //we remove one element in array -> so loop should continue with same index
    
            if (showNoiseLengthLog) {
                NSLog(@"Eliminated Amplitute Gesture - %@", tempGestureData.gestureTitle);
            }
		}

	}
}


//The data will be eliminated if the length is lower than given value (min length) or higher than given value (max length)
-(void)eliminateSampleLengthNoise:(NSMutableArray*)gestureDataArray{

	double lengthMinValue = [ConfigurationManager getParameterValue:KPN_NOISEELIMINATOR_MIN_LENGTH];
	double lengthMaxValue = [ConfigurationManager getParameterValue:KPN_NOISEELIMINATOR_MAX_LENGTH];
    
    double lengthSecMinValue = [ConfigurationManager getParameterValue:KPN_NOISEELIMINATOR_MINTIME_LENGTH];
	double lengthSecMaxValue = [ConfigurationManager getParameterValue:KPN_NOISEELIMINATOR_MAXTIME_LENGTH];
    
    
	NSMutableArray* timeArray = nil;
	
	for (int i=0; i<[gestureDataArray count]; i++) {
		GestureData* tempGestureData = ((GestureData*)[gestureDataArray objectAtIndex:i]);
		NSArray* dataArray = tempGestureData.gestureData;
		timeArray = [dataArray objectAtIndex:0];
		
		if ([timeArray count] >= lengthMinValue && [timeArray count] <= lengthMaxValue && [[timeArray lastObject]doubleValue]>=lengthSecMinValue &&  [[timeArray lastObject]doubleValue] <= lengthSecMaxValue) {
			//do nothing -> the length of the data is in range
		}
		else {
			[gestureDataArray removeObjectAtIndex:i];
			i--; //we remove one element in array -> so loop should continue with same index
            if ([timeArray count] < lengthMinValue || [[timeArray lastObject]doubleValue]<lengthSecMinValue) {
                 numberOfNoiseLengthMin++;
                if (showNoiseLengthLog) {
                    NSLog(@"Eliminated Min Len Gesture - %@", tempGestureData.gestureTitle);
                } 
                
            }
            else{
                 numberOfNoiseLengthMax++;
                if (showNoiseLengthLog) {
                 NSLog(@"Eliminated Max Len Gesture - %@", tempGestureData.gestureTitle);
                }
            }
           
		}
	}
}

-(void) dealloc{
	[instanceObjectNoiseEliminator release];
	[super dealloc];
}

@end
