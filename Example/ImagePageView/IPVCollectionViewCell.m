//
//  IPVCollectionViewCell.m
//  ImagePageView
//
//  Created by Kris Selden on 10/20/14.
//  Copyright (c) 2014 Kris Selden. All rights reserved.
//

#import "IPVCollectionViewCell.h"

@implementation IPVCollectionViewCell
-(void)prepareForReuse
{
    [self.activityIndicatorView stopAnimating];
    self.imageView.alpha = 0;
}
@end
