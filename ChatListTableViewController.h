//
//  ChatListTableViewController.h
//  ChatCLient
//
//  Created by Alex Coundouriotis on 3/15/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkHandler.h"
#import "CoreDataHandler.h"
#import "ChatViewController.h"
#import "ChatCellController.h"

@interface ChatListTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, NetworkHandlerDataSource>

@property (strong, nonatomic) NetworkHandler *handler;
@property (strong, nonatomic) CoreDataHandler *cdHandler;
@property (strong, nonatomic) NSString *selfUserID;

@end
