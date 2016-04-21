//
//  TrajectoryAngleQuantization.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/21/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "TrajectoryAngleQuantization.h"
#import "GestureData.h"

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

@implementation TrajectoryAngleQuantization


-(id)initWithSplitValues:(int)splitXY 
			  andsplitXZ:(int)splitXZ 
			  andsplitYZ:(int)splitYZ {
    self = [super init];
	if(self)
	{
		numberOfSplitInXY=splitXY;
		numberOfSplitInXZ=splitXZ;
		numberOfSplitInYZ=splitYZ;
		
		angleOfSplitInXY = 360.0 / splitXY;
		angleOfSplitInXZ = 360.0 / splitXZ;
		angleOfSplitInYZ = 360.0 / splitYZ;
		
		dictionaryClusterIndex = [[NSMutableDictionary alloc]initWithCapacity:splitXY*splitXZ*splitYZ];
		
		int clusterIndex = 1;
		for (int i=0; i<splitXY; i++) {
			for (int j=0; j<splitXZ; j++) {
				for (int k=0; k<splitYZ; k++) {
					[dictionaryClusterIndex setObject:[NSNumber numberWithInt:clusterIndex] forKey:[NSString stringWithFormat:@"%d%d%d",i,j,k]];
					clusterIndex++;
				}
			}
		}
	}
	
	return self;
}

-(int)getNumberOfCluster{
	return numberOfSplitInXY*numberOfSplitInXZ*numberOfSplitInYZ;
}

-(void)makeCluster:(NSArray*)gestureDataArray{

    double previousXValue=0.0;double previousYValue=0.0;double previousZValue=0.0;
	double currentXValue=0.0;double currentYValue=0.0;double currentZValue=0.0;
	double angleXY=0.0; double angleXZ=0.0; double angleYZ=0.0; 
	int clusterXY=0;int clusterXZ=0;int clusterYZ=0;
	int clusterIndex=0;
	
	for (GestureData* gestureData in gestureDataArray) {
		NSArray* dataArray = gestureData.gestureData;
		
		NSMutableArray* timeArray = [dataArray objectAtIndex:0];
		NSMutableArray* xArray = [dataArray objectAtIndex:1];
		NSMutableArray* yArray = [dataArray objectAtIndex:2];
		NSMutableArray* zArray = [dataArray objectAtIndex:3];
		NSMutableArray* clusterArray = [dataArray objectAtIndex:4];
		
        previousXValue = [(NSNumber*)[xArray objectAtIndex:0] doubleValue];
        previousYValue = [(NSNumber*)[yArray objectAtIndex:0] doubleValue];
        previousZValue = [(NSNumber*)[zArray objectAtIndex:0] doubleValue];
        
		for (int i=1; i<[timeArray count]; i++) {
			currentXValue = [(NSNumber*)[xArray objectAtIndex:i] doubleValue];
			currentYValue = [(NSNumber*)[yArray objectAtIndex:i] doubleValue];
		    currentZValue = [(NSNumber*)[zArray objectAtIndex:i] doubleValue];
															   
			angleXY =  RadiansToDegrees(atan2(currentYValue-previousYValue, currentXValue-previousXValue)) + 180;
			angleXZ =  RadiansToDegrees(atan2(currentZValue-previousZValue, currentXValue-previousXValue)) + 180;
			angleYZ =  RadiansToDegrees(atan2(currentZValue-previousZValue, currentYValue-previousYValue)) + 180;	
															   
			clusterXY = (angleXY / angleOfSplitInXY);
			clusterXZ = (angleXZ / angleOfSplitInXZ);
			clusterYZ = (angleYZ / angleOfSplitInYZ);
			clusterIndex = [[dictionaryClusterIndex objectForKey:[NSString stringWithFormat:@"%d%d%d",clusterXY,clusterXZ,clusterYZ]] intValue];
			
			//NSLog(@"%g, %g, %g -> Cluster: %d", angleXY, angleXZ, angleYZ, clusterIndex);
			[clusterArray replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:clusterIndex]];
            
            previousXValue = currentXValue;
            previousYValue = currentYValue;
            previousZValue = currentZValue;
		}
	}
}

@end
