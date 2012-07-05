//
//  MasterViewController.m
//  Pict Picker
//
//  Created by SystemTOGA on 6/19/12.
//  Copyright (c) 2012 Yuta Toga. All rights reserved.
//

#import "MasterViewController.h"
#import "HRColorUtil.h"
@interface MasterViewController ()

@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"viewWillAppear");
    CGFloat instantHue;
    CGFloat instantSaturation;
    CGFloat instantBrightness;
    CGFloat instantAlpha;
    [pickedColor getHue:&instantHue saturation:&instantSaturation brightness:&instantBrightness alpha:&instantAlpha];
    NSLog(@"hidecolor H:%f S:%f V:%f A:%f",instantHue, instantSaturation, instantBrightness, instantAlpha);
    UIColor *instantBarColor = [UIColor colorWithHue:instantHue saturation:instantSaturation brightness:instantBrightness*0.9 alpha:instantAlpha];
    self.navigationController.navigationBar.tintColor = instantBarColor;
    
    //title design
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"Pict Picker";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    
    titleLabel.shadowColor = [UIColor colorWithHue:instantHue saturation:instantSaturation brightness:instantBrightness*0.4 alpha:instantAlpha];
    titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);

    /*
    if (instantBrightness > 0.5) {
        titleLabel.textColor = [UIColor blackColor]; // please customize
    }else{
        titleLabel.textColor = [UIColor whiteColor]; // please customize
    }
    */
    titleLabel.textColor = [UIColor whiteColor];

    self.navigationItem.titleView = titleLabel;
    [titleLabel sizeToFit];
    
    myToolbar.tintColor = instantBarColor;
    if (fillModeButton.tintColor != nil) {
        NSLog(@"changeColor by fill");
        [self buttonOnVisual:fillModeButton :pickedColor];
        //change color and fill
        //1.クリア
        [self clear];
        //2.塗りつぶす
        [self fillColor:pickedColor];
        //3.arrayからholeをよみとって、描画
        [self makeHole];
    }
    else if(specialModeButton.tintColor == nil && originalModeButton.tintColor == nil){
        NSLog(@"change color by transparent");
        //change color and transparerent
        //1.クリア
        [self clear];
        //2.塗りつぶす
        [self fillColorTransparent:pickedColor];
        //3.arrayからholeをよみとって、描画
        [self makeHole];
    }else if(originalModeButton.tintColor != nil){
        [self buttonOnVisual:originalModeButton :pickedColor];
    }else if(specialModeButton.tintColor != nil){
        [self buttonOnVisual:specialModeButton :pickedColor];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //OtO added
    NSLog(@"viewDidLoad");    
    // キャンバスのインスタンスを生成
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.0 green:127/255.0 blue:127/255.0 alpha:1];
    pickedColor = self.navigationController.navigationBar.tintColor;//only first time
    //myToolbar.tintColor = pickedColor;//set in viewWillAppear
    self.view.backgroundColor = [UIColor blackColor];//please customize
    canvas = [[UIImageView alloc] initWithImage:nil];
    canvas.backgroundColor= [UIColor colorWithWhite:1 alpha:0];
    canvas.frame = CGRectMake(0, 0, 320, 480-44-44-20);
     
    //canvas.contentMode = UIViewContentModeScaleAspectFit;//xibとそろえておく!!
    //canvas.clipsToBounds = YES;
    NSLog(@"frame:%f bounds:%f frameOX:%f frameOY:%f boundsOX:%f boundsOY:%f", self.view.frame.size.height, self.view.bounds.size.height, self.view.frame.origin.x, self.view.frame.origin.y, self.view.bounds.origin.x, self.view.bounds.origin.y);
    [self.view insertSubview:canvas aboveSubview:self.view];

    
    //self.modeNum = [[NSNumber alloc] initWithInt:2];//2 is hole mode
    self.circleArray = [[NSMutableArray alloc] init];
    lineModeButton.tintColor = [UIColor blueColor];
    isKeepTouching = false;

    //fill canvas
    //color setting
    hideColor = [[UIColor alloc] initWithRed:1.0 green:0.5 blue:0.5 alpha:0.5];
    [self fillColorTransparent:hideColor];
    specialIsVirgin = true;
    //?????
    //[originalModeButton initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(touchDown:) ];
    //boot sound
    NSString *path = [[NSBundle mainBundle] pathForResource:@"boot" ofType:@"wav"];
    //パスからNSURLを取得
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    [self playSystemSound:fileURL];
    //loading view
    loadingView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    // インジケータ作成
    myActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [myActivityIndicatorView setCenter:CGPointMake(loadingView.bounds.size.width / 2, loadingView.bounds.size.height / 2)];
    // ビューに追加
    [loadingView addSubview:myActivityIndicatorView];
    [self.navigationController.view addSubview:loadingView];
    loadingView.hidden = true;
    firstVirgin = false;
    
    
    //avplayer
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"drumrollloop" ofType:@"wav"];
    NSURL *url = [NSURL fileURLWithPath:path2];
    AVAudioPlayer *audio = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [audio play];
    
}

- (void) touchDown:(id)sender {
    NSLog(@"touchDown");
}

//OtO added
// 画面に指をタッチしたとき
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesBegan");
    if (firstGuideLabel.hidden == false) {
        firstGuideLabel.hidden = true;
    }
    myImage = canvas.image;
    // 現在のタッチ座標をローカル変数currentPointに保持
    UITouch *touch = [touches anyObject]; 
    CGPoint currentPoint = [touch locationInView:canvas];
    isKeepTouching = true;
    // タッチ開始座標をインスタンス変数touchPointに保持
    touchPoint = [touch locationInView:canvas];
    self.touchDownPosX = [[NSNumber alloc] initWithFloat:touchPoint.x];
    self.touchDownPosY = [[NSNumber alloc] initWithFloat:touchPoint.y];
    myCentralLabel.text = [NSString stringWithFormat:@"Central: X:%f Y:%f", self.touchDownPosX.floatValue, self.touchDownPosY.floatValue];
    if (originalModeButton.tintColor == nil) {
        NSLog(@"hole effect comes!");
        //hole
        // 描画領域をcanvasの大きさで生成
        UIGraphicsBeginImageContext(canvas.frame.size);
        // canvasにセットされている画像（UIImage）を描画
        [canvas.image drawInRect:
         CGRectMake(0, 0, canvas.frame.size.width, canvas.frame.size.height)];
        //ここに書く
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 1.0, 1.0, 1.0);//important
        CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake(touchPoint.x, touchPoint.y, 42, 42));
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        //
        //描画
        canvas.image = UIGraphicsGetImageFromCurrentImageContext();
        // 描画領域のクリア
        UIGraphicsEndImageContext();
        // 現在のタッチ座標を次の開始座標にセット
        touchPoint = currentPoint;
    }
}


// 画面に指がタッチされた状態で動かしているとき
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{    
    NSLog(@"touchesMoved");
    // 現在のタッチ座標をローカル変数currentPointに保持
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:canvas];
    self.holeRadius = [NSNumber numberWithFloat: sqrt(pow((currentPoint.x-self.touchDownPosX.floatValue), 2)+pow(currentPoint.y-self.touchDownPosY.floatValue, 2))];    
    myRadiusLabel.text = [NSString stringWithFormat:@"Radius: %f", sqrt(pow((currentPoint.x-self.touchDownPosX.floatValue), 2)+pow(currentPoint.y-self.touchDownPosY.floatValue, 2))];
    /*
    if (self.modeNum.intValue == 0) {
        //line
        // 描画領域をcanvasの大きさで生成
        UIGraphicsBeginImageContext(canvas.frame.size);
        // canvasにセットされている画像（UIImage）を描画
        [canvas.image drawInRect:
         CGRectMake(0, 0, canvas.frame.size.width, canvas.frame.size.height)];
        // 線の角を丸くする
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        // 線の太さを指定
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10.0);
        // 線の色を指定（RGB）
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 1.0, 0.0, 0.5);
        // 線の描画開始座標をセット
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), touchPoint.x, touchPoint.y);
        // 線の描画終了座標をセット
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        // 描画の開始～終了座標まで線を引く
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        // 描画領域を画像（UIImage）としてcanvasにセット
        canvas.image = UIGraphicsGetImageFromCurrentImageContext();
        // 描画領域のクリア
        UIGraphicsEndImageContext();
        // 現在のタッチ座標を次の開始座標にセット
        touchPoint = currentPoint;
    }
    else if(self.modeNum.intValue == 1){
        //circle
        //円を描画
        // 描画領域をcanvasの大きさで生成
        UIGraphicsBeginImageContext(canvas.frame.size);
        // canvasにセットされている画像（UIImage）を描画
        [canvas.image drawInRect:
         CGRectMake(0, 0, canvas.frame.size.width, canvas.frame.size.height)];
        //ここに書く
        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 1.0, 0.0, 0.0, 0.5);
        CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake(touchPoint.x, touchPoint.y, 42, 42));
        CGContextFillPath(UIGraphicsGetCurrentContext());
        //
        //描画
        canvas.image = UIGraphicsGetImageFromCurrentImageContext();
        // 描画領域のクリア
        UIGraphicsEndImageContext();
        // 現在のタッチ座標を次の開始座標にセット
        touchPoint = currentPoint;
    }
    */
    if(originalModeButton.tintColor == nil){
        //hole effect
        NSLog(@"hole effect comes!");
        canvas.image = myImage;
        //hole
        // 描画領域をcanvasの大きさで生成
        UIGraphicsBeginImageContext(canvas.frame.size);
        
        // canvasにセットされている画像（UIImage）を描画
        [canvas.image drawInRect:
         CGRectMake(0, 0, canvas.frame.size.width, canvas.frame.size.height)];
        //ここに書く
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 0.75);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 1.0, 1.0, 1.0);//important
        CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake(self.touchDownPosX.floatValue-self.holeRadius.floatValue, self.touchDownPosY.floatValue-self.holeRadius.floatValue, self.holeRadius.floatValue*2, self.holeRadius.floatValue*2));
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        
        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 1.0, 1.0, 1.0, 0.25);
        CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake(self.touchDownPosX.floatValue-self.holeRadius.floatValue, self.touchDownPosY.floatValue-self.holeRadius.floatValue, self.holeRadius.floatValue*2, self.holeRadius.floatValue*2));
        CGContextFillPath(UIGraphicsGetCurrentContext());
        
        
        //
        //描画
        canvas.image = UIGraphicsGetImageFromCurrentImageContext();
        // 描画領域のクリア
        UIGraphicsEndImageContext();
        // 現在のタッチ座標を次の開始座標にセット
        touchPoint = currentPoint;
    }    
    else{
    //do nothing
        NSLog(@"something wrong");
    }

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touch end");
    isKeepTouching = false;
    UITouch *touch = [touches anyObject];
    touchPoint = [touch locationInView:canvas];
    if (originalModeButton.tintColor == nil) {
        //hole mode
        NSLog(@"hole effect comes!");
        NSDictionary *myDict= [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSValue valueWithCGPoint:CGPointMake(self.touchDownPosX.floatValue, self.touchDownPosY.floatValue)], @"pos",
                           [NSNumber numberWithFloat:self.holeRadius.floatValue], @"radius",
                                   nil];
        [self.circleArray addObject:myDict];
        canvas.image = myImage;
        // 現在のタッチ座標をローカル変数currentPointに保持
        UITouch *touch = [touches anyObject]; 
        CGPoint currentPoint = [touch locationInView:canvas];
        // 描画領域をcanvasの大きさで生成
        UIGraphicsBeginImageContext(canvas.frame.size);
        // canvasにセットされている画像（UIImage）を描画
        [canvas.image drawInRect:
         CGRectMake(0, 0, canvas.frame.size.width, canvas.frame.size.height)];
        //ここに書く
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);//important
        
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);//important
        CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake(self.touchDownPosX.floatValue-self.holeRadius.floatValue,
                                                                            self.touchDownPosY.floatValue-self.holeRadius.floatValue,
                                                                            self.holeRadius.floatValue*2,
                                                                            self.holeRadius.floatValue*2));
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        
        CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake(
                                                                            self.touchDownPosX.floatValue - self.holeRadius.floatValue,
                                                                            self.touchDownPosY.floatValue-self.holeRadius.floatValue,
                                                                            self.holeRadius.floatValue*2,
                                                                            self.holeRadius.floatValue*2));
        CGContextFillPath(UIGraphicsGetCurrentContext());
        //
        //描画
        canvas.image = UIGraphicsGetImageFromCurrentImageContext();
        // 描画領域のクリア
        UIGraphicsEndImageContext();
        // 現在のタッチ座標を次の開始座標にセット
        touchPoint = currentPoint;
        
        
        //sexy sound
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Pop" ofType:@"aiff"];
        //パスからNSURLを取得
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        [self playSystemSound:fileURL];
    }
}


/*
-(IBAction)lineModeButtonTouched{
    if (self.modeNum.intValue != 0) {
        self.modeNum = [[NSNumber alloc] initWithInt:0];
        circleModeButton.tintColor = lineModeButton.tintColor;
        holeModeButton.tintColor = lineModeButton.tintColor;
        lineModeButton.tintColor = [UIColor blueColor];
    }
}
-(IBAction)circleModeButtonTouched{
    if (self.modeNum.intValue != 1) {
        self.modeNum = [[NSNumber alloc] initWithInt:1];
        lineModeButton.tintColor = circleModeButton.tintColor;
        holeModeButton.tintColor = circleModeButton.tintColor;
        circleModeButton.tintColor = [UIColor blueColor];
    }
}
-(IBAction)holeModeButtonTouched{
    if (self.modeNum.intValue != 2) {
        self.modeNum = [[NSNumber alloc] initWithInt:2];
        lineModeButton.tintColor = holeModeButton.tintColor;
        circleModeButton.tintColor = holeModeButton.tintColor;
        holeModeButton.tintColor = [UIColor blueColor];
    }
}
 */
-(IBAction)undoModeButtonTouched{
    //undo
    NSLog(@"undoModeButtonTouched");
    [self.circleArray removeLastObject];

    //1.クリア
    UIGraphicsBeginImageContext(canvas.frame.size);
    canvas.image = nil;
    UIGraphicsEndImageContext();
    //2.塗りつぶす
    UIGraphicsBeginImageContext(canvas.frame.size);
    CGFloat instantRed;
    CGFloat instantGreen;
    CGFloat instantBlue;
    CGFloat instantAlpha;
    // UIColor 型の color から RGBA の値を取得します。
    [hideColor getRed:&instantRed green:&instantGreen blue:&instantBlue alpha:&instantAlpha];
    if(fillModeButton.tintColor != nil){
        //hideColorをべた塗りに
        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), instantRed, instantGreen, instantBlue, 1.0);
    }else{
        //hideColorを半透明に
        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), instantRed, instantGreen, instantBlue, instantAlpha);
    }
    // start at origin
    CGContextMoveToPoint (UIGraphicsGetCurrentContext(), CGRectGetMinX(canvas.frame), CGRectGetMinY(canvas.frame));
    // add bottom edge
    CGContextAddLineToPoint (UIGraphicsGetCurrentContext(), CGRectGetMaxX(canvas.frame), CGRectGetMinY(canvas.frame));
    // add right edge
    CGContextAddLineToPoint (UIGraphicsGetCurrentContext(), CGRectGetMaxX(canvas.frame), CGRectGetMaxY(canvas.frame));
    // add top edge
    CGContextAddLineToPoint (UIGraphicsGetCurrentContext(), CGRectGetMinX(canvas.frame), CGRectGetMaxY(canvas.frame));
    // add left edge and close
    CGContextClosePath (UIGraphicsGetCurrentContext());
    CGContextFillPath(UIGraphicsGetCurrentContext());
    canvas.image = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    
    [self makeHole];
}

-(IBAction)originalModeButtonTouched{
    NSLog(@"originalModeButtonTouched");
    if(originalModeButton.tintColor != nil){
        //show edit view
        [self buttonOffVisual:originalModeButton :pickedColor];
        //back to editing view
        [self clear];
        [self fillColorTransparent:pickedColor];
        [self makeHole];
    }else{
        //show the original view
        [self buttonOnVisual:originalModeButton :pickedColor];
        [self buttonOffVisual:specialModeButton :pickedColor];
        [self buttonOffVisual:fillModeButton :pickedColor];
        //show original
        canvas.image = nil;
    }
}

-(IBAction)fillModeButtonTouched{
    NSLog(@"fillModeButtonTouched");
    //1.クリア
    UIGraphicsBeginImageContext(canvas.frame.size);
    canvas.image = nil;
    UIGraphicsEndImageContext();
    //2.塗りつぶす
    UIGraphicsBeginImageContext(canvas.frame.size);
    CGFloat instantRed;
    CGFloat instantGreen;
    CGFloat instantBlue;
    CGFloat instantAlpha;
    // UIColor 型の color から RGBA の値を取得します。
    [hideColor getRed:&instantRed green:&instantGreen blue:&instantBlue alpha:&instantAlpha];
    if(fillModeButton.tintColor != nil){
        //show editing view
        [self buttonOffVisual:fillModeButton :pickedColor];
        [self buttonOffVisual:originalModeButton :pickedColor];
        //hideColorを半透明に
        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), instantRed, instantGreen, instantBlue, instantAlpha);
    }else{
        //show completion
        [self buttonOnVisual:fillModeButton :pickedColor];
        [self buttonOffVisual:specialModeButton :pickedColor];
        [self buttonOffVisual:originalModeButton :pickedColor];
        //hideColorをべた塗りに
        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), instantRed, instantGreen, instantBlue, 1.0);
        //sexy sound
        /*
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ah" ofType:@"wav"];
        //パスからNSURLを取得
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        [self playSystemSound:fileURL];
        */
    }
    // start at origin
    CGContextMoveToPoint (UIGraphicsGetCurrentContext(), CGRectGetMinX(canvas.frame), CGRectGetMinY(canvas.frame));
    // add bottom edge
    CGContextAddLineToPoint (UIGraphicsGetCurrentContext(), CGRectGetMaxX(canvas.frame), CGRectGetMinY(canvas.frame));
    // add right edge
    CGContextAddLineToPoint (UIGraphicsGetCurrentContext(), CGRectGetMaxX(canvas.frame), CGRectGetMaxY(canvas.frame));
    // add top edge
    CGContextAddLineToPoint (UIGraphicsGetCurrentContext(), CGRectGetMinX(canvas.frame), CGRectGetMaxY(canvas.frame));
    // add left edge and close
    CGContextClosePath (UIGraphicsGetCurrentContext());
    CGContextFillPath(UIGraphicsGetCurrentContext());
    canvas.image = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();

    [self makeHole];
}

-(IBAction)cameraButtonTouched{
    //[self startCameraControllerFromViewController: self usingDelegate: self];
    UIActionSheet*  sheet;
    sheet = [[UIActionSheet alloc] 
             initWithTitle:@"Select Source Type" 
             delegate:self 
             cancelButtonTitle:@"Cancel" 
             destructiveButtonTitle:nil 
             otherButtonTitles:@"Photo Library", @"Camera", @"Saved Photos", nil];
    
    // アクションシートを表示する
    [sheet showInView:self.view];
    UIImagePickerControllerSourceType   sourceType = 0;
    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)actionSheet:(UIActionSheet*)actionSheet 
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // ボタンインデックスをチェックする
    if (buttonIndex >= 3) {
        return;
    }
    
    // ソースタイプを決定する
    UIImagePickerControllerSourceType   sourceType = 0;
    switch (buttonIndex) {
        case 0: {
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        }
        case 1: {
            sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        }
        case 2: {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            break;
        }
    }
    
    // 使用可能かどうかチェックする
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {  
        return;
    }
    
    // イメージピッカーを作る
    UIImagePickerController*    imagePicker;
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = sourceType;
    imagePicker.allowsEditing = NO;//please customize
    imagePicker.delegate = self;
    
    // イメージピッカーを表示する
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    // ユーザが写真またはムービーのキャプチャを選択するためのコントロールを表示する
    // （写真とムービーの両方が利用可能な場合）
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    // 写真の移動と拡大縮小、または
    // ムービーのトリミングのためのコントロールを隠す。代わりにコントロールを表示するには、YESを使用する。
    cameraUI.allowsEditing = NO;//please customize
    cameraUI.delegate = delegate;
    cameraUI.showsCameraControls = YES;
    [controller presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}
// 「キャンセル(Cancel)」をタップしたユーザへの応答.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    NSLog(@"imagePickerControllerDidCancel");
    [self dismissViewControllerAnimated:YES completion:nil];
}
// 新規にキャプチャした写真やムービーを受理したユーザへの応答
- (void) imagePickerController: (UIImagePickerController *) picker
didFinishPickingMediaWithInfo: (NSDictionary *) info {
    NSLog(@"picker done!");
    firstVirgin = true;
    [self.circleArray removeAllObjects];
    [self buttonOffVisual:specialModeButton :pickedColor];
    [self buttonOffVisual:fillModeButton :pickedColor];
    [self buttonOffVisual:originalModeButton :pickedColor];
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    UIImage *pickedPhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"pickedPhoto:%d", pickedPhoto.imageOrientation);
    // 静止画像のキャプチャを処理する
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        if (editedImage) {
            imageToSave = editedImage;
            //pictImageView.image = editedImage;//problem is here
            //update special image
            specialIsVirgin = true;
            pictImageView.image = pickedPhoto;
        } else {
            imageToSave = originalImage;
            //pictImageView.image = originalImage;//problem is here
            //update special image
            specialIsVirgin = true;
            pictImageView.image = pickedPhoto;
        }
        // （オリジナルまたは編集後の）新規画像を「カメラロール(Camera Roll)」に保存する
        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
    }
    // ムービーのキャプチャを処理する
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        NSString *moviePath = [[info objectForKey:
                                UIImagePickerControllerMediaURL] path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum (
                                                 moviePath, nil, nil, nil);
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)actionButtonTouched{
    
    //FIX ME like photo application's action. it looks iOS6 feature so check ios library.
    
    /* comment out because i want to use uiactivityviewcontroller
    NSLog(@"actionButtonTouched");
    UIActionSheet*  sheet;
    sheet = [[UIActionSheet alloc] 
             initWithTitle:@"Select Action Type" 
             delegate:self 
             cancelButtonTitle:@"Cancel"
             destructiveButtonTitle:nil 
             otherButtonTitles:@"Mail", @"Tweet", @"Facebook", nil];
    
    // アクションシートを表示する
    [sheet showInView:self.view];
    UIImagePickerControllerSourceType   sourceType = 0;
    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    */
    //https://devforums.apple.com/message/679214#679214
    NSString *hoge = [[NSString alloc] initWithString:@"Hello, world!"];
    NSMutableArray *myActivityItemsArray = [[NSMutableArray alloc] init];
    [myActivityItemsArray addObject:hoge];
    
    UIImage *capturedImage = [self imageByRenderingView];
    [myActivityItemsArray addObject:capturedImage];
    //NSArray *activities = [[NSArray alloc] initWithObjects:UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypeCopyToPasteboard, UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, nil];
    
    UIActivityViewController *sharing = [[UIActivityViewController alloc] initWithActivityItems:myActivityItemsArray applicationActivities:nil];
    
    //sharing.excludedActivityTypes = @[
    /*
     UIActivityTypePostToFacebook,
     UIActivityTypePostToTwitter,
     UIActivityTypePostToWeibo,
     UIActivityTypeMessage,
     UIActivityTypeMail,
     UIActivityTypePrint,
     UIActivityTypeCopyToPasteboard,
     UIActivityTypeAssignToContact,
    
    */
    //];
    [self presentViewController:sharing animated:YES completion:nil];
}

//capture function
- (UIImage *)imageByRenderingView
{
    //UIGraphicsBeginImageContext(self.view.bounds.size);
    UIGraphicsBeginImageContext(CGRectMake(0, 0, 320, 480-44-44-20).size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}
/*
-(IBAction)specialButtonTouched{
 //iosのフィルターを使用した場合
    NSLog(@"CIGaussianBlur");
    //for filter
    CIImage *myCIImage = [[CIImage alloc] initWithImage:pictImageView.image];
    // CIFilterを作成し、ソース画像とエフェクトのパラメータをセットする
    //useful filter in iOS
    //1-CIGaussianBlur
    //2-CIPixellate    
    CIFilter *myCIFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    
    
    
    
    //[myCIFilter setValue:[CIVector vectorWithCGPoint:CGPointMake(150, 150)] forKey:@"inputCenter"];
    //[myCIFilter setValue:[NSNumber numberWithFloat:30.0] forKey:@"inputRadius"];
    //[myCIFilter setValue:[NSNumber numberWithFloat:0.50] forKey:@"inputScale"];
    [myCIFilter setDefaults];
    [myCIFilter setValue:myCIImage forKey:@"inputImage"];
    [myCIFilter setValue:[NSNumber numberWithFloat:10] forKey:@"inputRadius"];
    // 結果を取り出す
    myCIImage = myCIFilter.outputImage;
    // CIImageをUIImageに変換する
    CIContext *myCIContext = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [myCIContext createCGImage:myCIImage fromRect:[myCIImage extent]];
    UIImage *filteredImage  = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:UIImageOrientationUp];
    NSLog(@"%f %f", filteredImage.size.width, filteredImage.size.height);
    
    // 表示
    [canvas setImage:filteredImage];
    NSLog(@"\ncanvas.image.size w:%f h%f\n canvas.image.frame.origin x:%f y:%f\ncanvas.frame.size w%f h%f", canvas.image.size.width, canvas.image.size.height, canvas.frame.origin.x, canvas.frame.origin.y, canvas.frame.size.width, canvas.frame.size.height);
    //canvas.contentMode = UIViewContentModeScaleAspectFill;//xibとそろえておく!!
	//canvas.clipsToBounds = YES;
    NSLog(@"\n\ncanvas.image.size w:%f h%f\n canvas.image.frame.origin x:%f y:%f\ncanvas.frame.size w%f h%f", canvas.image.size.width, canvas.image.size.height, canvas.frame.origin.x, canvas.frame.origin.y, canvas.frame.size.width, canvas.frame.size.height);
    
    
    //add hole effect
    //arrayからholeをよみとって、描画
    for (int i=0; i<self.circleArray.count; i++) {
        NSLog(@"for %d", i);
        //hole
        // 描画領域をcanvasの大きさで生成
        UIGraphicsBeginImageContext(canvas.frame.size);
        // canvasにセットされている画像（UIImage）を描画
        [canvas.image drawInRect:
         CGRectMake(0, 0, canvas.frame.size.width, canvas.frame.size.height)];
        //ここに書く
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);//important
        
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);//important
        CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake([[[self.circleArray objectAtIndex:i] objectForKey:@"pos"] CGPointValue].x - [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue],
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"pos"] CGPointValue].y - [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue],
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue] * 2,
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue] * 2));
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        
        CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake([[[self.circleArray objectAtIndex:i] objectForKey:@"pos"] CGPointValue].x - [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue],
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"pos"] CGPointValue].y - [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue],
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue] * 2,
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue] * 2));
        CGContextFillPath(UIGraphicsGetCurrentContext());
        //
        //描画
        canvas.image = UIGraphicsGetImageFromCurrentImageContext();
        // 描画領域のクリア
        UIGraphicsEndImageContext();
    }
    //iOSの全フィルターを書き出す。
    NSArray *filterNames;
    filterNames = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    NSLog(@"%@", filterNames.description);
    //[self grayscale:canvas.image];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(canvas.image.CGImage);
    NSLog(@"%u", bitmapInfo);
}
*/
/*
-(IBAction)specialButtonTouched{
 //ピクセルにアクセスする。例１
    // pixel値の抽出
    UIImage *img = pictImageView.image;
    CGImageRef cgImage = [img CGImage];
    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
    CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    UInt8* pixels = (UInt8*)CFDataGetBytePtr(data);
    // 画像処理（グレースケール化）
    for (int y = 0 ; y < img.size.height; y++){
        for (int x = 0; x < img.size.width; x++){
            UInt8* buf = pixels + y * bytesPerRow + x * 4;
            UInt8 r, g, b;
            r = *(buf + 0);
            g = *(buf + 1);
            b = *(buf + 2);
            //ここでrgbが出そろったので、好きなようにピクセルデータをいじる
            UInt8 gray = (77 * r + 28 * g + 151 * b)>>8;
            *(buf + 0) = gray;
            *(buf + 1) = gray;
            *(buf + 2) = gray;
        }
    }
    // pixel値からUIImageの再合成
    CFDataRef resultData = CFDataCreate(NULL, pixels, CFDataGetLength(data));
    CGDataProviderRef resultDataProvider = CGDataProviderCreateWithCFData(resultData);
    CGImageRef resultCgImage = CGImageCreate(
                                             CGImageGetWidth(cgImage), CGImageGetHeight(cgImage),
                                             CGImageGetBitsPerComponent(cgImage), CGImageGetBitsPerPixel(cgImage), bytesPerRow,
                                             CGImageGetColorSpace(cgImage), CGImageGetBitmapInfo(cgImage), resultDataProvider,
                                             NULL, CGImageGetShouldInterpolate(cgImage), CGImageGetRenderingIntent(cgImage));
    UIImage* result = [[UIImage alloc] initWithCGImage:resultCgImage];
    
    // 後処理
    CGImageRelease(resultCgImage);
    CFRelease(resultDataProvider);
    CFRelease(resultData);
    CFRelease(data);
    
    canvas.image = result;
}
*/
/*
-(IBAction)specialButtonTouched{
 //ずらして描画作戦
    int shift = 5;
    UIImage* img1 = pictImageView.image;
    UIImage* img2 = pictImageView.image;
    CGRect rect;
    for (int i=0; i<8; i++) {
        UIGraphicsBeginImageContext(pictImageView.frame.size);
        switch (i) {
            case 0:
                rect.origin = CGPointMake(shift, shift);
                break;
            case 1:
                rect.origin = CGPointMake(-shift, shift);
                break;
            case 2:
                rect.origin = CGPointMake(shift, -shift);
                break;
            case 3:
                rect.origin = CGPointMake(-shift, -shift);
                break;
            case 4:
                rect.origin = CGPointMake(shift, 0);
                break;
            case 5:
                rect.origin = CGPointMake(0, shift);
                break;
            case 6:
                rect.origin = CGPointMake(0, -shift);
                break;
            case 7:
                rect.origin = CGPointMake(-shift, 0);
                break;
            default:
                break;
        }

        rect.size = canvas.frame.size;
        //透明度を指定して重ね合わせる
        [img1 drawInRect:rect blendMode:kCGBlendModeNormal alpha:0.5];
        UIImage* shrinkedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        canvas.image = shrinkedImage;
    }
    //keep current image
    img1 = canvas.image;
    //fill white
    UIGraphicsBeginImageContext(canvas.frame.size);
    CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 1, 1, 1, 0.5);
    // start at origin
    CGContextMoveToPoint (UIGraphicsGetCurrentContext(), CGRectGetMinX(canvas.frame), CGRectGetMinY(canvas.frame));
    // add bottom edge
    CGContextAddLineToPoint (UIGraphicsGetCurrentContext(), CGRectGetMaxX(canvas.frame), CGRectGetMinY(canvas.frame));
    // add right edge
    CGContextAddLineToPoint (UIGraphicsGetCurrentContext(), CGRectGetMaxX(canvas.frame), CGRectGetMaxY(canvas.frame));
    // add top edge
    CGContextAddLineToPoint (UIGraphicsGetCurrentContext(), CGRectGetMinX(canvas.frame), CGRectGetMaxY(canvas.frame));
    // add left edge and close
    CGContextClosePath (UIGraphicsGetCurrentContext());
    CGContextFillPath(UIGraphicsGetCurrentContext());
    img2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(pictImageView.frame.size);
    
    rect.origin = CGPointMake(0, 0);
    rect.size = canvas.frame.size;
    //透明度を指定して重ね合わせる
    [img1 drawInRect:rect blendMode:kCGBlendModeNormal alpha:1];
    [img2 drawInRect:rect blendMode:kCGBlendModeNormal alpha:0.9];
    UIImage* shrinkedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    canvas.image = shrinkedImage;
}
*/
/*
-(IBAction)specialButtonTouched{
    //ランダム関数をつかってばらけさす作戦
    // pixel値の抽出
    UIImage *img = pictImageView.image;
    CGImageRef cgImage = [img CGImage];
    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
    CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    UInt8* pixels = (UInt8*)CFDataGetBytePtr(data);
    // 画像処理（グレースケール化）
    UInt8 randShiftX, randShiftY;
    for (int y = 0 ; y < img.size.height; y++){
        for (int x = 0; x < img.size.width; x++){
            UInt8* buf = pixels + y * bytesPerRow + x * 4;
            UInt8 r, g, b;
            r = *(buf + 0);
            g = *(buf + 1);
            b = *(buf + 2);
            //ここでrgbが出そろったので、好きなようにピクセルデータをいじる
            randShiftX = arc4random() % 10;
            randShiftY = arc4random() % 10;
            if (randShiftX+x < img.size.width && randShiftY+y < img.size.height) {
                UInt8* bufShift = pixels + (y+randShiftY) * bytesPerRow + (x+randShiftX) * 4;
                *(bufShift + 0) = r;
                *(bufShift + 1) = g;
                *(bufShift + 2) = b;
            }
        }
    }
    // pixel値からUIImageの再合成
    CFDataRef resultData = CFDataCreate(NULL, pixels, CFDataGetLength(data));
    CGDataProviderRef resultDataProvider = CGDataProviderCreateWithCFData(resultData);
    CGImageRef resultCgImage = CGImageCreate(
                                             CGImageGetWidth(cgImage), CGImageGetHeight(cgImage),
                                             CGImageGetBitsPerComponent(cgImage), CGImageGetBitsPerPixel(cgImage), bytesPerRow,
                                             CGImageGetColorSpace(cgImage), CGImageGetBitmapInfo(cgImage), resultDataProvider,
                                             NULL, CGImageGetShouldInterpolate(cgImage), CGImageGetRenderingIntent(cgImage));
    UIImage* result = [[UIImage alloc] initWithCGImage:resultCgImage];
    
    // 後処理
    CGImageRelease(resultCgImage);
    CFRelease(resultDataProvider);
    CFRelease(resultData);
    CFRelease(data);
    
    canvas.image = result;
}
*/
-(IBAction)specialModeButtonTouched{
    NSLog(@"specialModeButtonTouched");
    //use blur
    //初回だけspecialImageを生成。以後再利用
    if (specialIsVirgin) {
        //show loadng indicator
        loadingView.hidden = false;
        
        //play drum roll
        //I need change syste sound to avfoundation
        [player play];
        player.numberOfLoops = -1;//infinity loop
        [myActivityIndicatorView startAnimating];
        //別スレッドで処理
        //do blur
        [self performSelectorInBackground:@selector(doInBackground) withObject:nil];
        specialIsVirgin = false;
    }else{
        if(specialModeButton.tintColor != nil){
            //show editing view
            [self buttonOffVisual:specialModeButton :pickedColor];
            //1.クリア
            [self clear];
            //2.塗りつぶす
            [self fillColorTransparent:pickedColor];
        }else{
            //special view(show blur)
            canvas.image = specialImage;
            canvas.clipsToBounds = YES;
            //button color
            [self buttonOnVisual:specialModeButton :pickedColor];
            [self buttonOffVisual:fillModeButton :pickedColor];
            [self buttonOffVisual:originalModeButton :pickedColor];
        }
    }
    [self makeHole];
    
}
- (void)doInBackground {
    // なにか重い処理を実行
    canvas.image = [pictImageView.image stackBlur:150];//maybe 150 is best
    specialImage = [self rotateImage:canvas.image imageOrientation:pictImageView.image.imageOrientation];
    //button color
    [self buttonOnVisual:specialModeButton :pickedColor];
    [self buttonOffVisual:fillModeButton :pickedColor];
    [self buttonOffVisual:originalModeButton :pickedColor];
    //special view
    if (firstVirgin) {
        NSLog(@"imageOrientation: %d", pictImageView.image.imageOrientation);
        canvas.image = specialImage;
        firstVirgin = true;
    }
    canvas.clipsToBounds = YES;
    //完了！
    [myActivityIndicatorView stopAnimating];
    loadingView.hidden = true;
    //sexy sound
    [player stop];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"terettere" ofType:@"wav"];
    //パスからNSURLを取得
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    [self PlayAlertSound:fileURL];
    [self makeHole];
}

-(void)clear{
    UIGraphicsBeginImageContext(canvas.frame.size);
    canvas.image = nil;
    UIGraphicsEndImageContext();
}

- (void)fillColor:(UIColor*)color{
    //fill canvas
    //color setting
    CGFloat instantRed;
    CGFloat instantGreen;
    CGFloat instantBlue;
    CGFloat instantAlpha;
    // UIColor 型の color から RGBA の値を取得します。
    [color getRed:&instantRed green:&instantGreen blue:&instantBlue alpha:&instantAlpha];
    //fill by fill color
    UIGraphicsBeginImageContext(canvas.frame.size);
    CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), instantRed, instantGreen, instantBlue, 1.0);//please customize
    // start at origin
    CGContextMoveToPoint (UIGraphicsGetCurrentContext(), CGRectGetMinX(canvas.frame), CGRectGetMinY(canvas.frame));
    // add bottom edge
    CGContextAddLineToPoint (UIGraphicsGetCurrentContext(), CGRectGetMaxX(canvas.frame), CGRectGetMinY(canvas.frame));
    // add right edge
    CGContextAddLineToPoint (UIGraphicsGetCurrentContext(), CGRectGetMaxX(canvas.frame), CGRectGetMaxY(canvas.frame));
    // add top edge
    CGContextAddLineToPoint (UIGraphicsGetCurrentContext(), CGRectGetMinX(canvas.frame), CGRectGetMaxY(canvas.frame));
    // add left edge and close
    CGContextClosePath (UIGraphicsGetCurrentContext());
    CGContextFillPath(UIGraphicsGetCurrentContext());
    canvas.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)fillColorTransparent:(UIColor*)color{
    //fill canvas
    //color setting
    CGFloat instantRed;
    CGFloat instantGreen;
    CGFloat instantBlue;
    CGFloat instantAlpha;
    // UIColor 型の color から RGBA の値を取得します。
    [color getRed:&instantRed green:&instantGreen blue:&instantBlue alpha:&instantAlpha];
    //fill by fill color
    UIGraphicsBeginImageContext(canvas.frame.size);
    CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), instantRed, instantGreen, instantBlue, 0.5);//please customize
    // start at origin
    CGContextMoveToPoint (UIGraphicsGetCurrentContext(), CGRectGetMinX(canvas.frame), CGRectGetMinY(canvas.frame));
    // add bottom edge
    CGContextAddLineToPoint (UIGraphicsGetCurrentContext(), CGRectGetMaxX(canvas.frame), CGRectGetMinY(canvas.frame));
    // add right edge
    CGContextAddLineToPoint (UIGraphicsGetCurrentContext(), CGRectGetMaxX(canvas.frame), CGRectGetMaxY(canvas.frame));
    // add top edge
    CGContextAddLineToPoint (UIGraphicsGetCurrentContext(), CGRectGetMinX(canvas.frame), CGRectGetMaxY(canvas.frame));
    // add left edge and close
    CGContextClosePath (UIGraphicsGetCurrentContext());
    CGContextFillPath(UIGraphicsGetCurrentContext());
    canvas.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}



- (void)makeHole{
    for (int i=0; i<self.circleArray.count; i++) {
        NSLog(@"holes for %d", i);
        //hole
        // 描画領域をcanvasの大きさで生成
        UIGraphicsBeginImageContext(canvas.frame.size);
        // canvasにセットされている画像（UIImage）を描画
        [canvas.image drawInRect:
         CGRectMake(0, 0, canvas.frame.size.width, canvas.frame.size.height)];
        //ここに書く
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);//important
        
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);//important
        CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake([[[self.circleArray objectAtIndex:i] objectForKey:@"pos"] CGPointValue].x - [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue],
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"pos"] CGPointValue].y - [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue],
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue] * 2,
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue] * 2));
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        
        CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake([[[self.circleArray objectAtIndex:i] objectForKey:@"pos"] CGPointValue].x - [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue],
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"pos"] CGPointValue].y - [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue],
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue] * 2,
                                                                            [[[self.circleArray objectAtIndex:i] objectForKey:@"radius"] floatValue] * 2));
        CGContextFillPath(UIGraphicsGetCurrentContext());
        //
        //描画
        canvas.image = UIGraphicsGetImageFromCurrentImageContext();
        // 描画領域のクリア
        UIGraphicsEndImageContext();
        
    }
}

//color picket
- (void)openColorPicker{
    HRColorPickerViewController* controller;
    controller = [HRColorPickerViewController fullColorPickerViewControllerWithColor:[self.view backgroundColor]];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}
- (void)setSelectedColor:(UIColor*)color{
    [self.view setBackgroundColor:color];
    CGFloat instantRed;
    CGFloat instantGreen;
    CGFloat instantBlue;
    CGFloat instantAlpha;
    // UIColor 型の color から RGBA の値を取得します。
    [color getRed:&instantRed green:&instantGreen blue:&instantBlue alpha:&instantAlpha];
    hideColor = [UIColor colorWithRed:instantRed green:instantGreen blue:instantBlue alpha:0.5];
    pickedColor = color;
    NSLog(@"color change!");
    [hexColorLabel setText:[NSString stringWithFormat:@"#%06x",HexColorFromUIColor(color)]];
}

-(IBAction)colorChangeButtonTouched{
    [self setSelectedColor:pickedColor];
    [self openColorPicker];
    
}

-(void)buttonOnVisual:(UIBarButtonItem*) buttonitem :(UIColor*)color{
    //change uibarbuttonitem design for "ON"
    //show special mode
    CGFloat instantHue;
    CGFloat instantSaturation;
    CGFloat instantBrightness;
    CGFloat instantAlpha;
    [color getHue:&instantHue saturation:&instantSaturation brightness:&instantBrightness alpha:&instantAlpha];
    buttonitem.tintColor = [UIColor colorWithHue:instantHue saturation:instantSaturation*0.1 brightness:1.0 alpha:instantAlpha];
    [buttonitem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont boldSystemFontOfSize:0.0], UITextAttributeFont,
                                        hideColor, UITextAttributeTextColor,
                                        [UIColor colorWithHue:instantHue saturation:instantSaturation brightness:instantBrightness*0.5 alpha:0.7], UITextAttributeTextShadowColor,
                                        CGSizeMake(0.0f, -1.0f), UITextAttributeTextShadowOffset,
                                        nil] forState:UIControlStateNormal];
}

-(void)buttonOffVisual:(UIBarButtonItem*) buttonitem :(UIColor*)color{
    //change uibarbuttonitem design for "OFF"
    //show special mode
    buttonitem.tintColor = nil;
    [buttonitem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        
                                        [UIColor grayColor], UITextAttributeTextShadowColor,
                                        [UIColor whiteColor], UITextAttributeTextColor,
                                        CGSizeMake(0.0f, -1.0f), UITextAttributeTextShadowOffset,
                                        nil] forState:UIControlStateNormal];
}
//sound
-(void)playSystemSound:(NSURL *)fileURL{
    SystemSoundID mySystemSoundID;
    //[3] SystemSoundIDを作成する
    OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef) fileURL, &mySystemSoundID);
    //[4]エラーがあった場合はreturnで中止
    if(err){
        NSLog(@"AudioServicesCreateSystemSoundID err = %li",err);
        return;
    }
    AudioServicesPlaySystemSound(mySystemSoundID);//just sound
    //AudioServicesPlayAlertSound(mySystemSoundID);//sound + vibration
}

-(void)PlayAlertSound:(NSURL *)fileURL{
    SystemSoundID mySystemSoundID;
    //[3] SystemSoundIDを作成する
    OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef) fileURL, &mySystemSoundID);
    //[4]エラーがあった場合はreturnで中止
    if(err){
        NSLog(@"AudioServicesCreateSystemSoundID err = %li",err);
        return;
    }
    //AudioServicesPlaySystemSound(mySystemSoundID);//just sound
    AudioServicesPlayAlertSound(mySystemSoundID);//sound + vibration
}

- (UIImage*)rotateImage:(UIImage*)img imageOrientation:(int)angleID
{
    CGImageRef img_ref = [img CGImage];
    CGContextRef context;
    UIImage *rotate_image;
    switch (angleID) {
        case 0:
            rotate_image = img;
            return rotate_image;
            break;
        case 2:
            UIGraphicsBeginImageContext(CGSizeMake(img.size.height, img.size.width));
            context = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(context, img.size.height, img.size.width);
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextRotateCTM(context, M_PI/2.0);
            break;
        case 1:
            UIGraphicsBeginImageContext(CGSizeMake(img.size.width, img.size.height));
            context = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(context, img.size.width, 0);
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextRotateCTM(context, -M_PI);
            break;
        case 3:
            UIGraphicsBeginImageContext(CGSizeMake(img.size.height, img.size.width));
            context = UIGraphicsGetCurrentContext();
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextRotateCTM(context, -M_PI/2.0);
            break;
        default:
            return nil;
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, img.size.width, img.size.height), img_ref);
    rotate_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return rotate_image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"shouldAutorotateToInterfaceOrientation");
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    //OtO
    if(interfaceOrientation == UIInterfaceOrientationPortrait){
        // 通常
        return YES;
    }else if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
        // 左に倒した状態
        NSLog(@"left");
        return NO;
    }else if(interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        // 右に倒した状態
        return NO;
    }else if(interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        // 逆さまの状態
        return NO;
    }
    NSLog(@"shouldAutorotateToInterfaceOrientation: something wrong");
    return NO;
}

@end
