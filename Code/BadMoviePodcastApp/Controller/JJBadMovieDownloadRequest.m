//
//  JJBadMovieDownloadRequest.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 6/25/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovieDownloadRequest.h"
#import "JJBadMovie.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"

@implementation JJBadMovieDownloadRequest

@synthesize progressHud = _progressHud;

- (void)downloadEpisode:(JJBadMovie *)episode withCompletionHandler:(JJBadMovieDownloadRequestCompletion)completion {
    NSURLRequest *movieRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:episode.url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:movieRequest];
    
    MBProgressHUD *hud = self.progressHud;
    [operation setDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        hud.progress = (totalBytesRead / (float)totalBytesExpectedToRead);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *downloadedFile = responseObject;
        NSString *fileName = [NSString stringWithFormat:@"%@-%@", episode.number, episode.name];
        [downloadedFile writeToFile:fileName
						 atomically:YES];
        hud.labelText = @"Saving";
                
        if (completion) {
            completion(downloadedFile, nil);
            hud.labelText = @"Saved";
        }
        
    } failure:nil];
    
    [operation start];
}

@end
