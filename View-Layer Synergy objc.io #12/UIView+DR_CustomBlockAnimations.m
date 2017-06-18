//
//  UIView+DR_CustomBlockAnimations.m
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

#import "UIView+DR_CustomBlockAnimations.h"
#import "DRSavedPopAnimationState.h"
#import <objc/runtime.h>

// This is an example of a custom block based animation API, as explained in
// my article "View-Layer Synergy" for objc.io issue 12:
// https://www.objc.io/issues/12-animations/view-layer-synergy/

@implementation UIView (DR_CustomBlockAnimations)

#pragma mark - State

static void *DR_currentAnimationContext = NULL;
static void *DR_popAnimationContext     = &DR_popAnimationContext;

static NSMutableArray<DRSavedPopAnimationState *> *DR_savedPopAnimationStates = nil;

+ (NSMutableArray<DRSavedPopAnimationState *> *)DR_savedPopAnimationStates
{
    if (!DR_savedPopAnimationStates) {
        DR_savedPopAnimationStates = [[NSMutableArray alloc] init];
    }
    return DR_savedPopAnimationStates;
}

#pragma mark - Swizzling

+ (void)load
{
    SEL originalSelector = @selector(actionForLayer:forKey:);
    SEL extendedSelector = @selector(DR_actionForLayer:forKey:);

    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method extendedMethod = class_getInstanceMethod(self, extendedSelector);

    NSAssert(originalMethod, @"original method should exist");
    NSAssert(extendedMethod, @"exchanged method should exist");

    if(class_addMethod(self, originalSelector, method_getImplementation(extendedMethod), method_getTypeEncoding(extendedMethod))) {
        class_replaceMethod(self, extendedSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, extendedMethod);
    }
}

- (id<CAAction>)DR_actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
    if (DR_currentAnimationContext == DR_popAnimationContext) {
        [[UIView DR_savedPopAnimationStates] addObject:[DRSavedPopAnimationState savedStateWithLayer:layer
                                                                                             keyPath:event]];

        // no implicit animation (it will be added later)
        return (id<CAAction>)[NSNull null];
    }

    // call the original implementation
    return [self DR_actionForLayer:layer forKey:event]; // yes, they are swizzled
}

#pragma mark - Pop Animation

+ (void)DR_popAnimationWithDuration:(NSTimeInterval)duration
                         animations:(void (^)(void))animations
{
    DR_currentAnimationContext = DR_popAnimationContext;

    // do the animation (which will trigger callbacks to the swizzled delegate method)
    animations();

    [[self DR_savedPopAnimationStates] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DRSavedPopAnimationState *savedState   = (DRSavedPopAnimationState *)obj;
        CALayer *layer    = savedState.layer;
        NSString *keyPath = savedState.keyPath;
        id oldValue       = savedState.oldValue;
        id newValue       = [layer valueForKeyPath:keyPath];

        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:keyPath];

        CGFloat easing = 0.2;
        CAMediaTimingFunction *easeIn  = [CAMediaTimingFunction functionWithControlPoints:1.0 :0.0 :(1.0-easing) :1.0];
        CAMediaTimingFunction *easeOut = [CAMediaTimingFunction functionWithControlPoints:easing :0.0 :0.0 :1.0];

        anim.duration = duration;
        anim.keyTimes = @[@0, @(0.35), @1];
        anim.values = @[oldValue, newValue, oldValue];
        anim.timingFunctions = @[easeIn, easeOut];

        // back to old value without an animation
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [layer setValue:oldValue forKeyPath:keyPath];
        [CATransaction commit];

        // animate the "pop"
        [layer addAnimation:anim forKey:keyPath];

    }];

    // clean up (remove all the stored state)
    [[self DR_savedPopAnimationStates] removeAllObjects];

    DR_currentAnimationContext = nil;
}

@end
