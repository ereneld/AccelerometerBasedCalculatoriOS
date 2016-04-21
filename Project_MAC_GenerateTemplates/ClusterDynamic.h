//
//  ClusterDynamic.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 4/20/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "Cluster.h"

@interface ClusterDynamic : Cluster {
   
    NSMutableArray* xSplitList;
    NSMutableArray* ySplitList;
    NSMutableArray* zSplitList;
    NSMutableArray* amplituteSplitList;    
}

-(void)makeCluster:(NSArray*)gestureDataArray;

@end
