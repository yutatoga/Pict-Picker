//
//  MasterViewController.h
//  Pict Picker
//
//  Created by SystemTOGA on 6/19/12.
//  Copyright (c) 2012 Yuta Toga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AudioToolbox/AudioToolbox.h>
#import "UIImage+StackBlur.h"
#import "HRColorPickerViewController.h"
#import "UIImage+fixOrientation.h"
#import <AVFoundation/AVFoundation.h>
@interface MasterViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, HRColorPickerViewControllerDelegate>{
    
    //OtO added
    UIImageView *canvas;
    CGPoint touchPoint;
    IBOutlet UIImageView *pictImageView;
    IBOutlet UIBarButtonItem *lineModeButton;
    IBOutlet UIBarButtonItem *circleModeButton;
    IBOutlet UIBarButtonItem *undoModeButton;
    IBOutlet UIBarButtonItem *holeModeButton;
    IBOutlet UIBarButtonItem *originalModeButton;
    IBOutlet UIBarButtonItem *fillModeButton;
    IBOutlet UIBarButtonItem *specialModeButton;
    IBOutlet UIBarButtonItem *colorChangeButton;
    IBOutlet UILabel *myRadiusLabel;
    IBOutlet UILabel *myCentralLabel;
    IBOutlet UIToolbar *myToolbar;
    IBOutlet UILabel *firstGuideLabel;
    BOOL isKeepTouching;
    BOOL specialIsVirgin;
    UIImage *myImage;
    UIImage *specialImage;
    UIColor *hideColor;
    UIColor *pickedColor;
    UILabel* hexColorLabel;
    //loading
    UIView *loadingView;
    UIActivityIndicatorView * myActivityIndicatorView;
    BOOL firstVirgin;
    //player
    AVAudioPlayer *player;
}
@property (nonatomic, retain) NSNumber *modeNum;
@property (nonatomic, retain) NSNumber *touchDownPosX;
@property (nonatomic, retain) NSNumber *touchDownPosY;
@property (nonatomic, retain) NSNumber *holeRadius;
@property (nonatomic, retain) NSMutableArray *circleArray;

/*
-(IBAction)lineModeButtonTouched;
-(IBAction)circleModeButtonTouched;
-(IBAction)holeModeButtonTouched;
*/
-(IBAction)undoModeButtonTouched;
-(IBAction)originalModeButtonTouched;
-(IBAction)fillModeButtonTouched;
-(IBAction)specialModeButtonTouched;
-(IBAction)cameraButtonTouched;
-(IBAction)actionButtonTouched;
-(IBAction)colorChangeButtonTouched;

@end
