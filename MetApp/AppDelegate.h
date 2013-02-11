//
//  AppDelegate.h
//  MetApp
//
//  Created by Jason Hullinger on 2/9/13.
//  Copyright (c) 2013 amewzing. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate>
{
    NSMutableArray *appsDataSource;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTableView *tableView;
@property (assign) IBOutlet NSButton *listAppsButton;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet NSTextView *descriptionTextView;

-(IBAction)listApps:(id)sender;

-(void)copyAllAppsInfo;

@end
