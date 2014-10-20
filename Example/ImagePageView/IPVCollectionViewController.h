//
//  IPVViewController.h
//  ImagePageView
//
//  Created by Kris Selden on 10/20/2014.
//  Copyright (c) 2014 Kris Selden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPVPhotosDataSource.h"

@interface IPVCollectionViewController : UICollectionViewController
@property (strong, nonatomic) IBOutlet IPVPhotosDataSource *photosDataSource;
@end
