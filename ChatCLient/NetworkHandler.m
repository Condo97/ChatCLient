//
//  NetworkHandler.m
//  ChatCLient
//
//  Created by Alex Coundouriotis on 1/27/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "NetworkHandler.h"

@implementation NetworkHandler
@synthesize delegate = _delegate;

+ (NetworkHandler *)sharedInstance {
    static dispatch_once_t onceToken;
    static NetworkHandler *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[NetworkHandler alloc] init];
    });
    return instance;
}

-(NSStreamStatus)initNetworkCommunication:(CFStringRef)ip {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)ip, 80, &readStream, &writeStream);
    _inputStream = (__bridge NSInputStream *)(readStream);//_inputStream = (NSInputStream *)readStream;
    _outputStream = (__bridge NSOutputStream *)writeStream;
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    [_outputStream open];
    NSStreamStatus *socketStatus = [_outputStream streamStatus];
    int status = socketStatus;
    NSLog(@"Stream Status is %i", status);
    return status;
}

-(NSStreamStatus)writeData:(NSData *)data {
    NSLog(@"%ld",(long)[_outputStream write:[data bytes] maxLength:[data length]]);
    NSLog(@"%lu",(unsigned long)[data length]);
    NSStreamStatus *socketStatus = [_outputStream streamStatus];
    int status = socketStatus;
    NSLog(@"Stream Status is %i", status);
    return status;
}

-(NSStreamStatus)getStreamStatus {
    return [_outputStream streamStatus];
}

-(void)closeStream {
    [_inputStream close];
    [_outputStream close];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    switch (streamEvent) {
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
            if (theStream == _inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([_inputStream hasBytesAvailable]) {
                    len = [_inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            NSLog(@"server said: %@", output);
                            [self parseInput:output];
                            //[self.delegate messageReceived:output];
                        }
                    }
                }
            }
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"Can not connect to the host!");
            break;
            
        case NSStreamEventEndEncountered:
            break;
            
        default:
            NSLog(@"Unknown event");
    }
    
}


-(void)parseInput:(NSString *)input {
    NSArray *messages = [input componentsSeparatedByString:@"\n"];
    if(messages.count > 0) {
        for(NSInteger i = 0; i < messages.count; i++) {
            NSString *message = messages[i];
            if([message rangeOfString:@":"].location != NSNotFound) {
                //Parse Message
                NSString *command = [message componentsSeparatedByString:@":"][0];
                //[message componentsSeparatedByString:@":"][1];
                
                if([command isEqual:@"waiting"]) {
                    
                } else {
                    NSRange nRange = [message rangeOfString:@"\n"];
                    
                    if(nRange.location != NSNotFound) {
                        message = [message stringByReplacingCharactersInRange:nRange withString:@""];
                    }
                    
                    NSLog(@"%@", command);
                    if([command isEqual: @"uis"]) {
                        NSString *userID = [message componentsSeparatedByString:@":"][1];
                        NSString *userName = [message componentsSeparatedByString:@":"][2];
                        NSArray *contents = [[NSArray alloc] initWithObjects:userName,userID, nil];
                        [self.delegate messageReceived:@"uis" withContents:contents];
                        
                        //[_cdHandler saveToCoreData:[NSString stringWithFormat:@"%@:%@",userName,userNumber] entityName:@"Chat" forKey:@"user"];
                        message = nil;
                    } else if ([command isEqual: @"msg"]) {
                        NSString *fromUser = [message componentsSeparatedByString:@":"][1];
                        NSString *theID = [message componentsSeparatedByString:@":"][2];
                        NSString *theMsg = [message componentsSeparatedByString:@":"][3];
                        NSArray *contents = [[NSArray alloc] initWithObjects:fromUser,theID,theMsg, nil];
                        
                        [self.delegate messageReceived:@"msg" withContents:contents];
                        //message = suffix;
                    } else if ([command isEqual: @"useridforgivenusername"]) {
                        NSString *username = [message componentsSeparatedByString:@":"][1];
                        NSString *userID = [message componentsSeparatedByString:@":"][2];
                        NSArray *contents = [[NSArray alloc] initWithObjects:username,userID, nil];
                        [self.delegate messageReceived:@"useridforgivenusername" withContents:contents];
                    } else if ([command isEqual: @"iam"]) {
                        NSString *userID = [message componentsSeparatedByString:@":"][1];
                        NSArray *contents = [[NSArray alloc] initWithObjects:userID, nil];
                        [self.delegate messageReceived:@"iam" withContents:contents];
                    } else if ([command isEqual:@"reg"]) {
                        NSString *success = [message componentsSeparatedByString:@":"][1];
                        NSArray *contents = [[NSArray alloc] initWithObjects:success, nil];
                        [self.delegate messageReceived:@"reg" withContents:contents];
                    } else if ([command isEqual:@"chat"]) {
                        NSString *userID1 = [message componentsSeparatedByString:@":"][1];
                        NSString *userID2 = [message componentsSeparatedByString:@":"][2];
                        NSArray *contents = [[NSArray alloc] initWithObjects:userID1, userID2, nil];
                        [self.delegate messageReceived:@"chat" withContents:contents];
                    }
                }
                
                //Save Message to CoreData and to Chat Window
                if (message != nil) {
                    NSString *formattedMessage = [NSString stringWithFormat:@"inc:%@",message];
                    //[_messages addObject:formattedMessage];
                    //[_cdHandler saveToCoreData:formattedMessage entityName:@"Chat" forKey:@"messages"];
                    
                }
            }
        }
    }
}

@end
