//
//  MedianSampler.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/11/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "MedianSampler.h"


@implementation MedianSampler




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
		double amplitudeValue = 0.0;
		for(int i=0; i< sampleSize; i = i + 1){
			int sampleDataIndex = (i * ((float)sequenceLength / sampleSize)) ;
			
			NSMutableArray* tempArrayForSort_keys = [[NSMutableArray alloc]init];
			NSMutableArray* tempArrayForSort_values = [[NSMutableArray alloc]init];
			for (int j=sampleDataIndex; j<(int)((i+1) * ((float)sequenceLength / sampleSize)) && [timeArray count] > j; j++) {
				amplitudeValue = [[xArray objectAtIndex:j] doubleValue] * [[xArray objectAtIndex:j] doubleValue]  ;
				amplitudeValue += [[yArray objectAtIndex:j] doubleValue] * [[yArray objectAtIndex:j] doubleValue]  ;
				amplitudeValue += [[zArray objectAtIndex:j] doubleValue] * [[zArray objectAtIndex:j] doubleValue]  ;
				amplitudeValue = sqrt(amplitudeValue);
				
				[tempArrayForSort_keys addObject:[NSNumber numberWithInt:j]];
				[tempArrayForSort_values addObject:[NSNumber numberWithDouble:amplitudeValue]];
			}
			NSMutableDictionary* tempDictionaryForSort = [[NSMutableDictionary alloc]initWithObjects:tempArrayForSort_values forKeys:tempArrayForSort_keys];
			NSArray* tempArraySortedKeys = [tempDictionaryForSort keysSortedByValueUsingSelector:@selector(compare:)];
			sampleDataIndex = [[tempArraySortedKeys objectAtIndex: ([tempArraySortedKeys count] / 2)] intValue];
			
			[tSampleArray addObject:[timeArray objectAtIndex:sampleDataIndex]];
			[xSampleArray addObject:[xArray objectAtIndex:sampleDataIndex]];
			[ySampleArray addObject:[yArray objectAtIndex:sampleDataIndex]];
			[zSampleArray addObject:[zArray objectAtIndex:sampleDataIndex]];
			[clusterSampleArray addObject:[clusterArray objectAtIndex:sampleDataIndex]];
			
			[tempArrayForSort_keys release];
			[tempArrayForSort_values release];
			[tempDictionaryForSort release];
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
