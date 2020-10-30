@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "three.js"

@implementation AppController : CPObject
{

}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];

    var mainview = [[Cubeview alloc] initWithFrame: [contentView bounds]];
    [contentView addSubview:mainview];

    [theWindow orderFront:self];

    // Uncomment the following line to turn on the standard menu bar.
    [CPMenu setMenuBarVisible:YES];
}

@end

@implementation Cubeview : CPView
{
    id scene, camera, renderer;
}

- (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame: aRect]
    if(self)
    {
        [self setBackgroundColor: [CPColor redColor]];
        var width = [self bounds].size.width;
        var height = [self bounds].size.height;

        scene = new THREE.Scene();
        camera = new THREE.PerspectiveCamera(75, width / height, 0.1, 1000 );

        renderer = new THREE.WebGLRenderer();
        renderer.setSize(width, height);
        _DOMElement.appendChild( renderer.domElement );

        var geometry = new THREE.BoxGeometry();
        var material = new THREE.MeshBasicMaterial( { color: 0x00ff00 } );
        var cube = new THREE.Mesh( geometry, material );
        scene.add( cube );

        camera.position.z = 5;
    }
    return self
}

- (void)drawRect:(CGRect)aRect
{
    renderer.render( scene, camera );
}

@end
