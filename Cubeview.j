@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "three.js"

@implementation Cubeview : CPView
{
    id scene, camera, renderer, raycaster, group, curnormal, curcube, curmesh, boxes;

    id colorSource @accessors;
}

- (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame: aRect]
    if(self)
    {
        [self setBackgroundColor: [CPColor redColor]];
        var width = [self bounds].size.width;
        var height = [self bounds].size.height;

        boxes = {}

        scene = new THREE.Scene();
        camera = new THREE.PerspectiveCamera(75, width / height, 0.1, 1000 );

        renderer = new THREE.WebGLRenderer();
        renderer.setSize(width, height);
        _DOMElement.appendChild( renderer.domElement );

        raycaster = new THREE.Raycaster();

        camera.position.z = 5;

        var light = new THREE.PointLight( 0x0000ff, 1, 100 );
        light.position.set( 6, 6, 6 );
        scene.add( light );

        var light = new THREE.PointLight( 0x00ff00, 1, 100 );
        light.position.set( -6, -6, -6 );
        scene.add( light );

        var light = new THREE.AmbientLight( 0x404040 ); // soft white light
        scene.add( light );

        group = new THREE.Group();
        scene.add( group );

        // First cube
        [self makeCubeAt:new THREE.Vector3(0, 0, 0) withColor:0xffffff];

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

            for (var i in group.children)
            {
                var chl = group.children[i];

                if (!chl.geometry) { continue; }

                for (var f in chl.geometry.faces)
                {
                    var face = chl.geometry.faces[f];
                    if (face.color)
                    {
                        face.color.set(chl.geometry.intcolor);
                    }
                }
            }

            curnormal = null;
            [self updateSelect:mouse];

            for (var i in group.children)
            {
                var chl = group.children[i];
                if (!chl.geometry) { continue; }
                chl.geometry.colorsNeedUpdate = true;
            }

            if (!is_down) { return; }

            var dx = e.screenX - last[0];
            var dy = e.screenY - last[1];

            [self rotateCam: CGPointMake(dx, dy)];
            last = [e.screenX, e.screenY];
        };

        renderer.domElement.onmouseup = function(e) {
            is_down = false;
        };

        renderer.domElement.onclick = function(e) {
            if (!curnormal) { return; }

            var x = curnormal.x + curcube.position.x;
            var y = curnormal.y + curcube.position.y;
            var z = curnormal.z + curcube.position.z;

            [self makeCubeAt:new THREE.Vector3(x, y, z) withColor:[self color]];

            [self setNeedsDisplay:YES];
        };

        renderer.domElement.oncontextmenu = function(e) {
            console.log("delete", curcube)
            if (!curnormal) { return; }

            var x = curcube.position.x;
            var y = curcube.position.y;
            var z = curcube.position.z;

            var key = x + "," + y + "," + z;
            if (!boxes[key]) { return; }

            group.remove(curmesh);
            boxes[key] = undefined;
        };

        renderer.domElement.onwheel = function(e) {
            camera.position.z += e.deltaY/10;
            [self setNeedsDisplay:YES];
        };


    }
    return self
}

- (void)makeCubeAt:(id)vector3 withColor:(int)color
{
    var x = vector3.x;
    var y = vector3.y;
    var z = vector3.z;

    var key = x + "," + y + "," + z;

    if (boxes[key]) { console.log(key, "exists"); return; }

    var newgeom = new THREE.BoxGeometry();

    newgeom.translate(x, y, z);
    newgeom.position = new THREE.Vector3(x, y, z);
    newgeom.intcolor = color;
    var newmat = new THREE.MeshBasicMaterial( {
        vertexColors: THREE.FaceColors,
        color: newgeom.intcolor
    } );
    var newcube = new THREE.Mesh( newgeom, newmat );

    boxes[key] = { mesh: newcube };
    group.add(newcube);
}

- (void)rotateCam:(CGPoint)pt
{
    group.rotation.x += pt.y/100;
    group.rotation.y += pt.x/100;

    [self setNeedsDisplay:YES];
}

- (void)updateSelect:(id)mouse
{
    // update the picking ray with the camera and mouse position
    raycaster.setFromCamera( mouse, camera );

    // calculate objects intersecting the picking ray
    var intersects = raycaster.intersectObjects( group.children );

    for ( var i = 0; i < intersects.length; i ++ ) {
        var normal = intersects[i].face.normal;
        for ( var c = 0; c < intersects[i].object.geometry.faces.length; c++ ) {
            var face = intersects[i].object.geometry.faces[c];
            if (face.normal.equals(normal)) {
                face.color.set(0xff0000)
            }
        }
        curnormal = normal
        curcube = intersects[i].object.geometry
        curmesh = intersects[i].object
        break;
    }
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(CGRect)aRect
{
    renderer.render( scene, camera );
}

- (int)color
{
    console.log(parseInt("0x" + [[colorSource color] hexString]))
    return parseInt("0x" + [[colorSource color] hexString]);
}

- (CPString)data
{
  var output = {}

  for(var key in boxes)
  {
    var box = boxes[key]
    if (!box) { continue; }
    output[key] = {
      color: box.mesh.geometry.intcolor,
      pos: [
        box.mesh.geometry.position.x,
        box.mesh.geometry.position.y,
        box.mesh.geometry.position.z
      ]
    }
  }
  return btoa(JSON.stringify(output))
}

- (void)setData:(CPString)data
{
  var input = JSON.parse(atob(data))
  scene.remove(group);

  group = new THREE.Group();
  scene.add( group );
  boxes = {}

  for(var key in input)
  {
    var x = input[key]
    [self makeCubeAt:new THREE.Vector3(x.pos[0], x.pos[1], x.pos[2])
           withColor:x.color]
  }
}
@end
