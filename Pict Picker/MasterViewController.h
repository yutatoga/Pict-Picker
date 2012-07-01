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
#import "UIImage+StackBlur.h"
@interface MasterViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>{
    
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
    IBOutlet UILabel *myRadiusLabel;
    IBOutlet UILabel *myCentralLabel;
    IBOutlet UIToolbar *myToolbar;
    IBOutlet UILabel *firstGuideLabel;
    BOOL isKeepTouching;
    BOOL specialIsVirgin;
    UIImage *myImage;
    UIImage *specialImage;
    UIColor *hideColor;
}
@property (nonatomic, retain) NSNumber *modeNum;
@property (nonatomic, retain) NSNumber *touchDownPosX;
@property (nonatomic, retain) NSNumber *touchDownPosY;
@property (nonatomic, retain) NSNumber *holeRadius;
@property (nonatomic, retain) NSMutableArray *circleArray;

-(IBAction)lineModeButtonTouched;
-(IBAction)circleModeButtonTouched;
-(IBAction)undoModeButtonTouched;
-(IBAction)holeModeButtonTouched;
-(IBAction)originalModeButtonTouched;
-(IBAction)fillModeButtonTouched;
-(IBAction)specialModeButtonTouched;
-(IBAction)cameraButtonTouched;
-(IBAction)actionButtonTouched;

@end
