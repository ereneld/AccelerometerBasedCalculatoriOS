//
//  KMeanCluster.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/21/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "KMeanCluster.h"
#import "GestureData.h"
#import "ConfigurationManager.h"

@implementation KMeanCluster

-(id)initWithClusterNumber:(int)clusterSize
		andDimensionNumber:(int)clusterDimension
   andInitializationOption:(ClusterInializationType)initializationOptions 
			  andRangeXMin:(double)xMin andRangeXMax:(double)xMax  
			  andRangeYMin:(double)yMin andRangeYMax:(double)yMax  
			  andRangeZMin:(double)zMin andRangeZMax:(double)zMax
{
    self = [super init];
	if(self)
	{
		clusterInializationType = initializationOptions;
		
		self.numberOfDataDimension = clusterDimension;
		self.numberOfCluster = clusterSize;
		rangeXMin = xMin;
		rangeXMax = xMax;
		rangeYMin = yMin;
		rangeYMax = yMax;
		rangeZMin = zMin;
		rangeZMax = zMax;
		
		isObjectsMoving = NO;
		
		if ((centeroidMatrix = malloc(numberOfDataDimension * sizeof(double *))) == NULL)
		{
			fprintf(stderr,"Memory allocation error (centeroidMatrix 1)\n");
		}
		else {
			for (int i=0; i < numberOfDataDimension; i++){
				if ((centeroidMatrix[i] = malloc(numberOfCluster * sizeof(double))) == NULL)
				{
					fprintf(stderr,"Memory allocation error (centeroidMatrix 2)\n");
				}
				else {
					for(int j=0; j < numberOfCluster; j++){
						centeroidMatrix[i][j] = 0.0;
					}
				}
				
			}
		}

		/* allocate memory for sumXYZMatrix */
		if ((sumXYZMatrix = malloc((numberOfDataDimension + 1) * sizeof(double *))) == NULL)
		{
			fprintf(stderr,"Memory allocation error (sumXYZMatrix 1)\n");
		}
		else {
			for (int i=0; i < (numberOfDataDimension + 1); i++){
				if ((sumXYZMatrix[i] = malloc(numberOfCluster * sizeof(double))) == NULL)
				{
					fprintf(stderr,"Memory allocation error (sumXYZMatrix 2)\n");
				}
				else {
					for(int j=0; j < numberOfCluster; j++){
						sumXYZMatrix[i][j] = 0.0;
					}
				}
			}
		}

		
	}
	return self;
	
}

-(void)initializeCluster{
	/* allocate memory for centeroidMatrix */
	double z=0.0;
	double randomAngle = 0.0;
	double lengthFromZAxis = 0.0;
	double angleMin = 0.0;
	double angleMax = 0.0;
	
	
	
	if (clusterInializationType == ClusterInializationTypeRandomInRange) {
		for (int i=0; i<numberOfCluster; i++) {
			centeroidMatrix[0][i]=(((double) arc4random() / 0xFFFFFFFFu) * (rangeXMax - rangeXMin)) + rangeXMin;
			centeroidMatrix[1][i]=(((double) arc4random() / 0xFFFFFFFFu) * (rangeYMax - rangeYMin)) + rangeYMin;
			centeroidMatrix[2][i]=(((double) arc4random() / 0xFFFFFFFFu) * (rangeZMax - rangeZMin)) + rangeZMin;
		}
	}
	else if(clusterInializationType == ClusterInializationTypeEqualPartitionInRange) {
		for (int i=0; i<numberOfCluster; i++) {
			centeroidMatrix[0][i] =  (((double)(rangeXMax - rangeXMin) / numberOfCluster) * i) + rangeXMin;
			centeroidMatrix[1][i] =  (((double)(rangeYMax - rangeYMin) / numberOfCluster) * i) + rangeYMin;
			centeroidMatrix[2][i] =  (((double)(rangeZMax - rangeZMin) / numberOfCluster) * i) + rangeZMin;
		}
	}
	else if(clusterInializationType == ClusterInializationTypeSphericalRandomInUnitSphere) {
		for (int i=0; i<numberOfCluster; i++) {
			// unit sphere  - uniform
			/* Generate a random point on a sphere of radius 1. */
			/* the sphere is sliced at z, and a random point at angle t
			 generated on the circle of intersection. */
			z = (((double) arc4random() / 0xFFFFFFFFu) * 2) - 1; //Generates -1 to 1 float value
			randomAngle = 2.0 * M_PI * ((double) arc4random() / 0xFFFFFFFFu);
			lengthFromZAxis = sqrt( 1 - z*z );
			centeroidMatrix[0][i]= lengthFromZAxis * cos( randomAngle );
			centeroidMatrix[1][i]= lengthFromZAxis * sin( randomAngle );
			centeroidMatrix[2][i]= z;
		}
	}
	else if(clusterInializationType == ClusterInializationTypeSphericalRandomInRange) {
		for (int i=0; i<numberOfCluster; i++) {
			//unit sphere - in range 
			z = (((double) arc4random() / 0xFFFFFFFFu) * (rangeZMax - rangeZMin)) + rangeZMin; //should be -1 to 1
			angleMin = atan2(rangeYMax, rangeXMax);
			angleMax = atan2(rangeYMin, rangeXMin);
			if (angleMin > angleMax) {
				randomAngle = angleMax;
				angleMax = angleMin;
				angleMin = randomAngle;
			}
			randomAngle = (((double) arc4random() / 0xFFFFFFFFu) * (angleMax - angleMin)) + angleMin; // between angle max and min
			lengthFromZAxis = sqrt( 1 - z*z );
			centeroidMatrix[0][i]= lengthFromZAxis * cos( randomAngle );
			centeroidMatrix[1][i]= lengthFromZAxis * sin( randomAngle );
			centeroidMatrix[2][i]= z;
		}
	}
	else {
		//do nothing
	}

	/*else if(initializationOption == kMeanInitialization_Spherical_EqualPartition_inRange) {
	 ;
	 }*/
	
	
	for (int i=0; i<numberOfCluster; i++) {
		sumXYZMatrix[0][i] = 0.0;
		sumXYZMatrix[1][i] = 0.0;
		sumXYZMatrix[2][i] = 0.0;
		sumXYZMatrix[3][i] = 0.0;
	}
	
	/*NSLog(@"centeroidMatrix");
	for (int i=0; i<numberOfCluster; i++) {
		NSLog(@"[0][%d] = %g | [1][%d] = %g | [2][%d] = %g ", i, centeroidMatrix[0][i], i, centeroidMatrix[1][i], i, centeroidMatrix[2][i]);
	}
	
	NSLog(@"sumXYZMatrix");
	for (int i=0; i<numberOfCluster; i++) {
		NSLog(@"[0][%d] = %g | [1][%d] = %g | [2][%d] = %g | [3][%d] = %g ", i, sumXYZMatrix[0][i], i, sumXYZMatrix[1][i], i, sumXYZMatrix[2][i], i, sumXYZMatrix[3][i]);
	}
	*/
}
-(void)setupCentroidMatrixWithSumMatrix{
	for (int i=0; i<numberOfCluster ; i++) {
		if (sumXYZMatrix[3][i]!=0) {
			centeroidMatrix[0][i] = (float)sumXYZMatrix[0][i] / (int)sumXYZMatrix[3][i];
			centeroidMatrix[1][i] = (float)sumXYZMatrix[1][i] / (int)sumXYZMatrix[3][i];
			centeroidMatrix[2][i] = (float)sumXYZMatrix[2][i] / (int)sumXYZMatrix[3][i];
		}
		else {
			//do nothing -> if no data point at that cluster stay same
			if (clusterInializationType == ClusterInializationTypeRandomInRange) {
				centeroidMatrix[0][i]=(((float) arc4random() / 0xFFFFFFFFu) * (rangeXMax - rangeXMin)) + rangeXMin;
				centeroidMatrix[1][i]=(((float) arc4random() / 0xFFFFFFFFu) * (rangeYMax - rangeYMin)) + rangeYMin;
				centeroidMatrix[2][i]=(((float) arc4random() / 0xFFFFFFFFu) * (rangeZMax - rangeZMin)) + rangeZMin;
				
			}
			else if(clusterInializationType == ClusterInializationTypeEqualPartitionInRange) {
				// do nothing - there is no randomness in clustering
			}
			else if(clusterInializationType == ClusterInializationTypeSphericalRandomInUnitSphere) {
				// unit sphere  - uniform
				/* Generate a random point on a sphere of radius 1. */
				/* the sphere is sliced at z, and a random point at angle t
				 generated on the circle of intersection. */
				double z = (((double) arc4random() / 0xFFFFFFFFu) * 2) - 1; //Generates -1 to 1 float value
				double randomAngle = 2.0 * M_PI * ((double) arc4random() / 0xFFFFFFFFu);
				double lengthFromZAxis = sqrt( 1 - z*z );
				centeroidMatrix[0][i]= lengthFromZAxis * cos( randomAngle );
				centeroidMatrix[1][i]= lengthFromZAxis * sin( randomAngle );
				centeroidMatrix[2][i]= z;
				
			}
			else if(clusterInializationType == ClusterInializationTypeSphericalRandomInRange) {
				//unit sphere - in range 
				double z = (((double) arc4random() / 0xFFFFFFFFu) * (rangeZMax - rangeZMin)) + rangeZMin; //should be -1 to 1
				double angleMin = atan2(rangeYMax, rangeXMax);
				double angleMax = atan2(rangeYMin, rangeXMin);
				if (angleMin > angleMax) {
					double randomAngle = angleMax;
					angleMax = angleMin;
					angleMin = randomAngle;
				}
				double randomAngle = (((double) arc4random() / 0xFFFFFFFFu) * (angleMax - angleMin)) + angleMin; // between angle max and min
				double lengthFromZAxis = sqrt( 1 - z*z );
				centeroidMatrix[0][i]= lengthFromZAxis * cos( randomAngle );
				centeroidMatrix[1][i]= lengthFromZAxis * sin( randomAngle );
				centeroidMatrix[2][i]= z;
			}
			/*else if(initializationOption == kMeanInitialization_Spherical_EqualPartition_inRange) {
			 // do nothing
			 }*/
			
			
		}
	}
	/*
	NSLog(@"centeroidMatrix");
	for (int i=0; i<numberOfCluster; i++) {
		NSLog(@"[0][%d] = %g | [1][%d] = %g | [2][%d] = %g ", i, centeroidMatrix[0][i], i, centeroidMatrix[1][i], i, centeroidMatrix[2][i]);
	}
	
	NSLog(@"sumXYZMatrix");
	for (int i=0; i<numberOfCluster; i++) {
		NSLog(@"[0][%d] = %g | [1][%d] = %g | [2][%d] = %g | [3][%d] = %g ", i, sumXYZMatrix[0][i], i, sumXYZMatrix[1][i], i, sumXYZMatrix[2][i], i, sumXYZMatrix[3][i]);
	}
	*/
}
-(int)getClosestCluster:(double)tValue andXValue:(double)xValue andYValue:(double)yValue andZValue:(double)zValue{
	int closestCluster = 0;
	double minValue = FLT_MAX;
	double distanceValue = 0.0;
	for (int i=0; i<numberOfCluster ; i++) {
		distanceValue = ((xValue - centeroidMatrix[0][i])*(xValue - centeroidMatrix[0][i])) + 
		((yValue - centeroidMatrix[1][i])*(yValue - centeroidMatrix[1][i])) + 
		((zValue - centeroidMatrix[2][i])*(zValue - centeroidMatrix[2][i])) ;
		if (distanceValue < minValue) {
			minValue = distanceValue;
			closestCluster = i;
		}
	}
	return closestCluster;
}

-(BOOL)isCentroidMatrixLoaded{
    BOOL returnValue = NO;
    for (int i=0; i < numberOfDataDimension; i++){
        for (int j=0; j<numberOfCluster; j++) {
            if (centeroidMatrix[i][j] != 0.0) {
                returnValue = YES;
                break;
            }
            else{
                // do nothing - continue
            }
        }
        
    }
    return returnValue;
}

-(void)makeCluster:(NSArray*)gestureDataArray{
    double tValue = 0.0;
    double xValue = 0.0;
    double yValue = 0.0;
    double zValue = 0.0;
    int clusterNumberActual = 0;
    int clusterNumberCalculated = 0;
    
    NSLog(@"----- Start Clustering");
	
    if (![self isCentroidMatrixLoaded]) {
        [self initializeCluster];
       
        do{
            isObjectsMoving = NO;
            for (GestureData* gestureData in gestureDataArray) {
                NSArray* dataArray = gestureData.gestureData;
                if (dataArray!= nil &&  [dataArray count]>0) {
                    for (int i=0; i<[(NSArray*)[dataArray objectAtIndex:0] count]; i++) {
                        tValue = [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:0] objectAtIndex:i] doubleValue];
                        xValue = [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:1] objectAtIndex:i] doubleValue];
                        yValue = [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:2] objectAtIndex:i] doubleValue];
                        zValue = [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:3] objectAtIndex:i] doubleValue];
                        clusterNumberActual = [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:4] objectAtIndex:i] intValue];
                        clusterNumberCalculated = 1 + [self getClosestCluster:tValue andXValue:xValue andYValue:yValue andZValue:zValue ];
                        if (clusterNumberActual != clusterNumberCalculated) {
                            if (clusterNumberActual > 0) {
                                if (sumXYZMatrix[3][clusterNumberActual-1]<=0) {
                                    NSLog(@" - ERROR -");
                                    NSLog(@"sumXYZMatrix");
                                    for (int i=0; i<numberOfCluster; i++) {
                                        NSLog(@"[0][%d] = %g | [1][%d] = %g | [2][%d] = %g | [3][%d] = %g ", i, sumXYZMatrix[0][i], i, sumXYZMatrix[1][i], i, sumXYZMatrix[2][i], i, sumXYZMatrix[3][i]);
                                    }
                                    NSLog(@"ERROR - check the clustering %d %d - %g %g", clusterNumberActual, clusterNumberCalculated, sumXYZMatrix[3][clusterNumberActual-1],sumXYZMatrix[3][clusterNumberCalculated-1] );
                                }
                                sumXYZMatrix[0][clusterNumberActual-1] = sumXYZMatrix[0][clusterNumberActual-1] - xValue;
                                sumXYZMatrix[1][clusterNumberActual-1] = sumXYZMatrix[1][clusterNumberActual-1] - yValue;
                                sumXYZMatrix[2][clusterNumberActual-1] = sumXYZMatrix[2][clusterNumberActual-1] - zValue;
                                sumXYZMatrix[3][clusterNumberActual-1] = sumXYZMatrix[3][clusterNumberActual-1] - 1;
                            }
                            sumXYZMatrix[0][clusterNumberCalculated-1] = sumXYZMatrix[0][clusterNumberCalculated-1] + xValue;
                            sumXYZMatrix[1][clusterNumberCalculated-1] = sumXYZMatrix[1][clusterNumberCalculated-1] + yValue;
                            sumXYZMatrix[2][clusterNumberCalculated-1] = sumXYZMatrix[2][clusterNumberCalculated-1] + zValue;
                            sumXYZMatrix[3][clusterNumberCalculated-1] = sumXYZMatrix[3][clusterNumberCalculated-1] + 1;
                            
                            [(NSMutableArray*)[dataArray objectAtIndex:4] replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:clusterNumberCalculated]];
                            isObjectsMoving = YES;
                        }
                        
                    }
                }
            }
            [self setupCentroidMatrixWithSumMatrix];
        }while (isObjectsMoving) ;
        [ConfigurationManager addConfiguration:[self getConfiguration] andName:KC_CLUSTER];
    }
    else{
        for (GestureData* gestureData in gestureDataArray) {
            NSArray* dataArray = gestureData.gestureData;
            if (dataArray!= nil &&  [dataArray count]>0) {
                for (int i=0; i<[(NSArray*)[dataArray objectAtIndex:0] count]; i++) {
                    tValue = [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:0] objectAtIndex:i] doubleValue];
                    xValue = [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:1] objectAtIndex:i] doubleValue];
                    yValue = [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:2] objectAtIndex:i] doubleValue];
                    zValue = [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:3] objectAtIndex:i] doubleValue];
                    clusterNumberCalculated = 1 + [self getClosestCluster:tValue andXValue:xValue andYValue:yValue andZValue:zValue ];
                    [(NSMutableArray*)[dataArray objectAtIndex:4] replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:clusterNumberCalculated]];
                }
            }
        }

    }
    
    NSLog(@"----- Finish Clustering");
	NSLog(@"centeroidMatrix");
	for (int i=0; i<numberOfCluster; i++) {
		NSLog(@"[0][%d] = %g | [1][%d] = %g | [2][%d] = %g ", i, centeroidMatrix[0][i], i, centeroidMatrix[1][i], i, centeroidMatrix[2][i]);
	}
	
	NSLog(@"sumXYZMatrix");
	for (int i=0; i<numberOfCluster; i++) {
		NSLog(@"[0][%d] = %g | [1][%d] = %g | [2][%d] = %g | [3][%d] = %g ", i, sumXYZMatrix[0][i], i, sumXYZMatrix[1][i], i, sumXYZMatrix[2][i], i, sumXYZMatrix[3][i]);
	}
}

-(NSDictionary*)getConfiguration{
    
    NSMutableDictionary* clusterConfiguration = [[NSMutableDictionary alloc]init];
    
    NSMutableArray* arrayCenteroids = [[NSMutableArray alloc]initWithCapacity:numberOfDataDimension];
    for (int i=0; i < numberOfDataDimension; i++){
        NSMutableArray* arrayOfDataValues = [[NSMutableArray alloc]initWithCapacity:numberOfCluster]; 
        for (int j=0; j<numberOfCluster; j++) {
            [arrayOfDataValues addObject:[NSNumber numberWithDouble:centeroidMatrix[i][j]]];
        }
        [arrayCenteroids addObject:arrayOfDataValues];
    }
    
    [clusterConfiguration setObject:arrayCenteroids forKey:@"arrayCenteroids"];
    
    return clusterConfiguration;
}

-(void)loadConfiguration:(NSDictionary*)configurationFile{
    NSMutableArray* arrayCenteroids = [[NSMutableArray alloc]initWithArray:[configurationFile objectForKey:@"arrayCenteroids"]];
    
    for (int i=0; i < numberOfDataDimension; i++){
        NSMutableArray* arrayOfDataValues = [arrayCenteroids objectAtIndex:i]; 
        for (int j=0; j<numberOfCluster; j++) {
            centeroidMatrix[i][j] = [[arrayOfDataValues objectAtIndex:j]doubleValue];
        }
    }
    
}

-(void) dealloc{
	for (int i=0; i < numberOfDataDimension; i++){
		free(centeroidMatrix[i]);
	}
	free(centeroidMatrix);
	for (int i=0; i < numberOfDataDimension+1; i++){
		free(sumXYZMatrix[i]);
	}
	free(sumXYZMatrix);
	
	[super dealloc];
}

@end
