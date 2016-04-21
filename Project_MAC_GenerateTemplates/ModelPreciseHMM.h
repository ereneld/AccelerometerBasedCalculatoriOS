//
//  ModelPreciseHMM.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/24/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "ModelHMMWii.h"

@interface ModelPreciseHMM : ModelHMMWii {

}

-(double*)calculateScalingFactor:(NSArray*) observationSequence;
-(double**)scaledForwardProcedure:(NSArray*) observationSequence;
-(double**)scaledBackwardProcedure:(NSArray*) observationSequence andScalingFactor:(double*)scalingFactor;


@end
