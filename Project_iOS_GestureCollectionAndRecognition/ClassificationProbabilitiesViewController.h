//
//  ClassificationProbabilitiesViewController.h
//  GestureDataWithRecognition
//
//  Created by dogukan ibrahimoglu on 3/17/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GestureData.h"

@interface ClassificationProbabilitiesViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate> {
    GestureData* gestureDataForData;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGestureData:(GestureData*)gestureData;
@end
