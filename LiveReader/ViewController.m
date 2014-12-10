//
//  ViewController.m
//  LiveReader
//
//  Created by Dmitry Kasyanchuk on 12/10/14.
//  Copyright (c) 2014 Onix. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray* imageViews;

@property (nonatomic) BOOL initialized;

@end

@implementation ViewController

static double const imageWidth = 100;
static double const imageHeight = 100;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.imageViews = [NSMutableArray new];
    }
    return self;
}

-(void)initView {
    self.view.backgroundColor = [UIColor blueColor];
    
    NSURL* remoteURL = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/17161916/TestVideos/GOPR1166.MP4"];
//    UIImage* resultImage = [self getImageFromURL:];
    
    int imageViews = [self countOfImages];
    for (int i = 0; i < imageViews; i++) {
        UIImageView* imageView = [UIImageView new];
//        imageView.image = resultImage;
        [self addImageView:imageView];
    }
    
    [self getImageFromURL:remoteURL completion:^(CGImageRef imageResult) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage* image = [[UIImage alloc] initWithCGImage:imageResult];
            [self.imageViews enumerateObjectsUsingBlock:^(UIImageView* imageView, NSUInteger idx, BOOL *stop) {
                imageView.image = image;
            }];
        });
    }];
}

-(void)addImageView:(UIImageView*)imageView {
    [self.imageViews addObject:imageView];
    [self.view addSubview:imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGRect)imageFrameForIndex:(int)index {
    // Making a grid from images
    int imagesPerRow = ceil(self.view.frame.size.width / imageWidth);
    int imageY = floor(index / imagesPerRow);
    int imageX = index - imagesPerRow * imageY;
    return CGRectMake(imageX * imageWidth, imageY * imageHeight, imageWidth, imageHeight);
}

-(int)countOfImages {
    int imagesPerRow = ceil(self.view.frame.size.width / imageWidth);
    int imagesPerColumn = ceil(self.view.frame.size.height / imageHeight);
    return imagesPerRow * imagesPerColumn;
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (!self.initialized) {
        self.initialized = YES;
        [self initView];
    }
    
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView* imageView, NSUInteger idx, BOOL *stop) {
        imageView.frame = [self imageFrameForIndex:(int)idx];
    }];
}

-(void)getImageFromURL:(NSURL*)url completion:(void(^)(CGImageRef imageResult))completion {
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = CMTimeMake(2, 1);
    
    [imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:time]] completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        if (!error) {
            if (completion) {
                completion(image);
            }
        }
        else {
            NSLog(@"Download error: %@", error);
        }
    }];
    
//    NSError* copyError;
//    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:&copyError];
//    if (copyError) {
//        NSLog(@"Copy error: %@", copyError);
//    }
//    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
//    return thumbnail;
}

@end
