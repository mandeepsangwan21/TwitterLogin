//
//  MainViewController.h
//  TwitterLogin
//
//  Created by SitesSimply PTY. LTD on 14/12/2015.
//  Copyright © 2015 SitesSimply PTY. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthConsumer.h"
#import "AppDelegate.h"

@interface MainViewController : UIViewController<UIWebViewDelegate>
{
    IBOutlet UIWebView *webview;
    OAConsumer* consumer;
    OAToken* requestToken;
    OAToken* accessToken;
}
@property (nonatomic,strong) OAToken* accessToken;
@property (nonatomic, retain) IBOutlet UIWebView *webview;
@property (nonatomic, retain) NSString *isLogin;

@end
