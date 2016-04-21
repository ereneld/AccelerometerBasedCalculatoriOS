//
//  ClusterDynamic.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 4/20/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "ClusterDynamic.h"
#import "GestureData.h"
#import "ConfigurationManager.h"
#import "Constants.h"

@implementation ClusterDynamic

-(void)prepareAmplituteSplitList:(NSArray*)gestureDataArray{
    if(!amplituteSplitList){
        xSplitList= [[NSMutableArray alloc]init];
        ySplitList= [[NSMutableArray alloc]init];
        zSplitList= [[NSMutableArray alloc]init];
        amplituteSplitList = [[NSMutableArray alloc]init];
        
        NSMutableArray* xList = [[NSMutableArray alloc]init];
        NSMutableArray* yList = [[NSMutableArray alloc]init];
        NSMutableArray* zList = [[NSMutableArray alloc]init];
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
                
                [xList addObject:[NSNumber numberWithDouble:currentXValue]];
                [yList addObject:[NSNumber numberWithDouble:currentYValue]];
                [zList addObject:[NSNumber numberWithDouble:currentZValue]];
                
                amplitude = currentXValue*currentXValue;
                amplitude += currentYValue*currentYValue;
                amplitude += currentZValue*currentZValue;
                // We are not taking the sqroot of amplitute, because we are using it just for clustering and sorting, so we don't need this operation
                // Note : We will not use while online recognition
                [amplituteList addObject:[NSNumber numberWithDouble:amplitude]];
                
            }
        }
        
        [xList sortUsingSelector:@selector(compare:)];
        [yList sortUsingSelector:@selector(compare:)];
        [zList sortUsingSelector:@selector(compare:)];
        [amplituteList sortUsingSelector:@selector(compare:)];
        splitSize = [amplituteList count] / numberOfCluster;
        
        for (int j=0; j<numberOfCluster; j++) {
            [xSplitList addObject:[NSNumber numberWithDouble:[[xList objectAtIndex:j*splitSize] doubleValue]]];
            [ySplitList addObject:[NSNumber numberWithDouble:[[yList objectAtIndex:j*splitSize] doubleValue]]];
            [zSplitList addObject:[NSNumber numberWithDouble:[[zList objectAtIndex:j*splitSize] doubleValue]]];
            [amplituteSplitList addObject:[NSNumber numberWithDouble:[[amplituteList objectAtIndex:j*splitSize] doubleValue]]];
        }
        
        [xList removeAllObjects];
        [xList release];
        [yList removeAllObjects];
        [yList release];
        [zList removeAllObjects];
        [zList release];
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
    int xIndex = 0;int yIndex = 0;int zIndex = 0;int clusterIndex = 0;
    
	[self prepareAmplituteSplitList:gestureDataArray];
	
	for (GestureData* gestureData in gestureDataArray) {
		NSArray* dataArray = gestureData.gestureData;
		NSMutableArray* timeArray = [dataArray objectAtIndex:0];
		NSMutableArray* xArray = [dataArray objectAtIndex:1];
		NSMutableArray* yArray = [dataArray objectAtIndex:2];
		NSMutableArray* zArray = [dataArray objectAtIndex:3];
		NSMutableArray* clusterArray = [dataArray objectAtIndex:4];
		
		for (int i=0; i<[timeArray count]; i++) {
			xIndex = 0; yIndex = 0; zIndex = 0;clusterIndex = 0;
            
			currentXValue = [(NSNumber*)[xArray objectAtIndex:i] doubleValue];
			currentYValue = [(NSNumber*)[yArray objectAtIndex:i] doubleValue];
		    currentZValue = [(NSNumber*)[zArray objectAtIndex:i] doubleValue];
			
			amplitude = currentXValue*currentXValue;
			amplitude += currentYValue*currentYValue;
			amplitude += currentZValue*currentZValue;
			
			for (int j=0; j<numberOfCluster; j++) {
				if (currentXValue > [[xSplitList objectAtIndex:j] doubleValue]) {
					xIndex = j + 1;
				}
                if (currentYValue > [[ySplitList objectAtIndex:j] doubleValue]) {
					yIndex = j + 1;
				}
                if (currentZValue > [[zSplitList objectAtIndex:j] doubleValue]) {
					zIndex = j + 1;
				}
                if (amplitude > [[amplituteSplitList objectAtIndex:j] doubleValue]) {
					clusterIndex = j + 1;
				}
                
			}
			[xArray replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:xIndex]];
            [yArray replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:yIndex]];
            [zArray replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:zIndex]];
			[clusterArray replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:clusterIndex]];
		}
	}
	
	[ConfigurationManager addConfiguration:[self getConfiguration] andName:KC_CLUSTER];
}

-(NSDictionary*)getConfiguration{
    
    NSMutableDictionary* clusterConfiguration = [[NSMutableDictionary alloc]init];
    [clusterConfiguration setObject:xSplitList forKey:@"xSplitList"];
    [clusterConfiguration setObject:ySplitList forKey:@"ySplitList"];
    [clusterConfiguration setObject:zSplitList forKey:@"zSplitList"];
    [clusterConfiguration setObject:amplituteSplitList forKey:@"amplituteSplitList"];
    return clusterConfiguration;
}

-(void)loadConfiguration:(NSDictionary*)configurationFile{
    xSplitList = [[NSMutableArray alloc]initWithArray:[configurationFile objectForKey:@"xSplitList"]];
    ySplitList = [[NSMutableArray alloc]initWithArray:[configurationFile objectForKey:@"ySplitList"]];
    zSplitList = [[NSMutableArray alloc]initWithArray:[configurationFile objectForKey:@"zSplitList"]];
    amplituteSplitList = [[NSMutableArray alloc]initWithArray:[configurationFile objectForKey:@"amplituteSplitList"]];
}


@end
