//
//  MainVC.m
//  Selfie App
//
//  Created by vikas chawla on 14/07/14.
//  Copyright (c) 2014 mobilemerit. All rights reserved.
//

#import "MainVC.h"

@interface MainVC ()

@end

@implementation MainVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.library = [[ALAssetsLibrary alloc] init];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && cameraLoaded == NO)
    {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagePickerController.showsCameraControls = NO;
        _imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        _imagePickerController.delegate = self;
        
        [[NSBundle mainBundle] loadNibNamed:@"cameraoverlay" owner:self options:nil];
        UIImage *sliderThumb = [UIImage imageNamed:@"button-capture"];
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)];
        [_slider addGestureRecognizer:gr];
        _imagePickerController.cameraViewTransform = CGAffineTransformMakeScale(_slider.value, _slider.value);

        
        [_slider setThumbImage:sliderThumb forState:UIControlStateNormal];
        [_slider setThumbImage:sliderThumb forState:UIControlStateHighlighted];
        
        [_imagePickerController.view addSubview:_cameraOverlay];
        [self presentViewController:_imagePickerController animated:YES completion:nil];
        cameraLoaded = YES;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    int kMaxResolution = 320;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        // Retina display
        kMaxResolution = 640;
    }
    _image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    CGImageRef imgRef = _image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    float scaleRatio = _slider.value;
    
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGFloat boundHeight;
    UIImageOrientation orient = _image.imageOrientation;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    
    UIGraphicsBeginImageContext(bounds.size);
     CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -(height - height/scaleRatio)/2, -(width - width/scaleRatio)/2);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    _image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    CGImageRelease(imageRef);

    
    [_imageView setImage:_image];
}

# pragma mark custom actions
-(void)sliderTapped:(UIGestureRecognizer *)gr {
    [_imagePickerController takePicture];
    [self dismissViewControllerAnimated:YES completion:NULL];
    _viewImageWrapper.hidden = NO;
}
- (IBAction)retakePicture:(id)sender {
    [self presentViewController:_imagePickerController animated:YES completion:nil];
}
- (IBAction)savePicture:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving";
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [_library saveImage:_image toAlbum:@"Selfie App" withCompletionBlock:^(NSError *error) {
            if (error!=nil) {
                NSLog(@"Big error: %@", [error description]);
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.labelText = @"Image Saved";
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}
- (IBAction)sliderChanged:(UISlider *)sender {
    _imagePickerController.cameraViewTransform = CGAffineTransformMakeScale((CGFloat)sender.value, (CGFloat)sender.value);
}

- (IBAction)share:(id)sender {
    NSString *shareText = @"My Selfie using #Selfie-App";
    //NSLog(currentURL.URL.absoluteString);
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareText, _image] applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}
@end
