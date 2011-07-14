//
//  stashViewController.h
//  stash
//
//  Created by Sasha Lerner on 7/13/11.
//  Copyright 2011 deviantART, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviantArt.h"

@interface stashViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, DeviantArtDelegate> {
    UIToolbar *toolbar;
    UIPopoverController *popoverController;
    UIImageView *imageView;
    BOOL newMedia;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) UIPopoverController *popoverController;
- (IBAction)useCamera: (id)sender;
- (IBAction)usePhotos: (id)sender;
- (IBAction)useStash: (id)sender;

@end
