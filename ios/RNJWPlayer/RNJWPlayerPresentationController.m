//
//  RNJWPlayerPresentationController.m
//  RNJWPlayer
//
//  Created by Chaim Paneth on 8/18/21.
//

#import "RNJWPlayerPresentationController.h"

@implementation RNJWPlayerPresentationController

- (CGRect)frameOfPresentedViewInContainerView
{
    return _superFrame;
}

//- (void)containerViewWillLayoutSubviews
//{
//    self.presentedView.frame = self.jwSuperView.frame;
//}

//- (void)containerViewDidLayoutSubviews
//{
//    self.presentedView.frame = self.jwSuperView.frame;
//}

@end
