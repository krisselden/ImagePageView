//
//  IPVCollectionViewCell.h
//  ImagePageView
//
//  Created by Kris Selden on 10/20/14.
//  Copyright (c) 2014 Kris Selden. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPVCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end
