//
//  DeviantArt.m
//  stash
//
//  Created by Brett Gibson on 6/10/11.
//  Copyright 2011 Brett Gibson. All rights reserved.
//

#import "DeviantArt.h"

#import "NXOAuth2Client.h"
#import "NXOAuth2Connection.h"

#import "JSONKit.h"

@interface DeviantArt ()
- (void)setupClient;
- (void)sendPostImageRequest;
- (void)addMimeBoundary:(NSMutableData *)body;
- (void)addParameter:(NSString *)param withValue:(NSString *)val toBody:(NSMutableData *)body;
- (void)addImageMimePart:(UIImage *)image toBody:(NSMutableData *)body;
@end

// app specific http://www.deviantart.com/submit/app/
// SET THESE!
NSString *const kDAOEClientID = @"47";
NSString *const kDAOECLientSecret = @"99541585d0b87569263c6558a76acac7";
// the app needs to declare that it handles the protocol in this url!
// see the "URL types" key in stash-Info.plist
NSString *const kDAOERedirectURL = @"dastash://oauth2";

// dA constants
NSString *const kDAAuthorizeURL = @"https://www.deviantart.com/oauth2/draft10/authorize";
NSString *const kDATokenURL = @"https://www.deviantart.com/oauth2/draft10/token";
NSString *const kDAStashURL = @"https://www.deviantart.com/api/draft10/submit";

// other consts
NSString *const kDAOEMimeBoundary = @"daStashAppIsFun";

@implementation DeviantArt

@synthesize oauthClient = _oauthClient, imageToUpload = _imageToUpload, 
            titleForUpload = _titleForUpload, delegate = _delegate;

#pragma mark - init dealloc and setup

- (void)dealloc{
  [_oauthClient release], _oauthClient = nil;
  [_imageToUpload release], _imageToUpload = nil;
  [_titleForUpload release], _titleForUpload = nil;
  
  [super dealloc];
}

- (id)init{
  if((self = [super init])){
    [self setupClient];
  }
  return self;
}

#pragma mark - public methods

- (BOOL)handleOpenURL:(NSURL *)url{
  BOOL ret = [self.oauthClient openRedirectURL:url];
  if(ret){
    
  }
  return ret;
}

- (void)postImage:(UIImage *)img withTitle:(NSString *)title{
  self.imageToUpload = img;
  self.titleForUpload = title;
  [self.oauthClient requestAccess];
}

#pragma mark - private methods

- (void)setupClient{
  NSURL *authURL = [NSURL URLWithString:kDAAuthorizeURL];
  NSURL *tokenURL = [NSURL URLWithString:kDATokenURL];
  
  self.oauthClient = [[[NXOAuth2Client alloc] initWithClientID:kDAOEClientID
                                                  clientSecret:kDAOECLientSecret
                                                  authorizeURL:authURL
                                                      tokenURL:tokenURL
                                                      delegate:self] autorelease];
}

- (void)addMimeBoundary:(NSMutableData *)body{
  NSString *boundaryString = [NSString stringWithFormat:@"\r\n--%@\r\n", kDAOEMimeBoundary];
  [body appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
}

   
- (void)addParameter:(NSString *)param withValue:(NSString *)val toBody:(NSMutableData *)body{
  
  [self addMimeBoundary:body];
  NSString *partHeader = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",
                                                    param];
  [body appendData:[partHeader dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[val dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)addImageMimePart:(UIImage *)image toBody:(NSMutableData *)body{
  [self addMimeBoundary:body];
  NSString *header = @"Content-Disposition: form-data; name=\"media\"; filename=\"upload.jpg\"\r\n";
  NSString *enc = @"Content-Transfer-Encoding: image/jpg\r\n\r\n";
  [body appendData:[header dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[enc dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:UIImageJPEGRepresentation(image, 0.9)];
}

- (void)sendPostImageRequest{
  if(self.imageToUpload){
    NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] 
                                initWithURL:[NSURL URLWithString:kDAStashURL] 
                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData 
                                timeoutInterval:90] autorelease];
		
		NSMutableDictionary *headers = [NSMutableDictionary dictionary];
		[headers setObject:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",
                       kDAOEMimeBoundary]
                forKey:@"Content-Type"];
		
		[req setAllHTTPHeaderFields:headers];	
		[req setHTTPMethod:@"POST"];
		
		NSMutableData *body = [NSMutableData data];
    
    [self addParameter:@"title" withValue:self.titleForUpload toBody:body];
    [self addImageMimePart:self.imageToUpload toBody:body];

		
    NSString *finalBoundary = [NSString stringWithFormat:@"\r\n--%@--\r\n", kDAOEMimeBoundary]; 
		[body appendData:[finalBoundary dataUsingEncoding:NSUTF8StringEncoding]];
		
		[req setHTTPBody:body];
		
    [[[NXOAuth2Connection alloc] initWithRequest:req 
                               requestParameters:nil
                                     oauthClient:self.oauthClient 
                                        delegate:self] autorelease];
  }
  self.imageToUpload = nil;
}

#pragma mark - NXOAuth2ClientDelegate
- (void)oauthClientNeedsAuthentication:(NXOAuth2Client *)client{
  NSURL *redirectURL = [NSURL URLWithString:kDAOERedirectURL];
  NSURL *authorizationURL = [client authorizationURLWithRedirectURL:redirectURL];
  [[UIApplication sharedApplication] openURL:authorizationURL];
}

- (void)oauthClientDidGetAccessToken:(NXOAuth2Client *)client{
  [self sendPostImageRequest];
}
- (void)oauthClientDidLoseAccessToken:(NXOAuth2Client *)client{
  NSLog(@"oauthClientDidLoseAccessToken");
}
- (void)oauthClient:(NXOAuth2Client *)client didFailToGetAccessTokenWithError:(NSError *)error{
  NSLog(@"didFailToGetAccessTokenWithError %@ %@", client, error);
}

#pragma mark - NXOAuth2ConnectionDelegate

- (void)oauthConnection:(NXOAuth2Connection *)connection 
     didReceiveResponse:(NSURLResponse *)response{
  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
  if ([httpResponse statusCode] >= 400) {
//    NSLog(@"response erred with code %d", [httpResponse statusCode]);
  }else{
//    NSLog(@"response succeeded with code %d", [httpResponse statusCode]);
  }
}

- (void)oauthConnection:(NXOAuth2Connection *)connection 
      didFinishWithData:(NSData *)data{
  if(self.delegate){
    NSDictionary *respJson = [data objectFromJSONData];
    [self.delegate stashWasPostedWithResponse:respJson];
  }
}

@end
