//
//  ViewController.m
//  PeerMotion
//
//  Created by Maria on 2018-11-15.
//  Copyright © 2018 MB. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CMMotionManager.h>

@interface ViewController (){
    BOOL connected;
}

//for pinkblock bouncing!
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic,strong) UIGravityBehavior *gravity;
@property (nonatomic,strong) UICollisionBehavior *collider;
@property (nonatomic,strong) UIDynamicItemBehavior *elastic;


@property (nonatomic, strong) CMMotionManager *motman;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCAdvertiserAssistant *assistant;
@property (strong, nonatomic) MCBrowserViewController *browserVC;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation ViewController


-(CMMotionManager *) motman{
    if(!_motman)
    {
        self.motman = [[CMMotionManager alloc] init];
        self.motman.accelerometerUpdateInterval = 1.0/15.0;
        self.motman.gyroUpdateInterval = 1.0/15.0;
    }
    return _motman;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    connected = NO;
    [self setUIToNotConnectedState];
    [self startMotion];
    [self setupSession];
    [self startGame];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (connected)
        [self setUIToConnectedState];
    else
        [self setUIToNotConnectedState];
}

-(void) startMotion{
    if (self.motman.deviceMotionAvailable) {
        [self.motman startAccelerometerUpdates];
        [self.motman startGyroUpdates];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.motman.accelerometerUpdateInterval target:self selector:@selector(pollMotion:) userInfo:nil repeats:YES];
    }
}

-(void) pollMotion:(NSTimer *)timer{
    CMAcceleration acc = self.motman.accelerometerData.acceleration;
    CMRotationRate rot = self.motman.gyroData.rotationRate;
    NSMutableArray *data =[[NSMutableArray alloc]init ];
    
    float x, y, z, rx, ry, rz;
    x = acc.x;
    y = acc.y;
    z = acc.z;
    rx= rot.x;
    ry = rot.y;
    rz = rot.z;
    self.acc_x.text = [NSString stringWithFormat:@"%.5f",x];
    self.acc_y.text = [NSString stringWithFormat:@"%.5f",y];
    self.acc_z.text = [NSString stringWithFormat:@"%.5f",z];
    self.rot_x.text = [NSString stringWithFormat:@"%.5f",rx];
    self.rot_y.text = [NSString stringWithFormat:@"%.5f",ry];
    self.rot_z.text = [NSString stringWithFormat:@"%.5f",rz];
    
    [data addObject:self.acc_x.text];
    [data addObject:self.acc_y.text];
    [data addObject:self.acc_z.text];
    [data addObject:self.rot_x.text];
    [data addObject:self.rot_y.text];
    [data addObject:self.rot_z.text];
    
    NSArray *myPeer = self.session.connectedPeers;
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:data requiringSecureCoding:NO error:nil ]
                   toPeers:myPeer
                  withMode:MCSessionSendDataReliable error:nil];
    NSLog(@"Peer: %@",myPeer.description);
}
-(void)setupSession
{
    // Prepare session
    MCPeerID *myPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    self.session = [[MCSession alloc] initWithPeer:myPeerID];
    self.session.delegate = self;
    
    // Start advertising
    self.assistant = [[MCAdvertiserAssistant alloc] initWithServiceType:@"MDA184" discoveryInfo:nil session:self.session];
    [self.assistant start];
}
#pragma mark <MCSessionDelegate> methods
// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (state == MCSessionStateConnected)
    {
//self.statusLabel.text = [str stringByAppendingString:@" connected"];
       [self setUIToConnectedState];
        connected = YES;
    }
    else if (state == MCSessionStateNotConnected)
    {
        //self.statusLabel.text = [str stringByAppendingString:@" not connected"];
        [self setUIToNotConnectedState];
        connected = NO;
    }
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSArray *arrayData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"here");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.acc_px.text = [NSString stringWithFormat:@"%@",arrayData[0]];
        self.acc_py.text = [NSString stringWithFormat:@"%@",arrayData[1]];
        self.acc_pz.text = [NSString stringWithFormat:@"%@",arrayData[2]];
        self.rot_px.text = [NSString stringWithFormat:@"%@",arrayData[3]];
        self.rot_py.text = [NSString stringWithFormat:@"%@",arrayData[4]];
        self.rot_pz.text = [NSString stringWithFormat:@"%@",arrayData[5]];
        float x = [arrayData[0] doubleValue];
        float y = [arrayData[1] doubleValue];
        
        //sending the information to move the pinkblock to the peer's info
        self.gravity.gravityDirection = CGVectorMake(x, y);
        switch(self.supportedInterfaceOrientations){
            case UIInterfaceOrientationMaskLandscapeRight:
                self.gravity.gravityDirection = CGVectorMake(-y, -x); break;
            case UIInterfaceOrientationMaskLandscapeLeft:
                self.gravity.gravityDirection = CGVectorMake(y, x); break;
            case UIInterfaceOrientationMaskPortrait:
                self.gravity.gravityDirection = CGVectorMake(x, -y); break;
            case UIInterfaceOrientationMaskPortraitUpsideDown:
                self.gravity.gravityDirection = CGVectorMake(-x, y); break;
        }
    });
    
    
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}



- (IBAction)browseActn:(id)sender {
    self.browserVC = [[MCBrowserViewController alloc] initWithServiceType:@"MDA184" session:self.session];
    self.browserVC.delegate = self;
    [self presentViewController:self.browserVC animated:YES completion:nil];
}

- (IBAction)disconnectActn:(UIButton *)sender {
    [self setUIToNotConnectedState];
    connected = NO;
    [self.session disconnect];
}

- (IBAction)stopActn:(UIButton *)sender {
    [self stopMonitoringMotion];
    
}

#pragma mark
#pragma mark <MCBrowserViewControllerDelegate> methods

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)stopMonitoringMotion
{
    [self.motman stopAccelerometerUpdates];
    [self.motman stopGyroUpdates];
}

- (void)startMonitoringMotion
{
    [self.motman startAccelerometerUpdates];
    [self.motman startGyroUpdates];
}

#pragma mark
#pragma mark helpers

- (void)setUIToNotConnectedState
{
    //self.sendButton.enabled = NO;
    self.disconnectBtn.enabled = NO;
    self.browseBtn.enabled = YES;
}

- (void)setUIToConnectedState
{
    //self.sendButton.enabled = YES;
    self.disconnectBtn.enabled = YES;
    self.browseBtn.enabled = NO;
}

///BOUNCING PINK FRAME

-(void) startGame
{
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.gravity = [[UIGravityBehavior alloc]initWithItems:@[self.pinkBlock]];
    [self.animator addBehavior:self.gravity];
    self.collider = [[UICollisionBehavior alloc]initWithItems:@[self.pinkBlock]];
    self.collider.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:self.collider];
}



@end
