//
//  ViewController.m
//  Socket-Server-Study
//
//  Created by SWRD on 3/12/14.
//  Copyright (c) 2014 ronghai_fan. All rights reserved.
//

#import "ViewController.h"
#import "Config.h"

@interface ViewController ()


@end

@implementation ViewController

//定义一个bool全局变量, 用来判断当前socket是否已经开始监听socket请求
bool isRunning = NO;

- (void)viewDidLoad
{
    _receiveData.editable = NO;
    listenrSocket = [[AsyncSocket alloc] initWithDelegate:self];
    _sendMessage.delegate = self;
    connnectionSocketsArray = [[NSMutableArray alloc]initWithCapacity:40];
    [self sendMsg];
    [super viewDidLoad];
}

- (void)append:(NSString *)text {
    
    NSMutableString *string = [NSMutableString stringWithString:_receiveData.text];
    [string appendFormat:@"\n%@", text];
    _receiveData.text = string;
}

- (void)sendMsg {
    if (!isRunning) {
        NSError *error = nil;
        if (![listenrSocket acceptOnPort:_SERVER_PORT_ error:&error]) {
            return;
        }
        isRunning = YES;
        NSLog(@"开始监听");
    } else {
        NSLog(@"重新监听");
        //断开当前监听
        [listenrSocket disconnect];
        //断开所有connectionSocket
        for (int i = 0; i < connnectionSocketsArray.count; i++) {
            [[connnectionSocketsArray objectAtIndex:i] disconnect];
        }
        isRunning = NO;
    }
    
}

- (IBAction)sendMessage:(id)sender {
    
    if (!(_sendMessage.text.length) == 0) {
        [listenrSocket writeData:[_sendMessage.text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Waring!"
                              message:@"Please Input Message"
                              delegate:self
                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark socketDeleaget

//连接socket出错
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    
    NSLog(@"error:%@", err.localizedDescription);
}

// 收到新的socket连接
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
    [connnectionSocketsArray addObject:newSocket];
    NSLog(@"开始连接");
   
}

//读取数据
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
    [sock readDataWithTimeout:-1 tag:0];
}

//与服务器建立连接,并发送消息
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    NSLog(@"host:%@", host);
    NSString *msg = @"Welcome To Socket Test Server";
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [sock writeData:data withTimeout:-1 tag:0];
}

//读取客户端发来的数据
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //假设当前有2个ip(10.128.18.157; 10.128.18.158)相互发送消息
    NSString *ip = @"192.168.1.102";
    //获取当前的socket
    for (int i = 0; i < connnectionSocketsArray.count; i++) {
        AsyncSocket *socket = (AsyncSocket *)[connnectionSocketsArray objectAtIndex:i];
  
        if ([socket.connectedHost isEqualToString:ip]) {
            [socket writeData:data withTimeout:-1 tag:0];
            //记录接收的信息
            if (msg) {
                [self append:msg];
                NSLog(@"%@", msg);
            } else {
                
                NSLog(@"error!");
            }
        }
        //客户端未连接
        else {
            NSString *returnMsg = @"The Other Is Not Online";
            NSData *returnData = [returnMsg dataUsingEncoding:NSUTF8StringEncoding];
            [sock writeData:returnData withTimeout:-1 tag:0];
        }
    }
}

//断开
- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    [connnectionSocketsArray removeObject:sock];
}

- (void)dealloc {
    [_receiveData release];
    [_sendMessage release];
    [super dealloc];
}
@end


