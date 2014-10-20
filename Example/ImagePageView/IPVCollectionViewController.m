//
//  IPVViewController.m
//  ImagePageView
//
//  Created by Kris Selden on 10/20/2014.
//  Copyright (c) 2014 Kris Selden. All rights reserved.
//

#import "IPVCollectionViewController.h"
#import "IPVCollectionViewCell.h"
#import <IPVImagePageViewController.h>

@implementation IPVCollectionViewController

- (IBAction)fetchImages
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.photosDataSource loadWithBlock:^{
        [self.collectionView reloadData];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[IPVImagePageViewController class]] &&
        [sender isKindOfClass:[IPVCollectionViewCell class]]) {
        IPVImagePageViewController *destinationViewController = segue.destinationViewController;
        IPVCollectionViewCell *cell = sender;

        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        IPVPhoto *photo = [self photoAtIndexPath:indexPath];
        destinationViewController.dataSource = self.photosDataSource;
        [destinationViewController setKey:photo
                                direction:UIPageViewControllerNavigationDirectionForward
                                 animated:NO
                               completion:^(BOOL finished) {
                               }];
    }
}

- (IPVPhoto *)photoAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.photosDataSource photoAtIndex:indexPath.item];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _photosDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IPVPhoto *photo = [self photoAtIndexPath:indexPath];
    IPVCollectionViewCell *cell = [self.collectionView
                                   dequeueReusableCellWithReuseIdentifier:@"ImageThumbnail"
                                   forIndexPath:indexPath];
    NSInteger tag = cell.tag = indexPath.item;
    BOOL isCached = [_photosDataSource
                     thumbnailForPhoto:photo
                     progressHandler:nil
                     completionHandler:^(UIImage *image, NSError *error) {
                         if (cell.tag != tag) {
                             return;
                         }
                         if (error) {
                             NSLog(@"Failed to load thumbnail: %@", [error localizedDescription]);
                         } else {
                             cell.imageView.image = image;
                             if (cell.activityIndicatorView.isAnimating) {
                                 [cell.activityIndicatorView stopAnimating];
                                 [UIView animateWithDuration:0.2 animations:^{
                                     cell.imageView.alpha = 1.0;
                                 }];
                             } else {
                                 cell.imageView.alpha = 1.0;
                             }
                         }
                     }];
    if (!isCached) {
        [cell.activityIndicatorView startAnimating];
    }
    return cell;
}

@end
