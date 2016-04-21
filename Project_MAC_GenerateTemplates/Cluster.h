//
//  Cluster.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/21/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GestureData.h"

@class DataSet;
@interface Cluster : NSObject {
	int numberOfDataDimension; //here; mostly, we are using 3 dimension -> X , Y , Z
	int numberOfCluster;	//the total number of cluster -> max limit of it, it may less than it
}

@property(nonatomic, assign)int numberOfDataDimension;
@property(nonatomic, assign)int numberOfCluster;

+(Cluster*) getCluster;
+(void) reset;
+(void)clusterDataSet:(DataSet*)currentDataSet;
+(void)clusterGestureData:(GestureData*)currentGestureData;

@end
