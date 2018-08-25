//
//  AppDelegate.h
//  PhotoDiary
//
//  Created by Francesco Saccani on 21/08/2018.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

@end

