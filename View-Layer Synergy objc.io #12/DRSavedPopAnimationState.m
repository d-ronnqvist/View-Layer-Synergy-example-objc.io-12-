//
//  DRSavedPopAnimationState.m
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

#import "DRSavedPopAnimationState.h"

// This is an example of a custom block based animation API, as explained in
// my article "View-Layer Synergy" for objc.io issue 12:
// https://www.objc.io/issues/12-animations/view-layer-synergy/

@implementation DRSavedPopAnimationState

+ (instancetype)savedStateWithLayer:(CALayer *)layer
                            keyPath:(NSString *)keyPath
{
    DRSavedPopAnimationState *savedState = [DRSavedPopAnimationState new];
    savedState.layer    = layer;
    savedState.keyPath  = keyPath;
    savedState.oldValue = [layer valueForKeyPath:keyPath];
    return savedState;
}

@end
