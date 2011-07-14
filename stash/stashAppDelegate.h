//
//  stashAppDelegate.h
//  stash
//
//  Created by Sasha Lerner on 7/13/11.
//  Copyright 2011 deviantART, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@class stashViewController, DeviantArt;

@interface stashAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) DeviantArt *deviantArt;
@property (nonatomic, retain) IBOutlet stashViewController *viewController;

+ (stashAppDelegate *)currentDelegate;

@end
