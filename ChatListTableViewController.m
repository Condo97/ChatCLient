//
//  ChatListTableViewController.m
//  ChatCLient
//
//  Created by Alex Coundouriotis on 3/15/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "ChatListTableViewController.h"

@interface ChatListTableViewController ()

@property (nonatomic) NSString *receiverToChatWith;
@property (strong, nonatomic) NSMutableArray *openChatArray;
@property (strong, nonatomic) NSString *selectedUsername;

@end

@implementation ChatListTableViewController

@synthesize selfUserID;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSLog(selfUserID);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
    _handler = [NetworkHandler sharedInstance];
    _cdHandler = [CoreDataHandler sharedInstance];
    
    [_handler setDelegate:self];
    
    NSString *openChatMessage = [NSString stringWithFormat:@"getallopenchats:%@\n", selfUserID];
    NSData *data = [[NSData alloc] initWithData:[openChatMessage dataUsingEncoding:NSASCIIStringEncoding]];
    [_handler writeData:data];
    
    _openChatArray = [self getOpenChats];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)newChat:(id)sender {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"New Chat"
                                                                              message: @"Enter username to chat with!"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"username";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray *textfields = alertController.textFields;
        UITextField *usernameField = textfields[0];
        
        NSString *openChatMessage = [NSString stringWithFormat:@"getidforusername:%@\n", usernameField.text];
        NSData *data = [[NSData alloc] initWithData:[openChatMessage dataUsingEncoding:NSASCIIStringEncoding]];
        [_handler writeData:data];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)messageReceived:(NSString *)message withContents:(NSArray *)contents {
    if([message isEqualToString:@"useridforgivenusername"]) {
        if(![contents[0] isEqualToString:@"-1"]) {
//            [_cdHandler saveToCoreData:contents[0] entityName:@"OpenChats" forKey:@"uername"];
//            NSNumber *uhh = [NSNumber numberWithInteger:[contents[1] integerValue]];
            NSString *finalString = [NSString stringWithFormat:@"%@:%@",contents[1],contents[0]]; //userID:username
            [_cdHandler saveToCoreData:finalString entityName:@"OpenChats" forKey:@"userIDandusername"];
            _receiverToChatWith = contents[1];
            [self performSegueWithIdentifier:@"toChatViewController" sender:nil];
        }
    } else if([message isEqualToString:@"chat"]) {
        NSArray *outputChatArray = [_cdHandler fetchFromCoreData:@"OpenChats"];
        BOOL exists = false;
        for(NSInteger i = 0; i < outputChatArray.count; i++) {
            if([outputChatArray[i] valueForKey:@"userIDandusername"] != nil) {
                if(!([[outputChatArray[i] valueForKey:@"userIDandusername"] componentsSeparatedByString:@":"][0] == contents[0] || [[outputChatArray[i] valueForKey:@"userIDandusername"] componentsSeparatedByString:@":"][0] == contents[1])) {
                    exists = true;
                }
            }
        }
        
        if(!exists) {
            NSString *theOtherUserID = @"";
            if(contents[0] != selfUserID)
                theOtherUserID = [[NSString alloc] initWithString:(@"%@",contents[0])];
            else
                theOtherUserID = [[NSString alloc] initWithString:(@"%@",contents[1])];
            
            NSString *openChatMessage = [NSString stringWithFormat:@"who:%@\n", theOtherUserID];
            NSData *data = [[NSData alloc] initWithData:[openChatMessage dataUsingEncoding:NSASCIIStringEncoding]];
            [_handler writeData:data];
        }
        [self.tableView reloadData];
    } else if([message isEqualToString:@"uis"]) {
        if(![contents[0] isEqualToString:@"-1"]) {
            //            [_cdHandler saveToCoreData:contents[0] entityName:@"OpenChats" forKey:@"uername"];
            //            NSNumber *uhh = [NSNumber numberWithInteger:[contents[1] integerValue]];
            NSString *finalString = [NSString stringWithFormat:@"%@:%@",contents[1],contents[0]]; //userID:username
            [_cdHandler saveToCoreData:finalString entityName:@"OpenChats" forKey:@"userIDandusername"];
            _receiverToChatWith = contents[1];
            [self performSegueWithIdentifier:@"toChatViewController" sender:nil];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"toChatViewController"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        
        ChatViewController *controller = [segue destinationViewController];
        [controller setReceiverID:_receiverToChatWith];
        [controller setSelfID:selfUserID];
        [controller setReceiverUsername:_selectedUsername];
        //[controller setSelfUserName:_inputNameField.text]; //SET VARIABLES IN OTHER CLASSES!!! WOW
        //controller.selfUserName = _inputNameField.text;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    
    
    return [self getOpenChats].count;
}

-(NSMutableArray *)getOpenChats {
    NSMutableArray *outputChats = [[NSMutableArray alloc] init];
    NSArray *outputChatArray = [_cdHandler fetchFromCoreData:@"OpenChats"];
    for(NSInteger i = 0; i < outputChatArray.count; i++) {
        if([outputChatArray[i] valueForKey:@"userIDandusername"] != nil) {
            [outputChats addObject:[outputChatArray[i] valueForKey:@"userIDandusername"]];
        }
    }
    return outputChats;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatCellController *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
    
    NSString *username = [_openChatArray[indexPath.row] componentsSeparatedByString:@":"][0];
    
    cell.username.text = username;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _receiverToChatWith = [_openChatArray[indexPath.row] componentsSeparatedByString:@":"][1];
    _selectedUsername = [_openChatArray[indexPath.row] componentsSeparatedByString:@":"][0];
    [self performSegueWithIdentifier:@"toChatViewController" sender:nil];
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
