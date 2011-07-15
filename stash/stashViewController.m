//
//  stashViewController.m
//  stash
//
//  Created by Sasha Lerner on 7/13/11.
//  Copyright 2011 deviantART, Inc. All rights reserved.
//

#import "stashViewController.h"
#import "stashAppDelegate.h"
#import "DeviantArt.h"

@implementation stashViewController

@synthesize imageView, popoverController;
@synthesize toolbar, spinner;


- (void)dealloc
{
    [toolbar release];
    [popoverController release];
    [imageView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:@"Camera"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(useCamera:)];
    UIBarButtonItem *photosButton = [[UIBarButtonItem alloc] 
                                         initWithTitle:@"Photo Library"
                                         style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(usePhotos:)];
    
    UIBarButtonItem *stashButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:@"Stash It"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(useStash:)];
    
    NSArray *items = [NSArray arrayWithObjects: cameraButton, photosButton, stashButton, nil];
    [toolbar setItems:items animated:NO];
    [cameraButton release];
    [photosButton release];
    [stashButton release];
    
    [spinner stopAnimating];
	spinner.hidden = TRUE;
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.imageView = nil;
    self.popoverController = nil;
    self.toolbar = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction) usePhotos: (id)sender {
    
    NSLog(@"Showing photolib@");
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if ([self.popoverController isPopoverVisible]) {
            [self.popoverController dismissPopoverAnimated:YES];
            [popoverController release];
            return;
        }
    }
    
    /*
    
    */
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (self == nil)
        || (self == nil)) {
        return;
    }
    
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = [NSArray arrayWithObjects: (NSString *) kUTTypeImage, nil];
    imagePicker.allowsEditing = NO;
    
    
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.popoverController = [[UIPopoverController alloc]
                                  initWithContentViewController:imagePicker];
        popoverController.delegate = self;
        [self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else {
        [self presentModalViewController: imagePicker animated: YES];
    }
    
    [imagePicker release];
    newMedia = NO;
    
    
    NSLog(@"Showing photolib - DONE@");
    
    return;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.popoverController dismissPopoverAnimated:true];
        [popoverController release];
    }
    
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    [self dismissModalViewControllerAnimated:YES];
    
    // Handle a still image picked from a photo album
    
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *originalImage, *editedImage, *imageToUse;

        editedImage = (UIImage *) [info objectForKey:
                               UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                 UIImagePickerControllerOriginalImage];
    
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        // Do something with imageToUse
        imageView.image = imageToUse;
        NSLog(@"Setting image %@", imageToUse);
        
        if (newMedia)
            UIImageWriteToSavedPhotosAlbum(imageToUse,
                                           self,  
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
        
    }
}


-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"\
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) useCamera: (id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  nil];
        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker
                                animated:YES];
        [imagePicker release];
        newMedia = YES;
    }
}

- (IBAction) useStash: (id)sender {
    spinner.hidden = FALSE;
	[spinner startAnimating];
    DeviantArt *dA = [stashAppDelegate currentDelegate].deviantArt;
    dA.delegate = self;
    [dA postImage:[imageView image] withTitle:@"Untitled@"];
    NSLog(@"posted");
}



#pragma mark - DeviantArtDelegate
- (void)stashWasPostedWithResponse:(NSDictionary *)jsonData{
    [spinner stopAnimating];
	spinner.hidden = TRUE;
    NSLog(@"posted to http://www.deviantart.com/deviation/%@", [jsonData objectForKey:@"stashid"]);
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Stashing sucess"
                          message: @"Finished with upload"\
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    //self.output.text = [NSString stringWithFormat:@"posted to http://www.deviantart.com/deviation/%@",
    //                                              [jsonData objectForKey:@"stashid"]];
}

@end
