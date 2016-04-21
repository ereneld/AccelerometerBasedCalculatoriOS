//
//  KMedoidCluster.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 1/21/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "KMedoidCluster.h"
#import "GestureData.h"
#import "Constants.h"
#import "ConfigurationManager.h"

@implementation KMedoidCluster


-(id)initWithClusterNumber:(int)clusterSize
		andDimensionNumber:(int)clusterDimension
{
    self = [super init];
	if(self)
	{
		self.numberOfDataDimension = clusterDimension;
		self.numberOfCluster = clusterSize;
		
		isObjectsMoving = NO;
		
		/* allocate memory for centeroidMatrix */
		
		if ((medoidMatrix = malloc(numberOfDataDimension * sizeof(double *))) == NULL)
		{
			fprintf(stderr,"Memory allocation error (centeroidMatrix 1)\n");
		}
		for (int i=0; i < numberOfDataDimension; i++){
			if ((medoidMatrix[i] = malloc(numberOfCluster * sizeof(double))) == NULL)
			{
				fprintf(stderr,"Memory allocation error (centeroidMatrix 2)\n");
			}
			else {
				for (int j=0; j<numberOfCluster; j++) {
					medoidMatrix[i][j] = 0.0;
				}
			}
		}
		
		/* allocate memory for sumXYZMatrix */
		if ((sumXYZMatrix = malloc((numberOfDataDimension + 1) * sizeof(double *))) == NULL)
		{
			fprintf(stderr,"Memory allocation error (sumXYZMatrix 1)\n");
		}
		for (int i=0; i < (numberOfDataDimension + 1); i++){
			if ((sumXYZMatrix[i] = malloc(numberOfCluster * sizeof(double))) == NULL)
			{
				fprintf(stderr,"Memory allocation error (sumXYZMatrix 2)\n");
			}
			else {
				for (int j=0; j<numberOfCluster; j++) {
					sumXYZMatrix[i][j] = 0.0;
				}
			}
			
		}
		
	}
	return self;
	
}

-(void)initializeClusterMedoids:(NSArray*)allGestureData{
	
	for(int i=0; i<numberOfCluster; i++){
		BOOL isAssignedANumber = NO;
		while (!isAssignedANumber) {
			int indexOfRandomMedoid = arc4random() % [allGestureData count];
			NSArray* dataArray = [(GestureData*)[allGestureData objectAtIndex:indexOfRandomMedoid] gestureData];
			if (dataArray!= nil &&  [dataArray count]>0) {
				NSArray* tArray = [dataArray objectAtIndex:0];
				NSArray* xArray = [dataArray objectAtIndex:1];
				NSArray* yArray = [dataArray objectAtIndex:2];
				NSArray* zArray = [dataArray objectAtIndex:3];
				NSArray* cArray = [dataArray objectAtIndex:4];
				indexOfRandomMedoid = arc4random() % [tArray count];
				medoidMatrix[0][i] =  [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:1] objectAtIndex:indexOfRandomMedoid] doubleValue];
				medoidMatrix[1][i] =  [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:2] objectAtIndex:indexOfRandomMedoid] doubleValue];
				medoidMatrix[2][i] =  [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:3] objectAtIndex:indexOfRandomMedoid] doubleValue];
				isAssignedANumber = YES;
			}
		}	
	}
	
	NSLog(@"medoidMatrix");
	for (int i=0; i<numberOfCluster; i++) {
		NSLog(@"[0][%d] = %g | [1][%d] = %g | [2][%d] = %g ", i, medoidMatrix[0][i], i, medoidMatrix[1][i], i, medoidMatrix[2][i]);
	}
	
	NSLog(@"sumXYZMatrix");
	for (int i=0; i<numberOfCluster; i++) {
		NSLog(@"[0][%d] = %g | [1][%d] = %g | [2][%d] = %g | [3][%d] = %g ", i, sumXYZMatrix[0][i], i, sumXYZMatrix[1][i], i, sumXYZMatrix[2][i], i, sumXYZMatrix[3][i]);
	}
	
}

-(int)getClosestCluster:(double)tValue andXValue:(double)xValue andYValue:(double)yValue andZValue:(double)zValue{
	int closestCluster = 0;
	double minValue = FLT_MAX;
	double distanceValue = 0.0;
	for (int i=0; i<numberOfCluster ; i++) {
		distanceValue = ((xValue - medoidMatrix[0][i])*(xValue - medoidMatrix[0][i])) + 
		((yValue - medoidMatrix[1][i])*(yValue - medoidMatrix[1][i])) + 
		((zValue - medoidMatrix[2][i])*(zValue - medoidMatrix[2][i])) ;
		if (distanceValue < minValue) {
			minValue = distanceValue;
			closestCluster = i;
		}
	}
	return closestCluster;
}

-(void)setupMedoidMatrixWithSumMatrix:(NSArray*)allGestureData{
	for (int i=0; i<numberOfCluster ; i++) {
		if (sumXYZMatrix[3][i]!=0) {
			medoidMatrix[0][i] = (float)sumXYZMatrix[0][i] / (int)sumXYZMatrix[3][i];
			medoidMatrix[1][i] = (float)sumXYZMatrix[1][i] / (int)sumXYZMatrix[3][i];
			medoidMatrix[2][i] = (float)sumXYZMatrix[2][i] / (int)sumXYZMatrix[3][i];
			
			int closestGestureIndex = 0;
			int closestGestureDataIndex = 0;
			double minValue = FLT_MAX;
			double distanceValue = 0.0;
			
			double xValue = 0.0;
			double yValue = 0.0;
			double zValue = 0.0;
			
			for(int j=0; j<[allGestureData count]; j++){
				GestureData* gestureData = [allGestureData objectAtIndex:j];
				NSArray* dataArray = gestureData.gestureData;
				if (dataArray!= nil &&  [dataArray count]>0) {
					for(int k=0; k<[(NSArray*)[dataArray objectAtIndex:0] count]; k++){
						
						xValue = [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:1] objectAtIndex:k] doubleValue];
						yValue = [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:2] objectAtIndex:k] doubleValue];
						zValue = [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:3] objectAtIndex:k] doubleValue];
						
						distanceValue = ((xValue - medoidMatrix[0][i])*(xValue - medoidMatrix[0][i])) + 
						((yValue - medoidMatrix[1][i])*(yValue - medoidMatrix[1][i])) + 
						((zValue - medoidMatrix[2][i])*(zValue - medoidMatrix[2][i])) ;
						
						if (distanceValue < minValue) {
							minValue = distanceValue;
							closestGestureIndex = j;
							closestGestureDataIndex = k;
						}
					}
				}
				
			}
			
			NSArray* dataArray = [(GestureData*)[allGestureData objectAtIndex:closestGestureIndex] gestureData];
			medoidMatrix[0][i] =  [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:1] objectAtIndex:closestGestureDataIndex] doubleValue];
			medoidMatrix[1][i] =  [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:2] objectAtIndex:closestGestureDataIndex] doubleValue];
			medoidMatrix[2][i] =  [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:3] objectAtIndex:closestGestureDataIndex] doubleValue];
			
			
		}
		else {
			//do nothing -> if no data point at that cluster stay same
			BOOL isAssignedANumber = NO;
			while (!isAssignedANumber) {
				int indexOfRandomMedoid = arc4random() % [allGestureData count];
				NSArray* dataArray = [(GestureData*)[allGestureData objectAtIndex:indexOfRandomMedoid] gestureData];
				if (dataArray!= nil &&  [dataArray count]>0) {
					NSArray* tArray = [dataArray objectAtIndex:0];
					indexOfRandomMedoid = arc4random() % [tArray count];
					medoidMatrix[0][i] =  [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:1] objectAtIndex:indexOfRandomMedoid] doubleValue];
					medoidMatrix[1][i] =  [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:2] objectAtIndex:indexOfRandomMedoid] doubleValue];
					medoidMatrix[2][i] =  [(NSNumber*)[(NSArray*)[dataArray objectAtIndex:3] objectAtIndex:indexOfRandomMedoid] doubleValue];
					isAssignedANumber = YES;
				}
			}
			
		}
	}
	
	
	NSLog(@"medoidMatrix");
	for (int i=0; i<numberOfCluster; i++) {
		NSLog(@"[0][%d] = %g | [1][%d] = %g | [2][%d] = %g ", i, medoidMatrix[0][i], i, medoidMatrix[1][i], i, medoidMatrix[2][i]);
	}
	
	NSLog(@"sumXYZMatrix");
	for (int i=0; i<numberOfCluster; i++) {
		NSLog(@"[0][%d] = %g | [1][%d] = %g | [2][%d] = %g | [3][%d] = %g ", i, sumXYZMatrix[0][i], i, sumXYZMatrix[1][i], i, sumXYZMatrix[2][i], i, sumXYZMatrix[3][i]);
	}
	
}

-(BOOL)isMedoidMatrixLoaded{
    BOOL returnValue = NO;
    for (int i=0; i < numberOfDataDimension; i++){
        for (int j=0; j<numberOfCluster; j++) {
            if (medoidMatrix[i][j] != 0.0) {
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

-(void)makeCluster:(NSArray*)allGestureData{
    double tValue = 0.0;
    double xValue = 0.0;
    double yValue = 0.0;
    double zValue = 0.0;
    int clusterNumberActual = 0;
    int clusterNumberCalculated = 0;

    
    NSLog(@"----- Start Clustering");
    if (![self isMedoidMatrixLoaded]) {
        [self initializeClusterMedoids:allGestureData];
            do{
            isObjectsMoving = NO;
            for (GestureData* gestureData in allGestureData) {
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
                                    NSLog(@"ERROR - check the clustering %d %d - %d %d", clusterNumberActual, clusterNumberCalculated, sumXYZMatrix[3][clusterNumberActual-1],sumXYZMatrix[3][clusterNumberCalculated-1] );
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
            [self setupMedoidMatrixWithSumMatrix:allGestureData];
        }while (isObjectsMoving) ;
        [ConfigurationManager addConfiguration:[self getConfiguration] andName:KC_CLUSTER];
    }
    else{
        for (GestureData* gestureData in allGestureData) {
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
}

-(NSDictionary*)getConfiguration{
    
    NSMutableDictionary* clusterConfiguration = [[NSMutableDictionary alloc]init];
    
    NSMutableArray* arrayOfMedoidMatrix = [[NSMutableArray alloc]initWithCapacity:numberOfDataDimension];
    for (int i=0; i < numberOfDataDimension; i++){
        NSMutableArray* arrayOfDataValues = [[NSMutableArray alloc]initWithCapacity:numberOfCluster]; 
        for (int j=0; j<numberOfCluster; j++) {
            [arrayOfDataValues addObject:[NSNumber numberWithDouble:medoidMatrix[i][j]]];
        }
        [arrayOfMedoidMatrix addObject:arrayOfDataValues];
    }
    
    [clusterConfiguration setObject:arrayOfMedoidMatrix forKey:@"arrayOfMedoidMatrix"];
    
    return clusterConfiguration;
}

-(void)loadConfiguration:(NSDictionary*)configurationFile{
     NSMutableArray* arrayOfMedoidMatrix = [[NSMutableArray alloc]initWithArray:[configurationFile objectForKey:@"arrayOfMedoidMatrix"]];
    
    for (int i=0; i < numberOfDataDimension; i++){
        NSMutableArray* arrayOfDataValues = [arrayOfMedoidMatrix objectAtIndex:i]; 
        for (int j=0; j<numberOfCluster; j++) {
            medoidMatrix[i][j] = [[arrayOfDataValues objectAtIndex:j]doubleValue];
        }
    }
    
}

-(int)getUsedClusterNumber{
	int returnValue = 0;
	for (int i=0; i<numberOfCluster; i++) {
		if (sumXYZMatrix[3][i]>0) { //which has some data in that cluster
			returnValue = returnValue + 1;
		}
	}
	return returnValue;	
}
-(NSString*)getMedoidString{
	NSString* returnValue=@"";
	for (int i=0; i<numberOfCluster; i++) {
		if (sumXYZMatrix[3][i]>0) { //which has some data in that cluster
			returnValue = [returnValue stringByAppendingString:[NSString stringWithFormat:@"%g,%g,%g\n",medoidMatrix[0][i],medoidMatrix[1][i],medoidMatrix[2][i]]];
		}
	}
	return returnValue;
	
}

-(void) dealloc{
	for (int i=0; i < numberOfDataDimension; i++){
		free(medoidMatrix[i]);
	}
	free(medoidMatrix);
	for (int i=0; i < numberOfDataDimension+1; i++){
		free(sumXYZMatrix[i]);
	}
	free(sumXYZMatrix);
	[super dealloc];
}
@end
