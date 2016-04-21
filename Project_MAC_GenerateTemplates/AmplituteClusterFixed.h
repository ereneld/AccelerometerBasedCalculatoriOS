//
//  AmplituteCluster.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/19/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cluster.h"

// Amplitude values divided by 33 with given info on artice 
// -> uWave: Accelerometer-based Personalized Gesture Recognition and Its Applications
@interface AmplituteClusterFixed : Cluster {

	
}

-(void)makeCluster:(NSArray*)gestureDataArray;

@end
