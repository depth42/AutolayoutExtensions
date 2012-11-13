//
//  ViewController.m
//  Demo-iOS
//
//  Created by Thomas Tempelmann on 13.11.12.
//  Copyright (c) 2012 Thomas Tempelmann. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
	__weak IBOutlet UILabel *theLabel;
}
@end

@implementation ViewController

- (IBAction)hideOrShowLabel:(id)sender {
	UISwitch *sw = sender;
	theLabel.hidden = !sw.isOn;
	[self.view endEditing:YES];
}

- (IBAction)endEditing:(id)sender {
	[self.view endEditing:YES];
}

@end
