//
//  SendMessageCellController.h
//  ChatCLient
//
//  Created by Alex Coundouriotis on 1/27/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SendDelegate <NSObject>
-(void)didTapSendButton:(NSString *)text;
@end

@interface SendMessageCellController : UIView
@property (weak, nonatomic) IBOutlet UITextField *textEntry;
- (IBAction)sendButton:(id)sender;
@property (nonatomic, unsafe_unretained) id <SendDelegate> delegate;
@end

