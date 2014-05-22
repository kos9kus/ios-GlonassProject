//
//  avViewController.h
//  Glonass
//
//  Created by Ko$ on 02.04.14.
//  Copyright (c) 2014 AV-Grup-Ko$. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface avViewCellController : UIViewController
@property (retain, nonatomic) IBOutlet UIWebView *newsViewBlock;
@property(nonatomic,retain) NSDictionary *newsContent;

@end
