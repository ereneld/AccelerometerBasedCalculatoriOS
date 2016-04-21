//
//  BandPassFilter.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/19/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "Filter.h"
#import "LowPassFilter.h"
#import "HighPassFilter.h"

@interface BandPassFilter : Filter {
	LowPassFilter* lowPassFilter;
	HighPassFilter* highPassFilter;
}
@property(nonatomic, retain)LowPassFilter* lowPassFilter;
@property(nonatomic, retain)HighPassFilter* highPassFilter;

-(id)initWithLowFilter:(LowPassFilter*)lowPassFiltr andHighPassFilter:(HighPassFilter*)highPassFiltr;
-(void)makeFilter:(double)currentX andY:(double)currentY andZ:(double)currentZ;


@end
