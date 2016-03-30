//
//  ViewController.m
//  Video_transcribe
//
//  Created by 周剑 on 16/1/16.
//  Copyright © 2016年 bukaopu. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

// 记录是录像还是拍照
@property (nonatomic, assign) BOOL isVideo;
@property (nonatomic, strong) UIImagePickerController *imagePC;

// 播放视频的播放器
@property (nonatomic, strong) AVPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isVideo = YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self presentViewController:self.imagePC animated:YES completion:nil];
}

- (UIImagePickerController *)imagePC {
    if (!_imagePC) {
        _imagePC = [[UIImagePickerController alloc] init];
        // 设置imagepc的来源,摄像头
        _imagePC.sourceType = UIImagePickerControllerSourceTypeCamera;
        // 设置前置还是后置摄像头
        _imagePC.cameraDevice = UIImagePickerControllerCameraDeviceFront; // 前置
        if (self.isVideo) {
            // 设置视频类型
            _imagePC.mediaTypes = @[(NSString *)kUTTypeMovie];
            // 设置视频质量
            _imagePC.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
            // 设置摄像头模式为视频
            _imagePC.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        }else {
            // 拍照
            _imagePC.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        }
        // 允许编辑
        _imagePC.allowsEditing = YES;
        // 设置代理
        _imagePC.delegate = self;
    }
    return _imagePC;
}


// 完成之后的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // imagepc的类型
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        // 视频路径
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *urlString = [url path];
        // 判断是否是保存在的系统相册里面
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlString)) {
            // 视频保存到相册,使用ALAssetsLibrary来保存
            UISaveVideoAtPathToSavedPhotosAlbum(urlString, self, @selector(video:didFinishSavingWithError:contextInfo:), nil); // 保存视频到系统相册
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"保存出现错误");
    }else {
        // 录制完之后自动播放
        NSURL *url = [NSURL fileURLWithPath:videoPath];
        self.player = [[AVPlayer alloc] initWithURL:url];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        playerLayer.frame = self.view.bounds;
        [self.view.layer addSublayer:playerLayer];
        [self.player play];
    }
}

@end
