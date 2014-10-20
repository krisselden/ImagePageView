//
//  IPVFlickrPhoto.h
//  ImagePageView
//
//  Created by Kris Selden on 10/20/14.
//  Copyright (c) 2014 Kris Selden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPVPhoto : NSObject

+ (void)getPhotos:(void (^)(NSArray *photos, NSError *error))completion;

@property (readonly, nonatomic) long index;
@property (readonly, nonatomic) NSURL *thumbnailURL;
@property (readonly, nonatomic) NSURL *photoURL;

@end
