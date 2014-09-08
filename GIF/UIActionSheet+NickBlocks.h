//
//  UIActionSheet+NickBlocks.h
//  GIF
//
//  Created by Nick Lee on 9/7/14.
//  Copyright (c) 2014 Nicholas Lee Designs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIAlertView-Blocks/UIActionSheet+Blocks.h>

@interface UIActionSheet (NickBlocks)

- (id)initWithTitle:(NSString *)inTitle cancelButtonItem:(RIButtonItem *)inCancelButtonItem destructiveButtonItem:(RIButtonItem *)inDestructiveItem otherButtonItem:(RIButtonItem *)inOtherItem;

@end
