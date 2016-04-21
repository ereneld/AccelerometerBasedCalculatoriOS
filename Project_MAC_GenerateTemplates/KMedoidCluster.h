//
//  KMedoidCluster.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/21/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cluster.h"

 
@interface KMedoidCluster : Cluster {

	double** medoidMatrix;		// medoidMatrix[0][clusterNumber] -> x value , 1-> y value, 2->z value
	double** sumXYZMatrix;		//	sumXYZMatrix[0][clusterNumber] -> total x value, 2->y, 3->z , 4-> total data point number on that cluster
	
	bool isObjectsMoving; // if there is no change while moving the operation stops
}

-(void)makeCluster:(NSArray*)gestureDataArray;		//The most general and used method

-(id)initWithClusterNumber:(int)clusterSize andDimensionNumber:(int)clusterDimension;
-(void)initializeClusterMedoids:(NSArray*)allGestureData;

-(void)setupMedoidMatrixWithSumMatrix:(NSArray*)allGestureData;
-(int)getClosestCluster:(double)tValue andXValue:(double)xValue andYValue:(double)yValue andZValue:(double)zValue;
-(void)setupMedoidMatrixWithSumMatrix:(NSArray*)allGestureData;


-(NSString*)getMedoidString;
-(int)getUsedClusterNumber;


@end
