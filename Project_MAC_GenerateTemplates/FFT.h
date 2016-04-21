//
//  FFT.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/28/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "DimensionalReductor.h"
#import <Accelerate/Accelerate.h>

@interface FFT : DimensionalReductor {

}


-(void)prepareArraySpatialDomain:(NSMutableArray*) arrayOriginal andArrayToPrepare:(float*) arrayToPrepare;
-(void)prepareArrayFrequencyDomain:(NSMutableArray*)arrayToChange andArrayFrequencyDomain:(float*) arrayFrequencyDomain;

@end
