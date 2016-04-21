//
//  LowPassFilter.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/19/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "LowPassFilter.h"


@implementation LowPassFilter
@synthesize filterConstant, isAdaptive, minStep, noiseAttenuation;

-(id)initWithSampleRate:(double)updateFrequency andCutoffFrequency:(double)cutoffFrequency andIsAdaptive:(BOOL)isAdaptiveFilter andMinStep:(double)minStepFilter andNoiseAttenuation:(double)noiseAttenuationFilter
{
    self = [super init];
	if(self)
	{
		double dt = 1.0 / updateFrequency;
		double RC = 1.0 / cutoffFrequency;
		self.filterConstant = dt / (dt + RC);
		
		self.isAdaptive = isAdaptiveFilter;
		self.minStep = minStepFilter;
		self.noiseAttenuation = noiseAttenuationFilter;
	}
	return self;
}

-(void)makeFilter:(double)currentX andY:(double)currentY andZ:(double)currentZ
{
	double alpha = filterConstant;
	
	if(isAdaptive)
	{
        double differenceMean = (fabs(  [self Norm:filteredX andY:filteredY andZ:filteredZ] - [self Norm:currentX andY:currentY andZ:currentZ] ) / minStep) - 1.0;
		double d =  [self Clamp:differenceMean andMin:0.0 andMax:1.0];
		alpha = (1.0 - d) * filterConstant / noiseAttenuation + d * filterConstant;
	}
	
	filteredX = currentX * alpha + filteredX * (1.0 - alpha);
	filteredY = currentY * alpha + filteredY * (1.0 - alpha);
	filteredZ = currentZ * alpha + filteredZ * (1.0 - alpha);
}


@end
