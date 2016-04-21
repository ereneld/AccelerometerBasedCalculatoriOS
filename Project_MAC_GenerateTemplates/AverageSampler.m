//
//  AverageSampler.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/11/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "AverageSampler.h"


@implementation AverageSampler

-(void)sampleGestureData:(NSArray*)dataArray{
	if (dataArray!= nil &&  [dataArray count]>0 && [(NSMutableArray*)[dataArray objectAtIndex:0] count] >= sampleSize) {
		
		NSMutableArray* tempSampleArray = [[NSMutableArray alloc]init];
		[tempSampleArray addObject:[[NSMutableArray alloc]init]];	// sample for T
		[tempSampleArray addObject:[[NSMutableArray alloc]init]];	// sample for X
		[tempSampleArray addObject:[[NSMutableArray alloc]init]];	// sample for Y
		[tempSampleArray addObject:[[NSMutableArray alloc]init]];	// sample for Z
		[tempSampleArray addObject:[[NSMutableArray alloc]init]];	// sample for Cluster
		
		NSMutableArray* timeArray = [dataArray objectAtIndex:0];
		NSMutableArray* xArray = [dataArray objectAtIndex:1];
		NSMutableArray* yArray = [dataArray objectAtIndex:2];
		NSMutableArray* zArray = [dataArray objectAtIndex:3];
		NSMutableArray* clusterArray = [dataArray objectAtIndex:4];
		
		NSMutableArray* tSampleArray = [tempSampleArray objectAtIndex:0];
		NSMutableArray* xSampleArray = [tempSampleArray objectAtIndex:1];
		NSMutableArray* ySampleArray = [tempSampleArray objectAtIndex:2];
		NSMutableArray* zSampleArray = [tempSampleArray objectAtIndex:3];
		NSMutableArray* clusterSampleArray = [tempSampleArray objectAtIndex:4];
		
		int sequenceLength = [timeArray count];
		double currentXValue=0.0;double currentYValue=0.0;double currentZValue=0.0;
		
		for(int i=0; i< sampleSize; i = i + 1){
			int sampleDataIndex = (i * ((float)sequenceLength / sampleSize)) ;
			
			currentXValue=0.0; currentYValue=0.0; currentZValue=0.0;
			for (int j=sampleDataIndex; j< (int)((i+1) * ((float)sequenceLength / sampleSize)) && [timeArray count] > j; j++) {
				
				int numberOfElementInOneSample = 0;
				if ([timeArray count] <= ((i+1) * ((float)sequenceLength / sampleSize))) {	// we are in the last portion
					numberOfElementInOneSample = [timeArray count] - sampleDataIndex ;
				}
				else {
					numberOfElementInOneSample = (int)((i+1) * ((float)sequenceLength / sampleSize)) - sampleDataIndex ;
				}

				currentXValue +=  ([(NSNumber*)[xArray objectAtIndex:j] doubleValue] / numberOfElementInOneSample);
				currentYValue += ([(NSNumber*)[yArray objectAtIndex:j] doubleValue] / numberOfElementInOneSample);
				currentZValue +=  ([(NSNumber*)[zArray objectAtIndex:j] doubleValue] / numberOfElementInOneSample);
			}
			
			[tSampleArray addObject:[timeArray objectAtIndex:sampleDataIndex]];
			[xSampleArray addObject:[NSNumber numberWithDouble:currentXValue]];
			[ySampleArray addObject:[NSNumber numberWithDouble:currentYValue]];
			[zSampleArray addObject:[NSNumber numberWithDouble:currentZValue]];
			[clusterSampleArray addObject:[clusterArray objectAtIndex:sampleDataIndex]];
			
		}
		[timeArray removeAllObjects];
		[xArray removeAllObjects];
		[yArray removeAllObjects];
		[zArray removeAllObjects];
		[clusterArray removeAllObjects];
		
		[timeArray addObjectsFromArray:tSampleArray];
		[xArray addObjectsFromArray:xSampleArray];
		[yArray addObjectsFromArray:ySampleArray];
		[zArray addObjectsFromArray:zSampleArray];
		[clusterArray addObjectsFromArray:clusterSampleArray];
		
		[tSampleArray release];
		[xSampleArray release];
		[ySampleArray release];
		[zSampleArray release];
		[clusterSampleArray release];
		[tempSampleArray release];
	}
}

@end


/*
 NSMutableArray* tempStateArray = [[NSMutableArray alloc]init];
 [tempStateArray addObject:[[NSMutableArray alloc]init]];	// state for X
 [tempStateArray addObject:[[NSMutableArray alloc]init]];	// state for Y
 [tempStateArray addObject:[[NSMutableArray alloc]init]];	// state for Z
 
 if (dataArray!= nil &&  [dataArray count]>0 && [(NSMutableArray*)[dataArray objectAtIndex:0] count] >= sampleSize) {
 
 NSMutableArray* timeArray = [dataArray objectAtIndex:0];
 NSMutableArray* xArray = [dataArray objectAtIndex:1];
 NSMutableArray* yArray = [dataArray objectAtIndex:2];
 NSMutableArray* zArray = [dataArray objectAtIndex:3];
 
 NSMutableArray* xStateArray = [tempStateArray objectAtIndex:0];
 NSMutableArray* yStateArray = [tempStateArray objectAtIndex:1];
 NSMutableArray* zStateArray = [tempStateArray objectAtIndex:2];
 
 double currentXValue=0.0;double currentYValue=0.0;double currentZValue=0.0;
 
 int numberOfQuantzs = [timeArray count] / K_TIMEAVERAGING_TIMEQUANT ;
 int lastPortionDataSize = [timeArray count] - (numberOfQuantzs*K_TIMEAVERAGING_TIMEQUANT);
 
 for(int i=0; i<[timeArray count]; i++){
 
 if ((i+1)-(numberOfQuantzs*K_TIMEAVERAGING_TIMEQUANT) > 0 && lastPortionDataSize>0) {
 currentXValue = currentXValue +  ([(NSNumber*)[xArray objectAtIndex:i] doubleValue] / lastPortionDataSize);
 currentYValue = currentYValue +  ([(NSNumber*)[yArray objectAtIndex:i] doubleValue] / lastPortionDataSize);
 currentZValue = currentZValue +  ([(NSNumber*)[zArray objectAtIndex:i] doubleValue] / lastPortionDataSize);
 }
 else {
 currentXValue = currentXValue +  ([(NSNumber*)[xArray objectAtIndex:i] doubleValue] / K_TIMEAVERAGING_TIMEQUANT);
 currentYValue = currentYValue +  ([(NSNumber*)[yArray objectAtIndex:i] doubleValue] / K_TIMEAVERAGING_TIMEQUANT);
 currentZValue = currentZValue +  ([(NSNumber*)[zArray objectAtIndex:i] doubleValue] / K_TIMEAVERAGING_TIMEQUANT);
 }
 
 if (((i+1) % K_TIMEAVERAGING_TIMEQUANT)==0 ) { //Next quantization
 for(int j=0; j< K_TIMEAVERAGING_TIMEQUANT ; j++){
 [xStateArray addObject:[[NSNumber alloc] initWithDouble:currentXValue]];
 [yStateArray addObject:[[NSNumber alloc] initWithDouble:currentYValue]];
 [zStateArray addObject:[[NSNumber alloc] initWithDouble:currentZValue]];
 }
 currentXValue=0.0; currentYValue=0.0; currentZValue=0.0;
 }
 
 if ((i == [timeArray count]-1) && ( lastPortionDataSize > 0)) { //if last portion exp. 62 data point but we got till 60 because of time quant is 10 -> so we got 2 of them
 for(int j=0; j<  lastPortionDataSize ; j++){
 [xStateArray addObject:[[NSNumber alloc] initWithDouble:currentXValue]];
 [yStateArray addObject:[[NSNumber alloc] initWithDouble:currentYValue]];
 [zStateArray addObject:[[NSNumber alloc] initWithDouble:currentZValue]];	
 
 }
 currentXValue=0.0; currentYValue=0.0; currentZValue=0.0;
 } 
 }
 [xArray removeAllObjects];
 [yArray removeAllObjects];
 [zArray removeAllObjects];
 
 [xArray addObjectsFromArray:xStateArray];
 [yArray addObjectsFromArray:yStateArray];
 [zArray addObjectsFromArray:zStateArray];
 }
 [tempStateArray release];
 */