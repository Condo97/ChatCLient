//
//  ChatViewController.h
//  ChatCLient
//
//  Created by Alex Coundouriotis on 1/27/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SendMessageCellController.h"
#import "ViewController.h"
#import "OtherChatViewCellController.h"
#import "SelfChatViewControllerCell.h"
#import "NetworkHandler.h"
#import "CoreDataHandler.h"


@interface ChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSStreamDelegate, SendDelegate, NetworkHandlerDataSource, UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NetworkHandler *handler;
@property (strong, nonatomic) CoreDataHandler *cdHandler;
@property (strong, nonatomic) NSString *receiverID;
@property (strong, nonatomic) NSString *selfID;
@property (strong, nonatomic) NSString *receiverUsername;
- (IBAction)clear:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet SendMessageCellController *sendView;
@property (assign, nonatomic) CGRect originalFrame;

@end
