//
//  ViewController.h
//  Socket-Server-Study
//
//  Created by SWRD on 3/12/14.
//  Copyright (c) 2014 ronghai_fan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"

@interface ViewController : UIViewController <UITextFieldDelegate, AsyncSocketDelegate> {
   //监听客户端请求
    AsyncSocket *listenrSocket;
    
    //当前请求连接的客户端
    NSMutableArray *connnectionSocketsArray;

}


- (IBAction)sendMessage:(id)sender;
@property (retain, nonatomic) IBOutlet UITextView *receiveData;
@property (retain, nonatomic) IBOutlet UITextField *sendMessage;




@end








