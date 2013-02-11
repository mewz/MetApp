//
//  AppDelegate.m
//  MetApp
//
//  Created by Jason Hullinger on 2/9/13.
//  Copyright (c) 2013 amewzing. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

OSStatus (*LSCopyAllApplicationURLs)( NSArray* *theList );

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    appsDataSource = [NSMutableArray array];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [appsDataSource count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if([[aTableColumn identifier]isEqualToString:@"appName"]){
        return [[appsDataSource objectAtIndex:rowIndex]objectForKey:@"appName"];
    }
    else if([[aTableColumn identifier]isEqualToString:@"appProtocol"]){
        return [[appsDataSource objectAtIndex:rowIndex]objectForKey:@"appProtocol"];
    }
    return nil;
}

- (void) tableViewSelectionDidChange: (NSNotification *) notification
{
    NSInteger selectedRow = [self.tableView selectedRow];
    if(selectedRow >= 0){
        NSString *descString = [NSString stringWithFormat:@"%@", [appsDataSource objectAtIndex:selectedRow]];
        [[self descriptionTextView]setString:descString];
    }
}

-(IBAction)listApps:(id)sender
{
    [self.listAppsButton setEnabled:NO];
    [self.progressIndicator startAnimation:nil];
    [NSThread detachNewThreadSelector:@selector(copyAllAppsInfo) toTarget:self withObject:nil];
}

-(void)copyAllAppsInfo
{
    CFBundleRef bundleRef = CFBundleGetBundleWithIdentifier(CFSTR("com.apple.LaunchServices"));
    //the only way I could find a list of all applications is to query for _LSCopyAllApplicationURLs
    //however, this is not documented and could be removed at any time so look here first if an update causes a crash
    LSCopyAllApplicationURLs = CFBundleGetFunctionPointerForName(bundleRef, CFSTR("_LSCopyAllApplicationURLs"));

    NSMutableArray *appsArray;
    LSCopyAllApplicationURLs(&appsArray);
    
    //loop through appsArray and find which ones responde to a URL protocol scheme
    //obj being a NSURL to the application
    [appsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSBundle *appBundle = [NSBundle bundleWithURL:(NSURL*)obj];
        NSArray *urlTypes = [appBundle objectForInfoDictionaryKey:@"CFBundleURLTypes"];

        if(urlTypes != nil && urlTypes.count > 0){
            NSString *appName = [[NSFileManager defaultManager]displayNameAtPath:[appBundle bundlePath]];
            NSMutableString *protocolSchemes = [NSMutableString string];
        
            //obj being a NSDictionary
            [urlTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSArray *schemeArray = [(NSDictionary*)obj objectForKey:@"CFBundleURLSchemes"];
                [schemeArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [protocolSchemes appendFormat:@"%@ ", obj];
                }];
            }];
            
            //add the items to the datasource array
            [appsDataSource addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:appName, protocolSchemes, [appBundle infoDictionary], nil]
                                                                  forKeys:[NSArray arrayWithObjects:@"appName", @"appProtocol", @"appInfo", nil]]];
        }
        
    }];
    
    //update the UI
    [self.listAppsButton setEnabled:YES];
    [self.progressIndicator stopAnimation:nil];
    [self.tableView reloadData];
}

@end
