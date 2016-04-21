//
//  SimpleSampler.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/11/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "Sampler.h"

//Simple Sampler is used for sampling the data according to given sample size.
//Exp. if our data is like => 1, 2, 3, 4, 5, 3, 2, 1, 3, 4, 5, 10 => and if our sample size is 3
// The result signal is => 1, 5, 3
@interface SimpleSampler : Sampler {

}

-(void)sampleGestureData:(NSArray*)dataArray;

@end
