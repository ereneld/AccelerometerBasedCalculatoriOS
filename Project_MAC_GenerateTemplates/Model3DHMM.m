//
//  Model3DHMM.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 4/21/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "Model3DHMM.h"


@implementation Model3DHMM

-(id)initWithStateNumber:(int)sNumber andObservationNumber:(int)oNumber andMaxIterationNumber:(int)maxIterationValue{
	self = [super init];
    if(self)
	{
		hmmX = [[ModelHMM alloc]initWithStateNumber:sNumber andObservationNumber:oNumber andMaxIterationNumber:maxIterationValue andDimensionToClassify:1];
		hmmY = [[ModelHMM alloc]initWithStateNumber:sNumber andObservationNumber:oNumber andMaxIterationNumber:maxIterationValue andDimensionToClassify:2];
		hmmZ = [[ModelHMM alloc]initWithStateNumber:sNumber andObservationNumber:oNumber andMaxIterationNumber:maxIterationValue andDimensionToClassify:3];
		
	}
	return self;
}


-(void)initialize{
	[hmmX initialize];
    [hmmY initialize];
    [hmmZ initialize];
}

-(void)traingGestureData:(NSArray*)gestureDataArray{
    [hmmX traingGestureData:gestureDataArray];
    [hmmY traingGestureData:gestureDataArray];
    [hmmZ traingGestureData:gestureDataArray];
}
-(double)getProbability:(NSArray*)gestureDataArray{
    double returnValue = [hmmX getProbability:gestureDataArray] * [hmmY getProbability:gestureDataArray] * [hmmZ getProbability:gestureDataArray];
    return returnValue;
}

-(NSString*)toString{
	NSString* returnValue = [[hmmX toSring] stringByAppendingString:[[hmmY toString] stringByAppendingString:[hmmZ toString]]];
	return returnValue;
}


-(NSDictionary*)getConfiguration{
    
    NSMutableDictionary* classifierConfiguration = [[NSMutableDictionary alloc]init];
    
    [classifierConfiguration setValue:[hmmX getConfiguration] forKey:@"hmmX"];
    [classifierConfiguration setValue:[hmmY getConfiguration] forKey:@"hmmY"];
    [classifierConfiguration setValue:[hmmZ getConfiguration] forKey:@"hmmZ"];
    
    return classifierConfiguration;
}

-(void)loadConfiguration:(NSDictionary*)configurationFile{

    NSMutableDictionary* hmmXConfiguration = [configurationFile objectForKey:@"hmmX"];
    NSMutableDictionary* hmmYConfiguration = [configurationFile objectForKey:@"hmmY"];
    NSMutableDictionary* hmmZConfiguration = [configurationFile objectForKey:@"hmmZ"];
    
    [hmmX loadConfiguration:hmmXConfiguration];
    [hmmY loadConfiguration:hmmYConfiguration];
    [hmmZ loadConfiguration:hmmZConfiguration];
}


@end
