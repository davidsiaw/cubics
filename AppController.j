@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Cubeview.j"

@implementation OpenDocumentWindow : CPWindow
{
    CPTextField field;
    Cubeview mainView;
}

- (id)initWithView:(Cubeview)cbv
{
    self = [super initWithContentRect:CGRectMake(50, 50, 500, 100) styleMask:CPTitledWindowMask | CPTexturedBackgroundWindowMask];
    if (self)
    {
        [self setTitle: "Please enter base64"];

        field = [CPTextField textFieldWithStringValue:"" placeholder:"base64" width: 400];
        [[self contentView] addSubview:field]

        var button = [CPButton buttonWithTitle:"Open!"]
        [button setFrameOrigin:CPPointMake(0,50)];
        [button setTarget:self];
        [button setAction:@selector(updateAndClose)];
        [[self contentView] addSubview:button]

        mainView = cbv;
    }
    return self
}

- (void)updateAndClose
{
    [mainView setData:[field stringValue]];
    [self close];
}

@end


@implementation SaveDocumentWindow : CPWindow
{
    CPTextField field;
    Cubeview mainView;
}

- (id)initWithView:(Cubeview)cbv
{
    self = [super initWithContentRect:CGRectMake(50, 50, 500, 100) styleMask:CPTitledWindowMask | CPClosableWindowMask];
    if (self)
    {
        [self setTitle: "Copy this data"];

        field = [CPTextField textFieldWithStringValue:[cbv data] placeholder:"base64" width: 400];
        [[self contentView] addSubview:field];

        mainView = cbv;
    }
    return self
}

@end

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

    var mainMenu = [[CPApplication sharedApplication] mainMenu];

    [mainMenu removeItemAtIndex: 0];
    [mainMenu removeItemAtIndex: 0];
    [mainMenu removeItemAtIndex: 0];
    [mainMenu removeItemAtIndex: 0];
    [mainMenu removeItemAtIndex: 0];

    var newMenuItem = [[CPMenuItem alloc] initWithTitle:@"New" action:@selector(newDocument:) keyEquivalent:@"n"];

    [newMenuItem setImage:[[CPTheme defaultTheme] valueForAttributeWithName:@"menu-general-icon-new" forClass:_CPMenuView]];
    [newMenuItem setAlternateImage:[[CPTheme defaultTheme] valueForAttributeWithName:@"menu-general-icon-new" inState:CPThemeStateHighlighted forClass:_CPMenuView]];

    [mainMenu addItem:newMenuItem];

    var openMenuItem = [[CPMenuItem alloc] initWithTitle:@"Open" action:@selector(openDocument:) keyEquivalent:@"o"];

    [openMenuItem setImage:[[CPTheme defaultTheme] valueForAttributeWithName:@"menu-general-icon-open" forClass:_CPMenuView]];
    [openMenuItem setAlternateImage:[[CPTheme defaultTheme] valueForAttributeWithName:@"menu-general-icon-open" inState:CPThemeStateHighlighted forClass:_CPMenuView]];

    [mainMenu addItem:openMenuItem];

    var saveMenu = [[CPMenu alloc] initWithTitle:@"Save"],
        saveMenuItem = [[CPMenuItem alloc] initWithTitle:@"Save" action:@selector(saveDocument:) keyEquivalent:nil];

    [saveMenuItem setImage:[[CPTheme defaultTheme] valueForAttributeWithName:@"menu-general-icon-save" forClass:_CPMenuView]];
    [saveMenuItem setAlternateImage:[[CPTheme defaultTheme] valueForAttributeWithName:@"menu-general-icon-save" inState:CPThemeStateHighlighted forClass:_CPMenuView]];


    [mainMenu addItem:saveMenuItem];

    var colorMenuItem = [[CPMenuItem alloc] initWithTitle:@"Colors" action:@selector(openPanel:) keyEquivalent:@""];

    [colorMenuItem setImage:[[CPTheme defaultTheme] valueForAttributeWithName:@"menu-general-icon-open" forClass:_CPMenuView]];
    [colorMenuItem setAlternateImage:[[CPTheme defaultTheme] valueForAttributeWithName:@"menu-general-icon-open" inState:CPThemeStateHighlighted forClass:_CPMenuView]];

    [mainMenu addItem:colorMenuItem];
}

- (void)openPanel:(id)sender
{
    [colorpanel orderFront:self];
}

- (void)newDocument:(id)sender
{
    [mainview setData:"eyIwLDAsMCI6eyJjb2xvciI6MTY3NzcyMTUsInBvcyI6WzAsMCwwXX19"]
}

- (void)openDocument:(id)sender
{
    var window = [[OpenDocumentWindow alloc] initWithView:mainview];
    [window orderFront:self];
}

- (void)saveDocument:(id)sender
{
    var window = [[SaveDocumentWindow alloc] initWithView:mainview];
    [window orderFront:self];
}

@end

