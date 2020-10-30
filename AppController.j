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
    id scene, camera, renderer, cube;
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
        var material = new THREE.LineBasicMaterial( {
            color: 0xffffff,
            linecap: 'round', //ignored by WebGLRenderer
            linejoin:  'round' //ignored by WebGLRenderer
        } );
        material.wireframe = true
        cube = new THREE.Mesh( geometry, material );
        scene.add( cube );

        camera.position.z = 5;

        var light = new THREE.PointLight( 0x0000ff, 1, 100 );
        light.position.set( 6, 6, 6 );
        scene.add( light );

        var light = new THREE.PointLight( 0x00ff00, 1, 100 );
        light.position.set( -6, -6, -6 );
        scene.add( light );

        var light = new THREE.AmbientLight( 0x404040 ); // soft white light
        scene.add( light );


        var is_down = false;
        var last = [0,0];
        renderer.domElement.onmousedown = function(e) {
            is_down = true;
            last = [e.screenX, e.screenY];
        };

        renderer.domElement.onmousemove = function(e) {
            if (!is_down) { return; }

            var dx = e.screenX - last[0];
            var dy = e.screenY - last[1];

            [self rotateCam: CGPointMake(dx, dy)];
            last = [e.screenX, e.screenY];
        };

        renderer.domElement.onmouseup = function(e) {
            is_down = false;
        };
    }
    return self
}

- (void)rotateCam:(CGPoint)pt
{
    cube.rotation.x += pt.y/100;
    cube.rotation.y += pt.x/100;

    [self setNeedsDisplay:YES];
}

- (void)drawRect:(CGRect)aRect
{
    renderer.render( scene, camera );
}

@end
