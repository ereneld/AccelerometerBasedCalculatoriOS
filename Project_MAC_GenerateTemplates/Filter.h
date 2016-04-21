//
//  Filter.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/19/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//


#import "DataSet.h"
#import "GestureData.h"
#import "Constants.h"
#import "ConfigurationManager.h"


@interface Filter : NSObject {
	double filteredX, filteredY, filteredZ;
	double lastX, lastY, lastZ;
}
@property(nonatomic, assign)double filteredX;
@property(nonatomic, assign)double filteredY;
@property(nonatomic, assign)double filteredZ;
@property(nonatomic, assign)double lastX;
@property(nonatomic, assign)double lastY;
@property(nonatomic, assign)double lastZ;

+(Filter*) getFilter;
+(void) reset;
+(void)filterDataSet:(DataSet*)currentDataSet;
+(void)filterGestureData:(GestureData*)currentGestureData;

-(double)Norm:(double)x andY:(double)y andZ:(double)z;
-(double)Clamp:(double) v andMin:(double)min andMax:(double)max;
@end
