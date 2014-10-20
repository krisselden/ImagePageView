//
//  IPVFlickrPhoto.m
//  ImagePageView
//
//  Created by Kris Selden on 10/20/14.
//  Copyright (c) 2014 Kris Selden. All rights reserved.
//

#import "IPVPhoto.h"

static inline NSURL *getRecentPhotosURL();
static inline NSURL *photoURL(NSDictionary *photo, NSString *size);
static NSData *cleanData(NSData *data);

@implementation IPVPhoto

+ (instancetype)photoWithJSONObject:(NSDictionary *)JSONObject
                              index:(long)index
{
    return [[self alloc] initWithJSONObject:JSONObject
                                      index:index];
}

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject
                             index:(long)index
{
    self = [super init];
    if (self) {
        _index = index;
        _thumbnailURL = photoURL(JSONObject, @"q");
        _photoURL = photoURL(JSONObject, @"b");
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Photo %ld", self.index+1];
}

+ (void)getPhotos:(void (^)(NSArray *, NSError *))completion
{
    [[[NSURLSession sharedSession]
      dataTaskWithURL:getRecentPhotosURL()
      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
          NSMutableArray *photos = nil;
          if (!error) {
              // quick hack to fix flickr title
              NSDictionary *response = [NSJSONSerialization
                                        JSONObjectWithData:cleanData(data)
                                        options:0
                                        error:&error];
              if (!error) {
                  photos = [NSMutableArray array];
                  NSUInteger index = 0;
                  for (NSDictionary *photo in response[@"photos"][@"photo"]) {
                      [photos addObject:[IPVPhoto photoWithJSONObject:photo
                                                                index:index++]];
                  }
                  
              }
          }
          
          dispatch_async(dispatch_get_main_queue(), ^{
              completion(photos, error);
          });
      }] resume];
}
@end

static inline NSURL *getRecentPhotosURL() {
    NSString *flickrAPIKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FLICKR_API_KEY"];
    if (!flickrAPIKey) {
        [NSException raise:NSGenericException
                    format:@"Missing FLICKR_API_KEY in Info.plist required for demo app"];
    }
    NSString *flickrURL = [NSString
                           stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=%@&format=json&nojsoncallback=1",
                           flickrAPIKey];
    return [NSURL URLWithString:flickrURL];
}

static inline NSURL *photoURL(NSDictionary *photo, NSString *size) {
    NSString *photoURL = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_%@.jpg",
                          photo[@"farm"], photo[@"server"], photo[@"id"], photo[@"secret"], size];
    return [NSURL URLWithString:photoURL];
    
}

static NSData *cleanData(NSData *data) {
    NSMutableString *text = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [text replaceOccurrencesOfString:@"\\u" withString:@"\\\\u" options:0 range:NSMakeRange(0, text.length)];
    return [text dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
}
