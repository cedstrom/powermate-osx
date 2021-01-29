//
//  AppDelegate.m
//  PowerMate Control Center
//
//  Created by Chris Edstrom on 1/25/21.
//  Copyright © 2021 Chris Edstrom. All rights reserved.
//

#import "AppDelegate.h"
#import "PowermateControllerDriver.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (retain) PowermateControllerDriver* driver;

@property (retain) NSStatusItem* menuItem;
@property (retain) NSMenuItem* connectionStateMenuItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
  
  NSStatusBar* statusBar = NSStatusBar.systemStatusBar;
  _menuItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
  _menuItem.button.title = @"⭕";
  _menuItem.menu = [[NSMenu alloc] initWithTitle:@"Powermate Driver"];
  
  _connectionStateMenuItem = [[NSMenuItem alloc] initWithTitle:@"Disconnected" action:nil keyEquivalent:@""];
  
  [_menuItem.menu addItem:_connectionStateMenuItem];
  [_menuItem.menu addItem:[NSMenuItem separatorItem]];
  [_menuItem.menu addItemWithTitle:@"Quit" action:@selector(quit:) keyEquivalent:@"q"];
  
  _driver = [[PowermateControllerDriver alloc] initWithDelegate:self];
}

-(void) quit:(id) sender {
  [NSApp terminate:sender];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  if(_driver) {
    [_driver setLedOff];
  }
}

-(void) controller:(PowermateControllerDriver *)driver didChangeState:(BOOL)connected {
  if(connected) {
    _connectionStateMenuItem.title = @"Connected";
    _menuItem.button.title = @"🎛️";
  } else {
    _connectionStateMenuItem.title = @"Disconnected";
    _menuItem.button.title = @"⭕";
  }
}


@end
