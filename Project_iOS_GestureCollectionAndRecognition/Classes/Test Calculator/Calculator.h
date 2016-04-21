//
//  Calculator.h
//  GestureDataWithRecognition
//
//  Created by dogukan ibrahimoglu on 4/20/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	ProcessTypeNONE,              //0
	ProcessTypeDelete,			//1
	ProcessTypeGiveOutput		//2
} ProcessType;

typedef enum {
	OperationTypeNONE,              //0
	OperationTypeAddition,			//1
	OperationTypeSubtraction,		//2
	OperationTypeMultiplication,	//3
	OperationTypeDivision           //4
} OperationType;

@interface Term : NSObject {
    //double termValue;
    NSString* termString;
}

-(id)initWithTerm:(NSString*)termValueString;
-(id)initWithTermValue:(double)termValue;

-(NSString*)toString;
-(double)toValue;
-(BOOL)deleteLastDigit;
-(BOOL)addLastDigit:(NSString*)termValue;
+(BOOL)isTerm:(NSString*)termValue;
@end

@interface Operator : NSObject {
    OperationType operationType;
}
@property(nonatomic, assign)OperationType operationType;

-(id)initWithValue:(OperationType)operationTypeValue;
-(NSString*)toString;

@end


@interface Calculator : NSObject {
    
    NSMutableArray* arrayCalculatorItems;
    
}

-(void)addItem:(NSString*)stringItem;
-(NSString*)getCalculatorString;
-(NSString*)getCalculatorMeaningString;

-(BOOL)isOperator:(NSString*)operatorValue;
-(BOOL)isProcess:(NSString*)processValue;
-(Term*)getTerm:(NSString*)termValue andLastTerm:(id)lastItem;
-(Operator*)getOperator:(NSString*)operatorValue andLastTerm:(id)lastItem;
-(OperationType)getOperatorType:(NSString*)operatorValue;
-(ProcessType)getProcessType:(NSString*)processValue;
-(BOOL)evaluateProcess:(NSString*)processValue;
@end
