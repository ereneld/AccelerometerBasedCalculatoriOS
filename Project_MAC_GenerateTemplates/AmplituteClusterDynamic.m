//
//  AmplituteClusterDynamic.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/26/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "AmplituteClusterDynamic.h"
#import "GestureData.h"
#import "ConfigurationManager.h"
#import "Constants.h"

@implementation AmplituteClusterDynamic

-(void)prepareAmplituteSplitList:(NSArray*)gestureDataArray{
    if(!amplituteSplitList){
        amplituteSplitList = [[NSMutableArray alloc]init];
        NSMutableArray* amplituteList = [[NSMutableArray alloc]init];
        
        double currentXValue=0.0;double currentYValue=0.0;double currentZValue=0.0;
        double amplitude=0.0;
        int splitSize = 0;
        for (GestureData* gestureData in gestureDataArray) {
            NSArray* dataArray = gestureData.gestureData;
            NSMutableArray* timeArray = [dataArray objectAtIndex:0];
            NSMutableArray* xArray = [dataArray objectAtIndex:1];
            NSMutableArray* yArray = [dataArray objectAtIndex:2];
            NSMutableArray* zArray = [dataArray objectAtIndex:3];
            
            for (int i=0; i<[timeArray count]; i++) {
                currentXValue = [(NSNumber*)[xArray objectAtIndex:i] doubleValue];
                currentYValue = [(NSNumber*)[yArray objectAtIndex:i] doubleValue];
                currentZValue = [(NSNumber*)[zArray objectAtIndex:i] doubleValue];
                
                amplitude = currentXValue*currentXValue;
                amplitude += currentYValue*currentYValue;
                amplitude += currentZValue*currentZValue;
                // We are not taking the sqroot of amplitute, because we are using it just for clustering and sorting, so we don't need this operation
                // Note : We will not use while online recognition
                [amplituteList addObject:[NSNumber numberWithDouble:amplitude]];
                
            }
        }
        
        [amplituteList sortUsingSelector:@selector(compare:)];
        splitSize = [amplituteList count] / numberOfCluster;
        
        for (int j=0; j<numberOfCluster; j++) {
            [amplituteSplitList addObject:[NSNumber numberWithDouble:[[amplituteList objectAtIndex:j*splitSize] doubleValue]]];
        }
        [amplituteList removeAllObjects];
        [amplituteList release];
    }
    else{
        //do nothing -> it means that it is ready from loading
    }
    
}

-(void)makeCluster:(NSArray*)gestureDataArray{
    double currentXValue=0.0;double currentYValue=0.0;double currentZValue=0.0;
    double amplitude=0.0;
    double amplitudeSplit=0.0;
    int clusterIndex = 0;
    
	[self prepareAmplituteSplitList:gestureDataArray];
	
	for (GestureData* gestureData in gestureDataArray) {
		NSArray* dataArray = gestureData.gestureData;
		NSMutableArray* timeArray = [dataArray objectAtIndex:0];
		NSMutableArray* xArray = [dataArray objectAtIndex:1];
		NSMutableArray* yArray = [dataArray objectAtIndex:2];
		NSMutableArray* zArray = [dataArray objectAtIndex:3];
		NSMutableArray* clusterArray = [dataArray objectAtIndex:4];
		
		for (int i=0; i<[timeArray count]; i++) {
			clusterIndex = 0;
            
			currentXValue = [(NSNumber*)[xArray objectAtIndex:i] doubleValue];
			currentYValue = [(NSNumber*)[yArray objectAtIndex:i] doubleValue];
		    currentZValue = [(NSNumber*)[zArray objectAtIndex:i] doubleValue];
			
			amplitude = currentXValue*currentXValue;
			amplitude += currentYValue*currentYValue;
			amplitude += currentZValue*currentZValue;
			
			for (int j=0; j<numberOfCluster; j++) {
				amplitudeSplit = [[amplituteSplitList objectAtIndex:j] doubleValue];
				if (amplitude > amplitudeSplit) {
					clusterIndex = j + 1;
				}
				else {
					break;
				}

			}
			
			[clusterArray replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:clusterIndex]];
		}
	}
	
	[ConfigurationManager addConfiguration:[self getConfiguration] andName:KC_CLUSTER];
}

-(NSDictionary*)getConfiguration{
    
    NSMutableDictionary* clusterConfiguration = [[NSMutableDictionary alloc]init];
    
    [clusterConfiguration setObject:amplituteSplitList forKey:@"amplituteSplitList"];
    return clusterConfiguration;
}

-(void)loadConfiguration:(NSDictionary*)configurationFile{
     amplituteSplitList = [[NSMutableArray alloc]initWithArray:[configurationFile objectForKey:@"amplituteSplitList"]];
}


@end
