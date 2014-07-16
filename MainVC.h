//
//  MainVC.h
//  Selfie App
//
//  Created by vikas chawla on 14/07/14.
//  Copyright (c) 2014 mobilemerit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface MainVC : UIViewController <UIImagePickerControllerDelegate> {
    BOOL cameraLoaded;
}

@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@property (strong, nonatomic) IBOutlet UIView *cameraOverlay;
@property (strong, nonatomic) IBOutlet UIView *viewImageWrapper;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)retakePicture:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *imageContainer;
@property (strong, nonatomic) UIImage *image;
- (IBAction)savePicture:(id)sender;
@property (strong, atomic) ALAssetsLibrary* library;

@property (strong, nonatomic) IBOutlet UISlider *slider;
- (IBAction)sliderChanged:(UISlider *)sender;
- (IBAction)share:(id)sender;

@end
