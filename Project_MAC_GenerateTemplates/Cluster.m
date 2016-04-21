//
//  Cluster.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/21/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "Cluster.h"
#import "Constants.h"
#import "ConfigurationManager.h"
#import "GestureData.h"
#import "DataSet.h"

#import "KMeanCluster.h"
#import "KMedoidCluster.h"
#import "TrajectoryAngleQuantization.h"
#import "AmplituteClusterFixed.h"
#import "AmplituteClusterDynamic.h"
#import "ClusterDynamic.h"

static Cluster* instanceObjectCluster; //singleton object

//Hidden methods ! -> to use for instance object
@interface Cluster (PrivateMethods)

-(void)clusterDataSet:(DataSet*)currentDataSet;
-(void)makeCluster:(NSArray*)gestureDataArray; //should be defined in each clustering algorithm

-(NSDictionary*)getConfiguration;
-(void)loadConfiguration:(NSDictionary*)configurationFile;
@end

@implementation Cluster

@synthesize numberOfDataDimension, numberOfCluster;

+(Cluster*) getCluster{
	if (!instanceObjectCluster) {
		switch ((int)[ConfigurationManager getParameterValue:KPN_CLUSTER_TYPE]) {
			case ClusterTypeNONE:
				instanceObjectCluster = nil;
				break;
			case ClusterTypeKMeans:
				instanceObjectCluster = [[KMeanCluster alloc] 
										  initWithClusterNumber:[ConfigurationManager getParameterValue:KPN_CLUSTER_NUMBER] 
										  andDimensionNumber:[ConfigurationManager getParameterValue:KPN_CLUSTER_DIMENSION] 
										  andInitializationOption:[ConfigurationManager getParameterValue:KPN_CLUSTER_INITIALIZATION] 
										  andRangeXMin:[ConfigurationManager getParameterValue:KPN_CLUSTER_RANGE_MIN_X] 
										  andRangeXMax:[ConfigurationManager getParameterValue:KPN_CLUSTER_RANGE_MAX_X] 
										  andRangeYMin:[ConfigurationManager getParameterValue:KPN_CLUSTER_RANGE_MIN_Y] 
										  andRangeYMax:[ConfigurationManager getParameterValue:KPN_CLUSTER_RANGE_MAX_Y] 
										  andRangeZMin:[ConfigurationManager getParameterValue:KPN_CLUSTER_RANGE_MIN_Z] 
										  andRangeZMax:[ConfigurationManager getParameterValue:KPN_CLUSTER_RANGE_MAX_Z]];
				
				[ConfigurationManager setParameterValue:KPN_CLASSIFIER_OBSERVATION_NUMBER andNewValue:[ConfigurationManager getParameterValue:KPN_CLUSTER_NUMBER]];
				break;
			case ClusterTypeKMedoid:
				instanceObjectCluster = [[KMedoidCluster alloc]
										 initWithClusterNumber:[ConfigurationManager getParameterValue:KPN_CLUSTER_NUMBER] 
										 andDimensionNumber:[ConfigurationManager getParameterValue:KPN_CLUSTER_DIMENSION]];
				[ConfigurationManager setParameterValue:KPN_CLASSIFIER_OBSERVATION_NUMBER andNewValue:[ConfigurationManager getParameterValue:KPN_CLUSTER_NUMBER]];
				break;
			case ClusterTypeLloyd:
				instanceObjectCluster = nil;
				break;
			case ClusterTypeTrajectoryAngle:
				instanceObjectCluster = [[TrajectoryAngleQuantization alloc]initWithSplitValues:[ConfigurationManager getParameterValue:KPN_CLUSTER_XY_SPLIT] 
																					 andsplitXZ:[ConfigurationManager getParameterValue:KPN_CLUSTER_XZ_SPLIT] 
																					 andsplitYZ:[ConfigurationManager getParameterValue:KPN_CLUSTER_YZ_SPLIT]];
				[ConfigurationManager setParameterValue:KPN_CLASSIFIER_OBSERVATION_NUMBER andNewValue:[(TrajectoryAngleQuantization*)instanceObjectCluster getNumberOfCluster]];
				
				break;
			case ClusterTypeAmplitudeFixed:
				instanceObjectCluster = [[AmplituteClusterFixed alloc]init];
				[ConfigurationManager setParameterValue:KPN_CLASSIFIER_OBSERVATION_NUMBER andNewValue:33];
				break;
			case ClusterTypeAmplitudeDynamic:
				instanceObjectCluster = [[AmplituteClusterDynamic alloc]init];
				[ConfigurationManager setParameterValue:KPN_CLASSIFIER_OBSERVATION_NUMBER andNewValue:[ConfigurationManager getParameterValue:KPN_CLUSTER_NUMBER]];
				break;
            case ClusterTypeALLDynamic:
				instanceObjectCluster = [[ClusterDynamic alloc]init];
				[ConfigurationManager setParameterValue:KPN_CLASSIFIER_OBSERVATION_NUMBER andNewValue:[ConfigurationManager getParameterValue:KPN_CLUSTER_NUMBER]];
				break;
			default:
				instanceObjectCluster = nil;
				break;
		}
	}
	return instanceObjectCluster;
}

+(void) reset{
	[instanceObjectCluster release];
	instanceObjectCluster = nil;
}

+(void)clusterDataSet:(DataSet*)currentDataSet{
	Cluster* currentClusterAlgorithm = [Cluster getCluster];
	if (currentClusterAlgorithm) {
		currentClusterAlgorithm.numberOfCluster = [ConfigurationManager getParameterValue:KPN_CLUSTER_NUMBER];
        currentClusterAlgorithm.numberOfDataDimension = [ConfigurationManager getParameterValue:KPN_CLUSTER_DIMENSION];
        
        [currentClusterAlgorithm makeCluster:currentDataSet.gestureDataArrayAllWithoutClass];    // We are sending all the data without class information, to make cluster with all information

		[currentDataSet.operationsequenceArray addObject:K_OPERATION_CLUSTER];
	}
	else {
		[currentDataSet.operationsequenceArray addObject:K_OPERATION_NONCLUSTER];
	}
	//[Cluster reset];
}

+(void)clusterGestureData:(GestureData*)currentGestureData{
    Cluster* currentClusterAlgorithm = [Cluster getCluster];
	if (currentClusterAlgorithm) {
		currentClusterAlgorithm.numberOfCluster = [ConfigurationManager getParameterValue:KPN_CLUSTER_NUMBER];
        currentClusterAlgorithm.numberOfDataDimension = [ConfigurationManager getParameterValue:KPN_CLUSTER_DIMENSION];
        [currentClusterAlgorithm loadConfiguration:[ConfigurationManager getConfiguration:KC_CLUSTER]];
        
        NSMutableArray* tempArray = [[NSMutableArray alloc]initWithCapacity:1];
        [tempArray addObject:currentGestureData];
        [currentClusterAlgorithm makeCluster:tempArray];    // We are sending all the data without class information, to 
        [tempArray removeAllObjects];
        [tempArray release];
        tempArray = nil;

	}
	else {
        //do nothing
	}
	[Cluster reset];
}
-(void)loadConfiguration:(NSDictionary*)configurationFile{
  // the default function is doing nothing ! -> it will override in derived classes
}

@end
