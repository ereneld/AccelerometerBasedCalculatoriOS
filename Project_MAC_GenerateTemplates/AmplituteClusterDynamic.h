//
//  AmplituteClusterDynamic.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/26/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "Cluster.h"

// Amplitude values divided by dynamicly with given number of slipt

@interface AmplituteClusterDynamic : Cluster {

	NSMutableArray* amplituteSplitList;
}

-(void)makeCluster:(NSArray*)gestureDataArray;


@end
