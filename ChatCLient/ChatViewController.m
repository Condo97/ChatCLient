//
//  ChatViewController.m
//  ChatCLient
//
//  Created by Alex Coundouriotis on 1/27/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

@synthesize receiverID, selfID, receiverUsername;

/**
 The CoreData should be:
 Messages: selfID:receiverID:userID:message
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:receiverUsername];
    //NSString *response = [NSString stringWithFormat:@"iam:9999:%@\n", selfUserName];
    //NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    //[_handler writeData:data];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
    _handler = [NetworkHandler sharedInstance];
    _cdHandler = [CoreDataHandler sharedInstance];
    _messages = [[NSMutableArray alloc] init];
    _messages = [self getMessagesForCurrentUser];
    _originalFrame = self.view.frame;
    
    [_handler setDelegate:self];
    [_sendView setDelegate:self];
    [_sendView.textEntry setDelegate:self];
    
    NSString *response = [NSString stringWithFormat:@"getwaiting:%@:%@\n", selfID, receiverID];
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [_handler writeData:data];

    if(_messages.count > 0){
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    CGPoint point = _tableView.contentOffset;
    point.y -= _tableView.rowHeight;
    _tableView.contentOffset = point;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return [self getMessagesForCurrentUser].count;
}

-(NSMutableArray *)getMessagesForCurrentUser {
    NSMutableArray *outputMessages = [[NSMutableArray alloc] init];
    NSArray *messageFetchArray = [_cdHandler fetchFromCoreData:@"Chat"];
    for(NSInteger i = 0; i < messageFetchArray.count; i++) {
        if([messageFetchArray[i] valueForKey:@"messages"] != nil) {
            if([[[messageFetchArray[i] valueForKey:@"messages"] componentsSeparatedByString:@":"][0] isEqual:selfID] && [[[messageFetchArray[i] valueForKey:@"messages"] componentsSeparatedByString:@":"][1] isEqual:receiverID])
            [outputMessages addObject:[messageFetchArray[i] valueForKey:@"messages"]];
        }
    }
    return outputMessages;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    if(indexPath.row == 0) {
    //        SendMessageCellController *cell = [tableView dequeueReusableCellWithIdentifier:@"send" forIndexPath:indexPath];
    //        cell.delegate = self;
    //        return cell;
    
    //if (_messages.count >= indexPath.row){
    //_messages = [self getMessages];
    
    if(indexPath.row == _messages.count-1) {
        
    }
    
    NSLog(@"%ld",(long)indexPath.row);
    NSString *currentMessage = _messages[indexPath.row];//_messages[indexPath.row-1];
    //NSRange isIncomingMessage = [currentMessage rangeOfString:@"inc:"];
    //NSRange isOutgoingMessage = [currentMessage rangeOfString:@"out:"];
    
    BOOL isIncomingMessage = ([currentMessage componentsSeparatedByString:@":"][2] == receiverID);
    
    if (isIncomingMessage){
        OtherChatViewCellController *cell = [tableView dequeueReusableCellWithIdentifier:@"others" forIndexPath:indexPath];
        
        NSString *userID = [currentMessage componentsSeparatedByString:@":"][2];//[removedInc componentsSeparatedByString:@"@"][[removedInc componentsSeparatedByString:@"@"].count-1];
        NSString *message = [currentMessage componentsSeparatedByString:@":"][3];//[removedInc componentsSeparatedByString:@"@"][0];
        
        NSArray *fetchArray = [_cdHandler fetchFromCoreData:@"Chat"]; //ID:NAME
        
        NSString *theName = @"";
        
        cell.userID.text = theName;
        cell.otherChatCell.text = message;
        return cell;
        
    } else {
        SelfChatViewControllerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"self" forIndexPath:indexPath];
        NSString *result = [currentMessage componentsSeparatedByString:@":"][3];
        cell.selfChatCell.text = result;
        return cell;
        
    }
}

-(void)messageReceived:(NSString *)command withContents:(NSArray *)contents  {
    if([command isEqualToString:@"msg"]) {
        if([contents[0] isEqual:receiverID]) {
            [_cdHandler saveToCoreData:[NSString stringWithFormat:@"%@:%@:%@:%@",selfID,receiverID,contents[0],contents[2]] entityName:@"Chat" forKey:@"messages"];
            
            NSString *response = [NSString stringWithFormat:@"delivered:%@\n",contents[1]];
            NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
            [_handler writeData:data];
        }
    }
    
    _messages = [self getMessagesForCurrentUser];
    [self.tableView reloadData];
    
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    CGPoint point = _tableView.contentOffset;
    point.y -= _tableView.rowHeight;
    _tableView.contentOffset = point;
}

-(void)didTapSendButton:(NSString *)text {
    NSString *formattedMessage = [NSString stringWithFormat:@"%@:%@:%@:%@",selfID,receiverID,selfID,text];
    [_cdHandler saveToCoreData:formattedMessage entityName:@"Chat" forKey:@"messages"];
    //[_messages addObject:formattedMessage];
    NSString *response  = [NSString stringWithFormat:@"msg:%@:%@\n",receiverID,text];
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [_handler writeData:data];//[_handler write:[data bytes] maxLength:[data length]];
    _messages = [self getMessagesForCurrentUser];
    
    [self.tableView reloadData];
    
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    CGPoint point = _tableView.contentOffset;
    point.y -= _tableView.rowHeight;
    _tableView.contentOffset = point;
}

-(void)keyboardWillShow:(NSNotification *)notification {
    // Animate the current
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    [UIView animateWithDuration:0.3f animations:^ {
        self.view.frame = CGRectMake(0, 0-keyboardSize.height, self.view.frame.size.width, self.view.frame.size.height);//-keyboardSize.height);
    }];
}

-(void)keyboardWillHide {
    // Animate the current view back to its original position
    [UIView animateWithDuration:0.3f animations:^ {
        self.view.frame = _originalFrame;
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self didTapSendButton:textField.text];
    [textField setText:@""];
    [textField resignFirstResponder];
    return YES;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

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

- (IBAction)clear:(id)sender {
    [_cdHandler clearChat];
    [_tableView reloadData];
}
@end
