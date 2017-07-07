//
//  ViewController.h
//  ChatCLient
//
//  Created by Alex Coundouriotis on 1/26/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkHandler.h"
#import "ChatListTableViewController.h"


@interface ViewController : UIViewController <NSStreamDelegate, NetworkHandlerDataSource>

@property (strong, nonatomic) IBOutlet UIView *joinView;
@property (weak, nonatomic) IBOutlet UITextField *inputUsernameField;
@property (weak, nonatomic) IBOutlet UITextField *ipAddressField;
@property (weak, nonatomic) IBOutlet UITextField *inputPasswordField;
- (IBAction)joinChat:(id)sender;
- (IBAction)disconnect:(id)sender;

@property (strong, nonatomic) NetworkHandler *handler;

+(NSOutputStream *)getOutputStream;
+(NSInputStream *)getInputStream;

@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;

@end

