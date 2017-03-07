//
//  AppDelegate.mm
//  CaffeApp
//
//  Created by Yuma Endo on 2017/03/07.
//  Copyright © 2017 ideeinc. All rights reserved.
//

#import "AppDelegate.h"
#import <caffe/caffe.hpp>

/**
 */
@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@end

/**
 */
@implementation AppDelegate

/**
 */
- (void) applicationDidFinishLaunching: (NSNotification*)notification
{
	caffe::Caffe::set_mode(caffe::Caffe::CPU);
	caffe::Caffe::set_multiprocess(true);
}

@end
