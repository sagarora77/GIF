//
//  UIActionSheet+NickBlocks.m
//  GIF
//
//  Created by Nick Lee on 9/7/14.
//  Copyright (c) 2014 Nicholas Lee Designs, LLC. All rights reserved.
//

#import "UIActionSheet+NickBlocks.h"

@implementation UIActionSheet (NickBlocks)

- (id)initWithTitle:(NSString *)inTitle cancelButtonItem:(RIButtonItem *)inCancelButtonItem destructiveButtonItem:(RIButtonItem *)inDestructiveItem otherButtonItem:(RIButtonItem *)inOtherItem
{
    return [self initWithTitle:inTitle cancelButtonItem:inCancelButtonItem destructiveButtonItem:inDestructiveItem otherButtonItems:inOtherItem, nil];
}

@end
