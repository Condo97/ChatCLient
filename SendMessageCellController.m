//
//  SendMessageCellController.m
//  ChatCLient
//
//  Created by Alex Coundouriotis on 1/27/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "SendMessageCellController.h"

@implementation SendMessageCellController
@synthesize delegate = _delegate;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

- (IBAction)sendButton:(id)sender {
    [self.delegate didTapSendButton:self.textEntry.text];
    [self.textEntry setText:@""];
}

@end
