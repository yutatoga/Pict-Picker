//
//  MasterViewController.m
//  Pict Picker
//
//  Created by SystemTOGA on 6/19/12.
//  Copyright (c) 2012 Yuta Toga. All rights reserved.
//

#import "MasterViewController.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //OtO added
    // キャンバスのインスタンスを生成
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.0 green:127/255.0 blue:127/255.0 alpha:1];
    self.view.backgroundColor = [UIColor blackColor];
    canvas = [[UIImageView alloc] initWithImage:nil];
    canvas.backgroundColor= [UIColor colorWithWhite:1 alpha:0];
    canvas.frame = CGRectMake(0, 0, 320, 480-44-44-20);
    //canvas.contentMode = UIViewContentModeScaleAspectFit;//xibとそろえておく!!
    //canvas.clipsToBounds = YES;
    NSLog(@"frame:%f bounds:%f frameOX:%f frameOY:%f boundsOX:%f boundsOY:%f", self.view.frame.size.height, self.view.bounds.size.height, self.view.frame.origin.x, self.view.frame.origin.y, self.view.bounds.origin.x, self.view.bounds.origin.y);
    [self.view insertSubview:canvas aboveSubview:self.view];

    
    self.modeNum = [[NSNumber alloc] initWithInt:2];//2 is hole mode
    self.circleArray = [[NSMutableArray alloc] init];
    lineModeButton.tintColor = [UIColor blueColor];
    isKeepTouching = false;
    hideColor = [[UIColor alloc] initWithRed:1.0 green:0.5 blue:0.5 alpha:0.5];
    
    //fill
    NSLog(@"fillModeButtonTouched");
    UIGraphicsBeginImageContext(canvas.frame.size);
    CGFloat instantRed;
    CGFloat instantGreen;
    CGFloat instantBlue;
    CGFloat instantAlpha;
    // UIColor 型の color から RGBA の値を取得します。
    [hideColor getRed:&instantRed green:&instantGreen blue:&instantBlue alpha:&instantAlpha];
    CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), instantRed, instantGreen, instantBlue, instantAlpha);
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
    specialIsVirgin = true;
    //?????
    //[originalModeButton initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(touchDown:) ];

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
    if (self.modeNum.intValue == 2) {
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
    else if(self.modeNum.intValue == 2){
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
   
    
    if (self.modeNum.intValue == 2) {
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
    }
}



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
    if(fillModeButton.tintColor == [UIColor blueColor]){
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
    
    
    
    //3.arrayからholeをよみとって、描画
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
}

-(IBAction)originalModeButtonTouched{
    NSLog(@"originalModeButtonTouched");
    if(originalModeButton.tintColor == [UIColor blueColor]){
        originalModeButton.tintColor = nil;
        //back to editing view
        //1.クリア
        UIGraphicsBeginImageContext(canvas.frame.size);
        canvas.image = nil;
        UIGraphicsEndImageContext();
        //2.塗りつぶす
        if (specialModeButton.tintColor != [UIColor blueColor]) {
            UIGraphicsBeginImageContext(canvas.frame.size);
            CGFloat instantRed;
            CGFloat instantGreen;
            CGFloat instantBlue;
            CGFloat instantAlpha;
            // UIColor 型の color から RGBA の値を取得します。
            [hideColor getRed:&instantRed green:&instantGreen blue:&instantBlue alpha:&instantAlpha];
            if(fillModeButton.tintColor == [UIColor blueColor]){
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
        }else{
            canvas.image = specialImage;
        }
        //3.arrayからholeをよみとって、描画
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
            //描画
            canvas.image = UIGraphicsGetImageFromCurrentImageContext();
            // 描画領域のクリア
            UIGraphicsEndImageContext();
        }
    }else{
        originalModeButton.tintColor = [UIColor blueColor];
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
    if(fillModeButton.tintColor == [UIColor blueColor]){
        //show editing view
        fillModeButton.tintColor = nil;
        //hideColorを半透明に
        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), instantRed, instantGreen, instantBlue, instantAlpha);        
    }else{
        //show completion
        fillModeButton.tintColor = [UIColor blueColor];
        specialModeButton.tintColor = nil;
        originalModeButton.tintColor = nil;
        //hideColorをべた塗りに
        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), instantRed, instantGreen, instantBlue, 1.0);
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

    

    //3.arrayからholeをよみとって、描画
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
}

-(IBAction)cameraButtonTouched{
    //[self startCameraControllerFromViewController: self usingDelegate: self];
    UIActionSheet*  sheet;
    sheet = [[UIActionSheet alloc] 
             initWithTitle:@"Select Soruce Type" 
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
    imagePicker.allowsEditing = YES;
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
    cameraUI.allowsEditing = YES;
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
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    // 静止画像のキャプチャを処理する
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        if (editedImage) {
            imageToSave = editedImage;
            pictImageView.image = editedImage;
        } else {
            imageToSave = originalImage;
            pictImageView.image = originalImage;

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
    //use blur
    //初回だけspecialImageを生成。以後再利用
    if (specialIsVirgin) {
        specialIsVirgin = false;
        canvas.image = [pictImageView.image stackBlur:150];
        specialImage = canvas.image;
        NSLog(@"contentmodea%d", canvas.contentMode);
        canvas.clipsToBounds = YES;
        NSLog(@"contentmode%d", canvas.contentMode);
    }
    //specialモードにするか、editモードに戻るのか
    if(specialModeButton.tintColor == [UIColor blueColor]){
        //show editing view
        specialModeButton.tintColor = nil;
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
        //hideColorをべた塗りに
        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), instantRed, instantGreen, instantBlue, instantAlpha);        
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
    }else{
        //show special mode
        specialModeButton.tintColor = [UIColor blueColor];
        fillModeButton.tintColor = nil;
        originalModeButton.tintColor = nil;
        //処理されたspecialImageを描画
        canvas.image = specialImage;
    }
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
}

//
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
