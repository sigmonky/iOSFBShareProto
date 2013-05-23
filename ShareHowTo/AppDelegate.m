/*
 * Copyright 2012 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */
/*- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // Handle incoming app links
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:FBSession.activeSession
                    fallbackHandler:^(FBAppCall *call) {
        NSLog(@"In fallback handler");
    }];
}*/
/**
 * A function for parsing URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

- (BOOL)application:(UIApplication *)application
openURL:(NSURL *)url
sourceApplication:(NSString *)sourceApplication
annotation:(id)annotation {
    // To check for a deep link, first parse the incoming URL
    // to look for a target_url parameter
    
    NSString *query = [url fragment];
    if (!query) {
        query = [url query];
    }
    UIAlertView *initialAlert = [[UIAlertView alloc]
                                 initWithTitle:@"News"
                                 message:[NSString stringWithFormat:@"Incoming: %@", query]
                                 delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil,
                                 nil];
    [initialAlert show];
    
   
    
    NSDictionary *params = [self parseURLParams:query];
    // Check if target URL exists
    NSString *targetURLString = [params valueForKey:@"target_url"];
    UIAlertView *targetURLAlert = [[UIAlertView alloc]
                                 initWithTitle:@"News"
                                 message:[NSString stringWithFormat:@"Incoming: %@", targetURLString]
                                 delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil,
                                 nil];
    [targetURLAlert show];
    if (targetURLString) {
        NSURL *targetURL = [NSURL URLWithString:targetURLString];
        NSDictionary *targetParams = [self
                                      parseURLParams:[targetURL query]];
        NSString *deeplink = [targetParams valueForKey:@"deeplink"];
        // Check for the 'deeplink' parameter to check if this is one of
        // our incoming news feed link
        if (deeplink) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"News"
                                  message:[NSString stringWithFormat:@"Incoming: %@", deeplink]
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil,
                                  nil];
            [alert show];
            //[alert release];
        }
    }
    return [FBSession.activeSession handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // We need to properly handle activation of the application with regards to Facebook Login
    // (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [FBSession.activeSession close];
}

@end
