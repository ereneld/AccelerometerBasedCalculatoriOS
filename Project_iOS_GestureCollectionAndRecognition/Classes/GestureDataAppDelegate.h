//
//  GestureDataAppDelegate.h
//  GestureData
//
//  Created by dogukan erenel on 4/11/10.
//  Copyright Bogazici University 2010. All rights reserved.
//

@interface GestureDataAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

