//
//  TrajectoryAngleQuantization.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/21/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "Cluster.h"

//it is used for clustering the data according to 2D or 3D trajectory angles (the angeles defined by the demanded cluster number)
@interface TrajectoryAngleQuantization : Cluster {
	int numberOfSplitInXY;
	int numberOfSplitInXZ;
	int numberOfSplitInYZ;
	
	double angleOfSplitInXY; //Degree of angle
	double angleOfSplitInXZ;
	double angleOfSplitInYZ;
	
	NSMutableDictionary* dictionaryClusterIndex;
}

-(id)initWithSplitValues:(int)splitXY 
			  andsplitXZ:(int)splitXZ 
			  andsplitYZ:(int)splitYZ;
-(int)getNumberOfCluster;
@end
