//
//  ViewController.m
//  LoadingImage
//
//  Created by Khada Jhin on 2018/8/14.
//  Copyright © 2018年 Khada Jhin. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIImageView *imageV = [self.view viewWithTag:100];
    [self loadImageWithUrl:@"https://pic3.zhimg.com/v2-0ad673672c550b117f55a999e95be35d_r.jpg" imageView:imageV];
    
}

- (void)loadImageWithUrl:(NSString *)urlStr imageView:(UIImageView *)imageView {
    NSURL *url = [NSURL URLWithString:urlStr];
    if (url == nil) {
        return;
    }
    //1.创建一个串行队列
    dispatch_queue_t queue = dispatch_queue_create("loadImage", DISPATCH_QUEUE_SERIAL);
    //2.dispatch_async 开启一个异步操作，第一个参数是指定一个gcd队列，第二个参数是分配一个处理事物的程序块到该队列。
    //dispatch_get_global_queue(0, 0) --全局队列
    //dispatch_get_main_queue() --主队列

    dispatch_async(queue, ^{
        if ([self getImageWithName:[self md5:urlStr]] != nil) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                imageView.image = [self getImageWithName:[self md5:urlStr]];
            });
        }else {
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = image;
                [self saveImage:image withName:[self md5:urlStr]];
            });
        }
    });
}


- (UIImage *)getImageWithName:(NSString *)imageName {
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    return savedImage;
}

#pragma mark 保存图片
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *UIImageJPEGRepresentation (UIImage *image, CGFloat compressionQuality);
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    [imageData writeToFile:fullPath atomically:NO];
}

#pragma mark 转换路径为有限的文件名，用于使用路径保存文件，传进去一个字符串，这个方法会生成一个32个数字组成的密文
- (NSString *) md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
