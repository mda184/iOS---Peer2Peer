//
//  ViewController.h
//  PeerMotion
//
//  Created by Maria on 2018-11-15.
//  Copyright © 2018 MB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <GameKit/GKPublicProtocols.h>

@interface ViewController : UIViewController < MCSessionDelegate, MCBrowserViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *acc_x;
@property (strong, nonatomic) IBOutlet UITextField *acc_y;
@property (strong, nonatomic) IBOutlet UITextField *acc_z;
@property (strong, nonatomic) IBOutlet UITextField *rot_x;
@property (strong, nonatomic) IBOutlet UITextField *rot_y;
@property (strong, nonatomic) IBOutlet UITextField *rot_z;
@property (strong, nonatomic) IBOutlet UIButton *browseBtn;
@property (weak, nonatomic) IBOutlet UIButton *disconnectBtn;
@property (strong, nonatomic) IBOutlet UIView *pinkBlock;

- (IBAction)browseActn:(id)sender;
- (IBAction)disconnectActn:(UIButton *)sender;
- (IBAction)stopActn:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet UITextField *acc_px;
@property (weak, nonatomic) IBOutlet UITextField *acc_py;
@property (weak, nonatomic) IBOutlet UITextField *acc_pz;
@property (weak, nonatomic) IBOutlet UITextField *rot_px;
@property (weak, nonatomic) IBOutlet UITextField *rot_py;
@property (weak, nonatomic) IBOutlet UITextField *rot_pz;



@end

