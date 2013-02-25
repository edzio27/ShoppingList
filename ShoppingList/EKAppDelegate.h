//
//  EKAppDelegate.h
//  ShoppingList
//
//  Created by edzio27 on 24.02.2013.
//  Copyright (c) 2013 edzio27. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EKViewController;

@interface EKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) EKViewController *viewController;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) UITabBarController *tabBarController;

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;

@end
