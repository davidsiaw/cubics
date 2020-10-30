@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Cubeview.j"

@implementation AppController : CPObject
{
    CPColorPanel colorpanel;
    Cubeview mainview;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];

    colorpanel = [CPColorPanel sharedColorPanel];
    [colorpanel setColor:[CPColor whiteColor]];

    mainview = [[Cubeview alloc] initWithFrame: [contentView bounds]];
    [contentView addSubview:mainview];
    [mainview setColorSource:colorpanel];

    [theWindow orderFront:self];

    // Uncomment the following line to turn on the standard menu bar.
    [CPMenu setMenuBarVisible:YES];

    var menu = [[CPApplication sharedApplication] mainMenu];

    [menu addItemWithTitle:"Colors" action:@selector(openPanel:) keyEquivalent:"c"];
}

- (id)openPanel:(id)sender
{
    [colorpanel orderFront:self];
}

@end
