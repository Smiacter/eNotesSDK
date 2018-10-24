//
//  WBQRCodeScanningVC.m
//  SGQRCodeExample
//
//  Created by kingsic on 2018/2/8.
//  Copyright © 2018年 kingsic. All rights reserved.
//

#import "WBQRCodeScanningVC.h"
#import "SGQRCode.h"

// 从SGQRCodeScanningView中拷过来的值，定义了扫码框的位置信息
/** 扫描内容的 W 值 */
#define scanBorderW 0.7 * self.view.frame.size.width
/** 扫描内容的 x 值 */
#define scanBorderX 0.5 * (1 - 0.7) * self.view.frame.size.width
/** 扫描内容的 Y 值 */
#define scanBorderY 0.5 * (self.view.frame.size.height - scanBorderW)

@interface WBQRCodeScanningVC () <SGQRCodeScanManagerDelegate, SGQRCodeAlbumManagerDelegate>
@property (nonatomic, strong) SGQRCodeScanManager *manager;
@property (nonatomic, strong) SGQRCodeScanningView *scanningView;
//@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UIButton *lightButton;
@property (nonatomic, strong) UIButton *albumButton;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic,assign) BOOL lightOn;
@end

@implementation WBQRCodeScanningVC

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanningView addTimer];
    [_manager startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanningView removeTimer];
}

- (void)dealloc {
    NSLog(@"WBQRCodeScanningVC - dealloc");
    [self removeScanningView];
    
    //关闭手电筒
    if (_lightOn) {
        [_device lockForConfiguration:nil];
        [_device setTorchMode:AVCaptureTorchModeOff];
        [_device unlockForConfiguration];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.scanningView];
    [self setupNavigationBar];
    [self setupQRCodeScanning];
    [self.view addSubview:self.lightButton];
    [self.view addSubview:self.albumButton];
//    [self.view addSubview:self.promptLabel];
}

- (void)setupNavigationBar {
    self.navigationItem.title = NSLocalizedString(@"TitleQrcodeScan", nil);
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:(UIBarButtonItemStyleDone) target:self action:@selector(rightBarButtonItenAction)];
}

- (SGQRCodeScanningView *)scanningView {
    if (!_scanningView) {
        _scanningView = [[SGQRCodeScanningView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _scanningView.scanningImageName = @"SGQRCode.bundle/QRCodeScanningLineGrid";
        _scanningView.scanningAnimationStyle = ScanningAnimationStyleGrid;
        _scanningView.cornerColor = [UIColor orangeColor];
    }
    return _scanningView;
}
- (void)removeScanningView {
    [self.scanningView removeTimer];
    [self.scanningView removeFromSuperview];
    self.scanningView = nil;
}

- (void)rightBarButtonItenAction {
    SGQRCodeAlbumManager *manager = [SGQRCodeAlbumManager sharedManager];
    [manager readQRCodeFromAlbumWithCurrentController:self];
    manager.delegate = self;
    
    if (manager.isPHAuthorization == YES) {
        [self.scanningView removeTimer];
    }
}

- (void)lightClickAction {
    if (_device == nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    _lightOn = !_lightOn;
    //根据ligthOn状态判断打开还是关闭
    if (_lightOn) {
        //开启手电筒
        [_device lockForConfiguration:nil];
        [_device setTorchMode:AVCaptureTorchModeOn];
        [_device unlockForConfiguration];
    }else{
        //关闭手电筒
        [_device lockForConfiguration:nil];
        [_device setTorchMode:AVCaptureTorchModeOff];
        [_device unlockForConfiguration];
    }
}

- (void)setupQRCodeScanning {
    self.manager = [SGQRCodeScanManager sharedManager];
    NSArray *arr = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    // AVCaptureSessionPreset1920x1080 推荐使用，对于小型的二维码读取率较高
    [_manager setupSessionPreset:AVCaptureSessionPreset1920x1080 metadataObjectTypes:arr currentController:self];
    [_manager cancelSampleBufferDelegate];
    _manager.delegate = self;
}

#pragma mark - - - SGQRCodeAlbumManagerDelegate
- (void)QRCodeAlbumManagerDidCancelWithImagePickerController:(SGQRCodeAlbumManager *)albumManager {
    [self.view addSubview:self.scanningView];
    [self.view bringSubviewToFront:_lightButton];
    [self.view bringSubviewToFront:_albumButton];
}
- (void)QRCodeAlbumManager:(SGQRCodeAlbumManager *)albumManager didFinishPickingMediaWithResult:(NSString *)result {
    if (self.scanDoneBlock != nil) {
        self.scanDoneBlock(result);
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)QRCodeAlbumManagerDidReadQRCodeFailure:(SGQRCodeAlbumManager *)albumManager {
    NSLog(@"暂未识别出二维码");
}

#pragma mark - - - SGQRCodeScanManagerDelegate
- (void)QRCodeScanManager:(SGQRCodeScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects {
    NSLog(@"metadataObjects - - %@", metadataObjects);
    if (metadataObjects != nil && metadataObjects.count > 0) {
        [scanManager playSoundName:@"SGQRCode.bundle/sound.caf"];
        [scanManager stopRunning];
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSString *address = [obj stringValue];
        if (self.scanDoneBlock != nil) {
            self.scanDoneBlock(address);
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        NSLog(@"暂未识别出扫描的二维码");
    }
}

//- (UILabel *)promptLabel {
//    if (!_promptLabel) {
//        _promptLabel = [[UILabel alloc] init];
//        _promptLabel.backgroundColor = [UIColor clearColor];
//        CGFloat promptLabelX = 0;
//        CGFloat promptLabelY = 0.73 * self.view.frame.size.height;
//        CGFloat promptLabelW = self.view.frame.size.width;
//        CGFloat promptLabelH = 25;
//        _promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
//        _promptLabel.textAlignment = NSTextAlignmentCenter;
//        _promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
//        _promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
//        _promptLabel.text = @"将二维码放入框内, 即可自动扫描";
//    }
//    return _promptLabel;
//}

- (UIButton *)lightButton {
    if (!_lightButton) {
        _lightButton = [[UIButton alloc] init];
        CGFloat promptLabelX = scanBorderX;
        CGFloat promptLabelY = scanBorderY + scanBorderW + 20;
        CGFloat promptLabelW = 24;
        CGFloat promptLabelH = 46;
        _lightButton.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
        [_lightButton setImage:[UIImage imageNamed:@"icon_light"] forState:UIControlStateNormal];
        [_lightButton addTarget:self action:@selector(lightClickAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lightButton;
}

- (UIButton *)albumButton {
    if (!_albumButton) {
        _albumButton = [[UIButton alloc] init];
        CGFloat promptLabelX = scanBorderX + scanBorderW - 36;
        CGFloat promptLabelY = scanBorderY + scanBorderW + 20;
        CGFloat promptLabelW = 36;
        CGFloat promptLabelH = 36;
        _albumButton.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
        [_albumButton setImage:[UIImage imageNamed:@"icon_album"] forState:UIControlStateNormal];
        [_albumButton addTarget:self action:@selector(rightBarButtonItenAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _albumButton;
}


@end

