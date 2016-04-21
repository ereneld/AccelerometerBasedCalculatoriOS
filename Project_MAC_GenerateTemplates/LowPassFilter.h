//
//  LowPassFilter.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/19/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "Filter.h"

@interface LowPassFilter : Filter {

	double filterConstant;

	BOOL isAdaptive;
	double minStep;
	double noiseAttenuation;

}
@property(nonatomic, assign)double filterConstant;
@property(nonatomic, assign)BOOL isAdaptive;
@property(nonatomic, assign)double minStep;
@property(nonatomic, assign)double noiseAttenuation;

-(id)initWithSampleRate:(double)updateFrequency andCutoffFrequency:(double)cutoffFrequency andIsAdaptive:(BOOL)isAdaptiveFilter andMinStep:(double)minStepFilter andNoiseAttenuation:(double)noiseAttenuationFilter;
-(void)makeFilter:(double)currentX andY:(double)currentY andZ:(double)currentZ;


@end
