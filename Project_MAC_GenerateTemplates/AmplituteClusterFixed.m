//
//  AmplituteCluster.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/19/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "AmplituteClusterFixed.h"
#import "GestureData.h"

@implementation AmplituteClusterFixed


// amp > 2g cluster: 32 -> 1 cluster 
// 2g > amp > 1g , cluster 27-31  -> 5 cluster
// 1g > amp > 0 , cluster 17-26 -> 10 cluster
//  amp = 0 , cluster 17	-> 0 cluster
// 0 > amp > -1g , cluster 7 - 16 -> 10 cluster
// -1g > amp > -2g , cluster 2 - 6 -> 5 cluster
// -2g > amp , cluster 1 -> 1 cluster

-(void)makeCluster:(NSArray*)gestureDataArray{
	
	double currentXValue=0.0;double currentYValue=0.0;double currentZValue=0.0;
	double amplitude=0.0;
	int clusterIndex=0;
	
	for (GestureData* gestureData in gestureDataArray) {
		NSArray* dataArray = gestureData.gestureData;
		
		NSMutableArray* timeArray = [dataArray objectAtIndex:0];
		NSMutableArray* xArray = [dataArray objectAtIndex:1];
		NSMutableArray* yArray = [dataArray objectAtIndex:2];
		NSMutableArray* zArray = [dataArray objectAtIndex:3];
		NSMutableArray* clusterArray = [dataArray objectAtIndex:4];
		
		for (int i=0; i<[timeArray count]; i++) {
			currentXValue = [(NSNumber*)[xArray objectAtIndex:i] doubleValue];
			currentYValue = [(NSNumber*)[yArray objectAtIndex:i] doubleValue];
		    currentZValue = [(NSNumber*)[zArray objectAtIndex:i] doubleValue];
			
			amplitude = currentXValue*currentXValue;
			amplitude += currentYValue*currentYValue;
			amplitude += currentZValue*currentZValue;
			amplitude = sqrt(amplitude);
			
			if (currentYValue < 0) {
				amplitude = -1 * amplitude;
			}
			
			if (amplitude>=2) {
				clusterIndex = 32;
			}
			else if(amplitude>=1) {
				clusterIndex = 27 + ((amplitude-1.0) / 0.2);
			}
			else if(amplitude>=0) {
				clusterIndex = 17 + (amplitude / 0.1);
			}
			else if(amplitude>=-1) {
				clusterIndex = 17 + (amplitude / 0.1);
			}
			else if(amplitude>=-2) {
				clusterIndex = 7 + ((amplitude+1.0) / 0.2);
			}
			else {
				clusterIndex = 1;
			}			
			
			[clusterArray replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:clusterIndex]];
		}
	}
}

@end
