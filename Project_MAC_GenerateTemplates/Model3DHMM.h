//
//  Model3DHMM.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 4/21/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelHMM.h"

@interface Model3DHMM : Classifier {
    ModelHMM* hmmX;
    ModelHMM* hmmY;
    ModelHMM* hmmZ;
}

-(id)initWithStateNumber:(int)sNumber andObservationNumber:(int)oNumber andMaxIterationNumber:(int)maxIterationValue;

-(void)traingGestureData:(NSArray*)gestureDataArray;
-(double)getProbability:(NSArray*)gestureDataArray;

@end
