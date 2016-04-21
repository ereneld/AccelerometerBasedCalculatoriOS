//
//  ModelCurveFitting.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/12/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ModelCurveFitting : NSObject {

	int numberOfMaxDimension; // a x^(max) + b x^(max-1) + .... + n
	double** coefficients; //  coefficients[ Dimension ][ Polynomial degree ] ; 
	// exp1 c[0][1] means that X dimensions Second coefficient value for x^1
	// exp2 c[1][2] means that Y dimensions Third coefficient value for x^2
	// exp2 c[2][0] means that Z dimensions First coefficient value for x^0
	// exp3 c[3][0] ERROR no more than 3 dimension -> the data consist of three dimension
}



@end
