//
//  CustomJWPlaylistItem.h
//  RNJWPlayer
//
//  Created by Chaim Paneth on 6/11/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <JWPlayer_iOS_SDK/JWPlayerController.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomJWPlaylistItem : JWPlaylistItem

@property (readwrite) NSInteger seekTime;

@end

NS_ASSUME_NONNULL_END
