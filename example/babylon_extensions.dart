@JS("BABYLON")
library BabylonExtensions;

import "dart:html";
import "package:js/js.dart";

import "babylon.dart";
import "babylon_debug.dart";
import "interop_globals.dart";

@anonymous
@JS()
class ShaderMaterialShaderPath {
    external factory ShaderMaterialShaderPath({
        String vertex, String fragment,
        ScriptElement vertexElement, ScriptElement fragmentElement,
        String vertexSource, String fragmentSource
    });
}
