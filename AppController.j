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
    id scene, camera, renderer, raycaster, cube;
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

        raycaster = new THREE.Raycaster();

        var geometry = new THREE.BoxGeometry();
        var material = new THREE.MeshBasicMaterial( {
            vertexColors: THREE.VertexColors,
            color: 0xffffff
        } );
        //material.wireframe = true
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
            var mouse = new THREE.Vector2();
            mouse.x = ( e.offsetX / width ) * 2 - 1 + [self bounds].origin.x;
            mouse.y = - ( e.offsetY / height ) * 2 + 1 + [self bounds].origin.y;

            for (var i in geometry.faces)
            {
                if (geometry.faces[i].color)
                {
                    geometry.faces[i].color.setHex(0xffffff);

                }
            }

            [self updateSelect:mouse];
            geometry.elementsNeedUpdate = true;

            if (!is_down) { return; }

            var dx = e.screenX - last[0];
            var dy = e.screenY - last[1];

            [self rotateCam: CGPointMake(dx, dy)];
            last = [e.screenX, e.screenY];
        };

        renderer.domElement.onmouseup = function(e) {
            is_down = false;
        };

        renderer.domElement.onwheel = function(e) {
            camera.position.z += e.deltaY/10;
            [self setNeedsDisplay:YES];
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

- (void)updateSelect:(id)mouse
{
    // update the picking ray with the camera and mouse position
    raycaster.setFromCamera( mouse, camera );

    // calculate objects intersecting the picking ray
    var intersects = raycaster.intersectObjects( scene.children );

    for ( var i = 0; i < intersects.length; i ++ ) {
        var normal = intersects[i].face.normal;
        for ( var c = 0; c < intersects[i].object.geometry.faces.length; c++ ) {
            var face = intersects[i].object.geometry.faces[c];
            if (face.normal.equals(normal)) {
                face.color.set(0xff0000)
            }
        }
    }
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(CGRect)aRect
{
    renderer.render( scene, camera );
}

@end
