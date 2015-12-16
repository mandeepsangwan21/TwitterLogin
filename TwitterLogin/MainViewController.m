//
//  MainViewController.m
//  TwitterLogin
//
//  Created by SitesSimply PTY. LTD on 14/12/2015.
//  Copyright © 2015 SitesSimply PTY. LTD. All rights reserved.
//


#import "MainViewController.h"

NSString *client_id = @"GtJqVCX8VV4vrZ3z2loPCblay";
NSString *secret = @"2kcQlh6x8ZaX7A6PQ0KCDP8gk91gXvrJIrjNNIDXDcqhbSQshO";
NSString *callback = @"https://TwitterLoginDemo.com/callback";

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize webview, isLogin,accessToken;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [super viewDidLoad];
    consumer = [[OAConsumer alloc] initWithKey:client_id secret:secret];
    NSURL* requestTokenUrl = [NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"];
    OAMutableURLRequest* requestTokenRequest = [[OAMutableURLRequest alloc] initWithURL:requestTokenUrl
                                                                               consumer:consumer
                                                                                  token:nil
                                                                                  realm:nil
                                                                      signatureProvider:nil];
    OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:callback];
    [requestTokenRequest setHTTPMethod:@"POST"];
    [requestTokenRequest setParameters:[NSArray arrayWithObject:callbackParam]];
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
    [dataFetcher fetchDataWithRequest:requestTokenRequest
                             delegate:self
                    didFinishSelector:@selector(didReceiveRequestToken:data:)
                      didFailSelector:@selector(didFailOAuth:error:)];
    
    
  //  NSURL *req = [NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"];
//    http://upload.twitter.com/1/statuses/update_with_media.json
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)didReceiveRequestToken:(OAServiceTicket*)ticket data:(NSData*)data {
    NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    requestToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
    
    NSURL* authorizeUrl = [NSURL URLWithString:@"https://api.twitter.com/oauth/authorize"];
    OAMutableURLRequest* authorizeRequest = [[OAMutableURLRequest alloc] initWithURL:authorizeUrl
                                                                            consumer:nil
                                                                               token:nil
                                                                               realm:nil
                                                                   signatureProvider:nil];
    NSString* oauthToken = requestToken.key;
    OARequestParameter* oauthTokenParam = [[OARequestParameter alloc] initWithName:@"oauth_token" value:oauthToken];
    [authorizeRequest setParameters:[NSArray arrayWithObject:oauthTokenParam]];
    
    [webview loadRequest:authorizeRequest];
    
    
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    //  [indicator startAnimating];
    NSString *temp = [NSString stringWithFormat:@"%@",request];
    //  BOOL result = [[temp lowercaseString] hasPrefix:@"http://codegerms.com/callback"];
    // if (result) {
    NSRange textRange = [[temp lowercaseString] rangeOfString:[@"https://TwitterLoginDemo.com/callback" lowercaseString]];
    
    if(textRange.location != NSNotFound){
        
        // Extract oauth_verifier from URL query
        NSString* verifier = nil;
        NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
        for (NSString* param in urlParams) {
            NSArray* keyValue = [param componentsSeparatedByString:@"="];
            NSString* key = [keyValue objectAtIndex:0];
            if ([key isEqualToString:@"oauth_verifier"]) {
                verifier = [keyValue objectAtIndex:1];
                break;
            }
        }
        
        if (verifier) {
            NSURL* accessTokenUrl = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
            OAMutableURLRequest* accessTokenRequest = [[OAMutableURLRequest alloc] initWithURL:accessTokenUrl consumer:consumer token:requestToken realm:nil signatureProvider:nil];
            OARequestParameter* verifierParam = [[OARequestParameter alloc] initWithName:@"oauth_verifier" value:verifier];
            [accessTokenRequest setHTTPMethod:@"POST"];
            [accessTokenRequest setParameters:[NSArray arrayWithObject:verifierParam]];
            OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
            [dataFetcher fetchDataWithRequest:accessTokenRequest
                                     delegate:self
                            didFinishSelector:@selector(didReceiveAccessToken:data:)
                              didFailSelector:@selector(didFailOAuth:error:)];
        } else {
            // ERROR!
        }
        
        [webView removeFromSuperview];
        
        return NO;
    }
    
    return YES;
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    // ERROR!
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    // [indicator stopAnimating];
}

- (void)didReceiveAccessToken:(OAServiceTicket*)ticket data:(NSData*)data {
    NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    accessToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
    // WebServiceSocket *connection = [[WebServiceSocket alloc] init];
    //  connection.delegate = self;
    NSString *pdata = [NSString stringWithFormat:@"type=2&token=%@&secret=%@&login=%@", accessToken.key, accessToken.secret, self.isLogin];
    // [connection fetch:1 withPostdata:pdata withGetData:@"" isSilent:NO];
    NSLog(@"%@",accessToken.secret);
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Twitter Access Tooken"
                              message:pdata
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
    
    
        // Url for upload pictures
    
    
}
- (IBAction)tweetThis:(id)sender {
    
    NSURL *finalURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];
                       
                       OAMutableURLRequest *theRequest = [[OAMutableURLRequest alloc] initWithURL:finalURL
                                                                                         consumer:consumer
                                                                                            token:accessToken
                                                                                            realm: nil
                                                                                signatureProvider:nil];
                       
                       [theRequest setHTTPMethod:@"POST"];
                       [theRequest setTimeoutInterval:120];
                       [theRequest setHTTPShouldHandleCookies:NO];
                       
                       // Set headers for client information, for tracking purposes at Twitter.(This is optional)
//                       [theRequest setValue:@"TestIphone" forHTTPHeaderField:@"X-Twitter-Client"];
//                       [theRequest setValue:@"1.1" forHTTPHeaderField:@"X-Twitter-Client-Version"];
//                       [theRequest setValue:@"http://www.TestIphone.com/" forHTTPHeaderField:@"X-Twitter-Client-URL"];
    
                       NSString *boundary = @"--Hi all, First Share"; // example taken and implemented.
                       NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
                       [theRequest setValue:contentType forHTTPHeaderField:@"content-type"];
                       
                       NSMutableData *body = [NSMutableData data];
                       
                       [body appendData:[[NSString stringWithFormat:@"--%@\r\n\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                       [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"status\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                       [body appendData:[[NSString stringWithFormat:@"%@",@"latest upload"] dataUsingEncoding:NSUTF8StringEncoding]];
                       [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                       [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                       [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"media[]\"; filename=\"notes.png\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                       [body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                       [body appendData:[NSData dataWithData:UIImageJPEGRepresentation([UIImage imageNamed:@"notes.png"], 0.5)]];
                       [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                       [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                       
                       [theRequest prepare];
                       
                       NSString *oAuthHeader = [theRequest valueForHTTPHeaderField:@"Authorization"];
                       [theRequest setHTTPBody:body];
                       
                       NSHTTPURLResponse *response = nil;
                       NSError *error = nil;
                       
                       NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest
                                                                    returningResponse:&response                            
                                                                                error:&error];
                       NSString *responseString = [[NSString alloc] initWithData:responseData                                
                                                                        encoding:NSUTF8StringEncoding];
}

- (void)didFailOAuth:(OAServiceTicket*)ticket error:(NSError*)error {
    // ERROR!
}

@end
