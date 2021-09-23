import "dart:html";

import "package:LoaderLib/Loader.dart";
import "package:js/js.dart" as js;
import "package:js/js_util.dart" as jsu;

import 'babylon.dart' as B;

Future<void> main() async {
    final CanvasElement canvas = querySelector("#canvas")! as CanvasElement;
    final B.Engine engine = new B.Engine(canvas, true);
    final B.Scene scene = await createScene(engine, canvas);

    engine.runRenderLoop(js.allowInterop(() { scene.render(); }));

    /*final B.Promise<String> promise = new B.Promise<String>(js.allowInterop((void Function(String value) accept, void Function(dynamic reason) reject) {
        new Future<void>.delayed(const Duration(seconds: 3), () => accept("hello"));
    }));

    final Future<String> s = jsu.promiseToFuture(promise).then((dynamic string) {

        print("future: $string");

        return string;
    });*/
}

Future<B.Scene> createScene(B.Engine engine, CanvasElement canvas) async {
    final B.Scene scene = new B.Scene(engine);
    final B.Camera camera = new B.ArcRotateCamera("camera", 0, 0, 5, B.Vector3.Zero(), scene)
        ..attachControl(canvas, false);

    final B.Light light = new B.HemisphericLight("light1", new B.Vector3(0,1,0), scene);

    final B.Mesh plane = B.MeshBuilder.CreatePlane("plane", B.MeshBuilderCreatePlaneOptions( size: 2 ) , scene);

    final String vert = await Loader.getResource("basic.vert");
    final String frag = await Loader.getResource("timehole.frag");
    
    final B.ShaderMaterial material = new B.ShaderMaterial("material", scene, jsu.jsify(<String,dynamic>{ "vertexSource": vert, "fragmentSource": frag }))
        ..backFaceCulling = false;

    plane.material = material;

    final DateTime startTime = new DateTime.now();
    scene.registerBeforeRender(js.allowInterop(([dynamic a, dynamic b]) {
        material.setFloat("time", (DateTime.now().difference(startTime)).inMilliseconds * 0.001);
        material.setVector3("cameraPosition", camera.position);
    }));

    return scene;
}