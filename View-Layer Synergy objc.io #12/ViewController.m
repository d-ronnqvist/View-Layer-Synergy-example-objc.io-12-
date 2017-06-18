//
//  ViewController.m
//  View-Layer Synergy objc.io #12
//
//  Created by David Rönnqvist on 2017-06-18.
//  Copyright © 2017 David Rönnqvist
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "ViewController.h"
#import "UIView+DR_CustomBlockAnimations.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIView *movingView;
@property (strong, nonatomic) IBOutlet UIView *scalingView;
@property (strong, nonatomic) IBOutlet UIView *rotatingView;
@property (strong, nonatomic) IBOutlet UIView *colorChangingView;

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(performCustomAnimation:)
                                   userInfo:nil
                                    repeats:YES];
}

// This is not animating _with_ a timer, but rather using a timer to repeatedly
// trigger an animation using a custom block based animation API.
- (void)performCustomAnimation:(NSTimer *)timer
{
    UIColor *customOrange =  [UIColor colorWithRed:1 green:0.73 blue:0 alpha:1];

    [UIView DR_popAnimationWithDuration:0.7
                             animations:^{
                                 self.movingView.frame = CGRectOffset(self.movingView.frame, 0.0, -45.0);
                                 self.scalingView.transform  = CGAffineTransformMakeScale(1.4, 1.4);
                                 self.rotatingView.transform = CGAffineTransformMakeRotation(M_PI_2);
                                 self.colorChangingView.backgroundColor = customOrange;
                             }];
}

@end
