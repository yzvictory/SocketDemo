//
//  ViewController.m
//  SocketDemo
//
//  Created by yz on 15/11/5.
//  Copyright © 2015年 DeviceOne. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSStreamDelegate>
{
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
}

- (IBAction)btnConnect:(UIButton *)sender;

- (IBAction)btnSend:(UIButton *)sender;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    NSLog(@"%@",[NSThread currentThread]);
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"输入输出流打开完成");
            break;
        case NSStreamEventHasBytesAvailable:
        NSLog(@"有字节可读");
            [self readData];
            break;
        case NSStreamEventHasSpaceAvailable:
        NSLog(@"可以发送字节");
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"连接出错");
            [_inputStream close];
            [_outputStream close];
            [_inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [_outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            break;
        default:
            break;
    }
}

- (IBAction)btnConnect:(UIButton *)sender
{
    //服务端的ip地址
    NSString *host = @"192.168.1.74";
    int port = 8888;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    //连接
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)(host), port, &readStream, &writeStream);
    
    _inputStream = (__bridge NSInputStream*)(readStream);
    _outputStream = (__bridge NSOutputStream*)(writeStream);
    
    _inputStream.delegate = self;
    _outputStream.delegate = self;

    [_inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode ];
    [_outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [_inputStream open];
    [_outputStream open];
}
- (IBAction)btnSend:(UIButton *)sender
{
    NSString *message = @"hello world";
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [_outputStream write:data.bytes maxLength:data.length];
}
- (void)readData
{
    //本地缓存
    uint8_t buf[1024];
    NSInteger len  =[_inputStream read:buf maxLength:sizeof(buf)];
    NSData *data = [NSData dataWithBytes:buf length:len];
    NSString *recStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"receive data :%@",recStr);
}
@end




















