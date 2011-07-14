//
//  DeviantArt.h
//  stash
//
//  Created by Brett Gibson on 6/10/11.
//  Copyright 2011 Brett Gibson. All rights reserved.
//

#import "NXOAuth2ClientDelegate.h"
#import "NXOAuth2ConnectionDelegate.h"

#import <UIKit/UIKit.h>

@protocol DeviantArtDelegate
- (void)stashWasPostedWithResponse:(NSDictionary *)jsonData;
@end

@class NXOAuth2Client;

@interface DeviantArt : NSObject<
  NXOAuth2ClientDelegate,
  NXOAuth2ConnectionDelegate> {
}

@property (nonatomic, retain) NXOAuth2Client *oauthClient;
@property (nonatomic, retain) UIImage *imageToUpload;
@property (nonatomic, copy) NSString *titleForUpload;
@property (nonatomic, assign) id<DeviantArtDelegate> delegate;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)postImage:(UIImage *)img withTitle:(NSString *)title;

@end
