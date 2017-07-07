//
//  ViewController.m
//  ChatCLient
//
//  Created by Alex Coundouriotis on 1/26/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSString *selfUserID;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_disconnectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    _handler = [NetworkHandler sharedInstance];
    [_handler setDelegate:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"toChatListViewController"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        
        ChatListTableViewController *controller = [segue destinationViewController];
        [controller setSelfUserID:_selfUserID]; //SET VARIABLES IN OTHER CLASSES!!! WOW
        //controller.selfUserName = _inputNameField.text;
    }
}

-(void)messageReceived:(NSString *)message withContents:(NSArray *)contents {
    if([message isEqualToString:(@"iam")]) {
        if(![contents[0] isEqualToString:@"-1"]) {
            _selfUserID = contents[0];
            [self performSegueWithIdentifier:@"toChatListViewController" sender:NULL];
        }
    } else if ([message isEqualToString:@"reg"]) {
        if([contents[0] isEqualToString:@"y"]) {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Success!"
                                                                                      message: @"Login successfully registered! Chat away ;)"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"thx;);)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Fail¡"
                                                                                      message: @"Login didn't successfully register¡ User may be taken? :("
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Oh no :(" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (IBAction)joinChat:(id)sender {
    [_handler initNetworkCommunication:(CFStringRef)_ipAddressField.text];
    NSString *response = [NSString stringWithFormat:@"login:%@:%@\n",_inputUsernameField.text,_inputPasswordField.text];
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [_handler writeData:data];
}

- (IBAction)disconnect:(id)sender {
    NSLog(@"disconnect method called");
    //NSLog(@"input stream id %@", _inputStream);
    
    NSStreamStatus *socketStatus = [_handler getStreamStatus];
    int status = socketStatus;
    NSLog(@"Stream Status is %i", status);
    
    
    if (status == 2) {
        [_handler closeStream];
        [_disconnectButton setTitle:@"Connect" forState:UIControlStateNormal];
        NSLog(@"Socket Closed");
    } else {
        [_handler initNetworkCommunication:(CFStringRef)_ipAddressField.text];
        [_disconnectButton setTitle:@"Connecting..." forState:UIControlStateDisabled];

        
    }
}

- (IBAction)registerButton:(id)sender {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Register"
                                                                              message: @"Enter username and password to register!"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"username :)";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"password :)";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray *textfields = alertController.textFields;
        UITextField *usernameField = textfields[0];
        UITextField *passwordField = textfields[1];
        [_handler initNetworkCommunication:(CFStringRef)_ipAddressField.text];
        NSString *openChatMessage = [NSString stringWithFormat:@"reg:%@:%@\n", usernameField.text, passwordField.text];
        NSData *data = [[NSData alloc] initWithData:[openChatMessage dataUsingEncoding:NSASCIIStringEncoding]];
        [_handler writeData:data];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];

}

-(void)initNetworkCommunication {
    
}


@end
