//
//  ACEView.m
//  ACEView
//
//  Created by Michael Robinson on 26/08/12.
//  Copyright (c) 2012 Code of Interest. All rights reserved.
//

#import <ACEView/ACEView.h>
#import <ACEView/ACEModeNames.h>
#import <ACEView/ACEThemeNames.h>
#import <ACEView/ACEKeyboardHandlerNames.h>
#import <ACEView/ACERange.h>
#import <ACEView/ACEStringFromBool.h>
#import <ACEView/ACEToken.h>
#import <ACEView/ACESearchItem.h>

#import <ACEView/NSString+EscapeForJavaScript.h>
#import <ACEView/NSInvocation+MainThread.h>

#define ACE_JAVASCRIPT_DIRECTORY @"___ACE_VIEW_JAVASCRIPT_DIRECTORY___"

#pragma mark - ACEViewDelegate
NSString *const ACETextDidEndEditingNotification = @"ACETextDidEndEditingNotification";

#pragma mark - ACEView private
static NSArray *allowedSelectorNamesForJavaScript;

@interface ACEView()

- (NSString *) aceJavascriptDirectoryPath;
- (NSString *) htmlPageFilePath;

- (NSString *) stringByEvaluatingJavaScriptOnMainThreadFromString:(NSString *)script;
- (void) executeScriptsWhenLoaded:(NSArray *)scripts;
- (void) executeScriptWhenLoaded:(NSString *)script;

- (void) resizeWebView;

- (void) showFindInterface;
- (void) showReplaceInterface;

+ (NSArray *) allowedSelectorNamesForJavaScript;

- (void) aceTextDidChange;

@end

#pragma mark - ACEView implementation
@implementation ACEView

@synthesize firstSelectedRange, delegate, webView;

#pragma mark - Internal
- (id) initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) {
        return nil;
    }

    webView = [[WebView alloc] init];
    [webView setFrameLoadDelegate:self];
    
    return self;
}

- (void) awakeFromNib {
    [self addSubview:webView];
    [self setBorderType:NSBezelBorder];
    
    textFinder = [[NSTextFinder alloc] init];
    [textFinder setClient:self];
    [textFinder setFindBarContainer:self];

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    NSString *javascriptDirectory = [self aceJavascriptDirectoryPath];
    
    NSString *htmlPath = [self htmlPageFilePath];
    
    NSString *html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    html = [html stringByReplacingOccurrencesOfString:ACE_JAVASCRIPT_DIRECTORY withString:javascriptDirectory];
    
    [[webView mainFrame] loadHTMLString:html baseURL:[bundle bundleURL]];
}

- (void) setBorderType:(NSBorderType)borderType {
    [super setBorderType:borderType];
    padding = (borderType == NSNoBorder) ? 0 : 1;
    [self resizeWebView];
}

- (NSString *) aceJavascriptDirectoryPath{
    // Unable to use pretty resource paths with CocoaPods
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [[bundle pathForResource:@"ace" ofType:@"js"] stringByDeletingLastPathComponent];
}

- (NSString *) htmlPageFilePath{
    // Unable to use pretty resource paths with CocoaPods
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [bundle pathForResource:@"index" ofType:@"html"];
}

+ (BOOL) isSelectorExcludedFromWebScript:(SEL)aSelector {
    return ![[ACEView allowedSelectorNamesForJavaScript] containsObject:NSStringFromSelector(aSelector)];
}

#pragma mark - NSView overrides
- (void) drawRect:(NSRect)dirtyRect {
    [self resizeWebView];
    [super drawRect:dirtyRect];
}
- (void) resizeSubviewsWithOldSize:(NSSize)oldSize {
    [self resizeWebView];
}

#pragma mark - WebView delegate methods
- (void) webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    [[webView windowScriptObject] setValue:self forKey:@"ACEView"];
}

#pragma mark - NSTextFinderClient methods
- (void) performTextFinderAction:(id)sender {
    [textFinder performAction:[sender tag]];
}
- (void) scrollRangeToVisible:(NSRange)range {
    firstSelectedRange = range;    
    [self executeScriptWhenLoaded:[NSString stringWithFormat:
                                   @"editor.session.selection.clearSelection();"
                                   @"editor.session.selection.setRange(new Range(%@));"
                                   @"editor.centerSelection()",
                                   ACEStringFromRangeAndString(range, [self string])]];
}
- (void) replaceCharactersInRange:(NSRange)range withString:(NSString *)string {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.session.replace(new Range(%@), \"%@\");",
                                    ACEStringFromRangeAndString(range, [self string]), [string stringByEscapingForJavaScript]]];
}
- (BOOL) isEditable {
    return YES;
}

#pragma mark - Private
- (NSString *) stringByEvaluatingJavaScriptOnMainThreadFromString:(NSString *)script {
    SEL stringByEvaluatingJavascriptFromString = @selector(stringByEvaluatingJavaScriptFromString:);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [[webView class] instanceMethodSignatureForSelector:stringByEvaluatingJavascriptFromString]];
    [invocation setSelector:stringByEvaluatingJavascriptFromString];

    [invocation setArgument:&script atIndex:2];
    [invocation setTarget:webView];
    [invocation invokeOnMainThread];

    NSString *contentString;
    [invocation getReturnValue:&contentString];

    return contentString;
}
- (void) executeScriptsWhenLoaded:(NSArray *)scripts {
    if ([webView isLoading]) {
        [self performSelector:@selector(executeScriptsWhenLoaded:) withObject:scripts afterDelay:0.2];
        return;
    }
    [scripts enumerateObjectsUsingBlock:^(id script, NSUInteger index, BOOL *stop) {
        [webView stringByEvaluatingJavaScriptFromString:script];
    }];
}
- (void) executeScriptWhenLoaded:(NSString *)script {
    [self executeScriptsWhenLoaded:@[script]];
}

- (void) resizeWebView {
    NSRect bounds = [self bounds];
    id<NSTextFinderBarContainer> findBarContainer = [textFinder findBarContainer];
    if ([findBarContainer isFindBarVisible]) {
        CGFloat findBarHeight = [[findBarContainer findBarView] frame].size.height;
        bounds.origin.y += findBarHeight;
        bounds.size.height -= findBarHeight;
    }
    
    [webView setFrame:NSMakeRect(bounds.origin.x + padding, bounds.origin.y + padding,
                                 bounds.size.width - (2 * padding), bounds.size.height - (2 * padding))];
}

- (void) showFindInterface {
    [textFinder performAction:NSTextFinderActionShowFindInterface];
    [self resizeWebView];
}
- (void) showReplaceInterface {
    [textFinder performAction:NSTextFinderActionShowReplaceInterface];
    [self resizeWebView];
}

+ (NSArray *) allowedSelectorNamesForJavaScript {
    if (allowedSelectorNamesForJavaScript == nil) {
        allowedSelectorNamesForJavaScript = @[
            @"showFindInterface",
            @"showReplaceInterface",
            @"aceTextDidChange"
        ];
    }
    return [allowedSelectorNamesForJavaScript retain];
}

- (void) aceTextDidChange {
    NSNotification *textDidChangeNotification = [NSNotification notificationWithName:ACETextDidEndEditingNotification
                                                                              object:self];
    [[NSNotificationCenter defaultCenter] postNotification:textDidChangeNotification];
    if (self.delegate == nil) {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(textDidChange:)]) {
        [self.delegate performSelector:@selector(textDidChange:) withObject:textDidChangeNotification];
    }
}

#pragma mark - Public
- (NSString *) string {
    return [self stringByEvaluatingJavaScriptOnMainThreadFromString:@"editor.getValue();"];
}

- (void) setString:(id)string {
    [self executeScriptsWhenLoaded:@[
        @"reportChanges = false;",
        [NSString stringWithFormat:@"editor.setValue(\"%@\");", [string stringByEscapingForJavaScript]],
        @"editor.clearSelection();",
        @"editor.moveCursorTo(0, 0);",
        @"reportChanges = true;",
        @"ACEView.aceTextDidChange();"
    ]];
}

- (NSArray *) token:(NSUInteger)row {
    return [ACEToken fromString:[self stringByEvaluatingJavaScriptOnMainThreadFromString:[NSString stringWithFormat:@"JSON.stringify(editor.session.getTokens(%ld));", row]]];
}

- (NSString*) getLine:(NSInteger)line {
    return [self stringByEvaluatingJavaScriptOnMainThreadFromString:[NSString stringWithFormat:@"editor.session.getLine(%ld);", line]];
}

- (NSString*) getSearchOptions:(NSDictionary*)options {
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:options options:nil error:&error];
    
    if (error || !json) {
        return nil;
    }
    
    return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
}

- (NSArray*) findAll:(NSDictionary*) options {
    NSString* stringOptions = [self getSearchOptions:options];
    NSString* script = [NSString stringWithFormat:@"JSON.stringify(new Search().set(%@).findAll(editor.session));", stringOptions];
        
    return [ACESearchItem fromString:[self stringByEvaluatingJavaScriptOnMainThreadFromString:script]];
}

- (void) replaceAll:(NSString*) replacement options:(NSDictionary*)options {
    NSString* stringOptions = [self getSearchOptions:options];
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.replaceAll(\"%@\", %@);", replacement, stringOptions]];
}

- (NSUInteger) getLength {
    return [self stringByEvaluatingJavaScriptOnMainThreadFromString:@"editor.getSession().getLength() + \"\""].integerValue;
}
- (void) setOption:(NSString*) key stringValue:(NSString*)value {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setOption(\"%@\", \"%@\");", key, value]];
}
- (void) setOption:(NSString*) key integerValue:(NSInteger)value {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setOption(\"%@\", %ld);", key, (long)value]];
}
- (void) setOption:(NSString*) key boolValue:(BOOL)value {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setOption(\"%@\", \"%@\");", key, ACEStringFromBool(value)]];
}
- (void) setMode:(NSString*)mode {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.getSession().setMode(\"ace/mode/%@\");", mode]];
}
- (void) setTheme:(NSString*)theme {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setTheme(\"ace/theme/%@\");", theme]];
}

- (void) setWrappingBehavioursEnabled:(BOOL)wrap {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setWrapBehavioursEnabled(%@);", ACEStringFromBool(wrap)]];
}
- (void) setUseSoftWrap:(BOOL)wrap {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.getSession().setUseWrapMode(%@);", ACEStringFromBool(wrap)]];
}
- (void) setWrapLimitRange:(NSRange)range {
    [self setUseSoftWrap:YES];
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.getSession().setWrapLimitRange(%ld, %ld);", range.location, range.length]];
}
- (void) setNewLineMode:(NSString*)mode {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.getSession().setNewLineMode(%@);", mode]];
}
- (void) setUseSoftTabs:(BOOL)tabs {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.getSession().setUseSoftTabs(%@);", ACEStringFromBool(tabs)]];
}
- (void) setTabSize:(NSInteger)size {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.getSession().setTabSize(%ld);", (long)size]];
}
- (void) setShowInvisibles:(BOOL)show {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setShowInvisibles(%@);", ACEStringFromBool(show)]];
}
- (void) setShowFoldWidgets:(BOOL)show {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setShowFoldWidgets(%@);", ACEStringFromBool(show)]];
}
- (void) setFadeFoldWidgets:(BOOL)fade {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setFadeFoldWidgets(%@);", ACEStringFromBool(fade)]];
}
- (void) setHighlightActiveLine:(BOOL)highlight {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setHighlightActiveLine(%@);", ACEStringFromBool(highlight)]];
}
- (void) setHighlightGutterLine:(BOOL)highlight {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setHighlightGutterLine(%@);", ACEStringFromBool(highlight)]];
}
- (void) setHighlightSelectedWord:(BOOL)highlight {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setHighlightSelectedWord(%@);", ACEStringFromBool(highlight)]];
}
- (void) setDisplayIndentGuides:(BOOL)display {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setDisplayIndentGuides(%@);", ACEStringFromBool(display)]];
}
- (void) setAnimatedScroll:(BOOL)animate {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setAnimatedScroll(%@);", ACEStringFromBool(animate)]];
}
- (void) setScrollSpeed:(NSUInteger)speed {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setScrollSpeed(%ld);", speed]];
}
- (void) setKeyboardHandler:(ACEKeyboardHandler)keyboardHandler {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setKeyboardHandler(%@);", [ACEKeyboardHandlerNames commandForKeyboardHandler:keyboardHandler]]];
}
- (void) setPrintMarginColumn:(NSUInteger)column {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setPrintMarginColumn(%ld);", column]];
}
- (void) setShowPrintMargin:(BOOL)show {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setShowPrintMargin(%@);", ACEStringFromBool(show)]];
}
- (void) setFontSize:(NSUInteger)size {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.setFontSize('%ldpx');", size]];
}

- (void) gotoLine:(NSInteger)lineNumber column:(NSInteger)columnNumber animated:(BOOL)animate {
    [self executeScriptWhenLoaded:[NSString stringWithFormat:@"editor.gotoLine(%ld, %ld, %@);", lineNumber, columnNumber, ACEStringFromBool(animate)]];
}

@end
