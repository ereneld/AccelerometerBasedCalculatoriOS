//
//  KMeanCluster.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/21/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "Cluster.h"
#import "Constants.h"

@interface KMeanCluster : Cluster {

	double** centeroidMatrix;	// centeroidMatrix[0][clusterNumber] -> x value , 1-> y value, 2->z value
	double** sumXYZMatrix;		//	sumXYZMatrix[0][clusterNumber] -> total x value, 2->y, 3->z , 4-> total data point number on that cluster
	
	bool isObjectsMoving; // if there is no change while moving the operation stops
	
	ClusterInializationType clusterInializationType;
	
	double rangeXMin, rangeXMax;	//these values are used in initialization
	double rangeYMin, rangeYMax;
	double rangeZMin, rangeZMax;
	
}

-(id)initWithClusterNumber:(int)clusterSize
		andDimensionNumber:(int)clusterDimension
   andInitializationOption:(ClusterInializationType)initializationOptions 
			  andRangeXMin:(double)xMin andRangeXMax:(double)xMax  
			  andRangeYMin:(double)yMin andRangeYMax:(double)yMax  
			  andRangeZMin:(double)zMin andRangeZMax:(double)zMax;

-(void)initializeCluster;
-(void)setupCentroidMatrixWithSumMatrix;
-(int)getClosestCluster:(double)tValue andXValue:(double)xValue andYValue:(double)yValue andZValue:(double)zValue;

-(void)makeCluster:(NSArray*)gestureDataArray;		//The most general and used method

@end
