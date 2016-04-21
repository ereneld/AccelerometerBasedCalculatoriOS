//
//  MiddleSampler.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/11/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "MiddleSampler.h"


@implementation MiddleSampler

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
		for(int i=0; i< sampleSize; i = i + 1){
			int sampleDataIndex = (i * ((float)sequenceLength / sampleSize)) + (int)(((float)sequenceLength / sampleSize) / 2) ;
			
			[tSampleArray addObject:[timeArray objectAtIndex:sampleDataIndex]];
			[xSampleArray addObject:[xArray objectAtIndex:sampleDataIndex]];
			[ySampleArray addObject:[yArray objectAtIndex:sampleDataIndex]];
			[zSampleArray addObject:[zArray objectAtIndex:sampleDataIndex]];
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
