//
//  AppDelegate.m
//  ACE View Example
//
//  Created by Michael Robinson on 26/08/12.
//  Copyright (c) 2012 Code of Interest. All rights reserved.
//

#import "ACEViewAppDelegate.h"
#import "ACEView/ACEView.h"
#import "ACEView/ACEModeNames.h"
#import "ACEView/ACEThemeNames.h"
#import "ACEView/ACEKeyboardHandlerNames.h"

@implementation ACEViewAppDelegate

#define ACE_JAVASCRIPT_DIRECTORY @"___ACE_VIEW_JAVASCRIPT_DIRECTORY___"


@synthesize aceView;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *htmlFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"HTML5" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
    [aceView setString:html];
//    [aceView setString:[NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://github.com/faceleg/ACEView"] encoding:NSUTF8StringEncoding
//                                                   error:nil]];
    [aceView setDelegate:self];
    [aceView setKeyboardHandler:ACEKeyboardHandlerAce];
    [aceView setShowPrintMargin:NO];
    [aceView setShowInvisibles:YES];
}

- (NSString *) aceJavascriptDirectoryPath{
    // Unable to use pretty resource paths with CocoaPods
    NSBundle *bundle = [NSBundle bundleForClass:[ACEView class]];
    return [[bundle pathForResource:@"ace" ofType:@"js"] stringByDeletingLastPathComponent];
}

- (NSString *) htmlPageFilePath{
    // Unable to use pretty resource paths with CocoaPods
    NSBundle *bundle = [NSBundle bundleForClass:[ACEView class]];
    return [bundle pathForResource:@"index" ofType:@"html"];
}


- (void) awakeFromNib {
    [syntaxMode addItemsWithTitles:[ACEModeNames humanModeNames]];
    [syntaxMode selectItemAtIndex:ACEModeHTML];
    
    [theme addItemsWithTitles:[ACEThemeNames humanThemeNames]];

    [keyboardHandler addItemsWithTitles:[ACEKeyboardHandlerNames humanKeyboardHandlerNames]];
    [keyboardHandler selectItemAtIndex:ACEKeyboardHandlerAce];
}

- (IBAction) syntaxModeChanged:(id)sender {
}

- (IBAction) themeChanged:(id)sender {
}

- (IBAction) keyboardHandlerChanged:(id)sender {
    [aceView setKeyboardHandler:[keyboardHandler indexOfSelectedItem]];
}

- (void) textDidChange:(NSNotification *)notification {
    // Handle text changes
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
