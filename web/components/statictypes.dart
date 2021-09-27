import "components.dart";

abstract class StaticTypes {
    static final ClassDef typeDynamic = new ClassDef()..name="dynamic"..canBeExtended=false;
    static final ClassDef typeVoid = new ClassDef()..name="void"..canBeExtended=false;

    static final ClassDef typeString = new ClassDef()..name="String";
    static final ClassDef typeInt = new ClassDef()..name="int";

    static final ClassDef typeList = new ClassDef()..name="List";
    static final ClassDef typeFunction = new ClassDef()..name="Function";

    static final TypeModifier typePartial = new TypeModifier()..name="Partial"..generics.add(new GenericRef()..name="T");

    static final Map<String, TypeDef> mapping = new Map<String,TypeDef>.fromIterable(rawMapping.entries, key: (dynamic entry) => entry.key, value: (dynamic item) {
        final MapEntry<String,dynamic> entry = item;
        if (entry.value is TypeDef) {
            return entry.value;
        } else if (entry.value is String) {
            return new ClassDef()..name = entry.value;
        } else {
            throw Exception("Invalid type mapping entry: ${entry.value}");
        }
    });
    static final Map<String, dynamic> rawMapping = <String, dynamic> {
        "void": typeVoid,
        "null": typeVoid,
        "any": typeDynamic,
        "this": typeDynamic, // weird
        "unknown": typeDynamic,
        "undefined": typeVoid, // this one is weird
        "object": typeDynamic, // object literals
        "Function": typeFunction,
        "Promise": "Promise",
        "Error": "Error",
        "Event": "HTML.Event",
        "Partial": typePartial,
        "RegExp": "RegExp",

        "string": typeString,
        "String": typeString,
        "number": "num",
        "Number": "num",
        "int": typeInt,
        "float": "double",
        "double": "double",
        "boolean": "bool",
        "Boolean": "bool",
        "symbol": "Symbol",
        "true": "bool",
        "false": "bool",
        "Object": "Object",

        "Array": typeList,
        "ArrayLike": typeList,
        "ReadonlyArray": typeList,
        "Set": typeList,
        "ClientRect": "Math.Rectangle<num>",

        // dart:typed_data
        "Float32Array": "Float32List",

        "Int8Array": "Int8List",
        "Int16Array": "Int16List",
        "Int32Array": "Int32List",

        "Uint8Array": "Uint8List",
        "Uint16Array": "Uint16List",
        "Uint32Array": "Uint32List",

        "ArrayBuffer": "ByteBuffer",
        "ArrayBufferView": typeDynamic, // no general version in dart as far as I can tell

        // dart:html as HTML
        "HTMLElement": "HTML.Element",
        "HTMLImageElement": "HTML.ImageElement",
        "Document": "HTML.Document",
        "Blob": "HTML.Blob",
        "File": "HTML.File",
        "ImageData": "HTML.ImageData",
        "HTMLCanvasElement": "HTML.CanvasElement",
        "CanvasRenderingContext2D": "HTML.CanvasRenderingContext2D",
        "OffscreenCanvas": "HTML.OffscreenCanvas",
        "OffscreenCanvasRenderingContext2D": "HTML.OffscreenCanvasRenderingContext2D",
        "HTMLButtonElement": "HTML.ButtonElement",
        "HTMLVideoElement": "HTML.VideoElement",
        "KeyboardEvent": "HTML.KeyboardEvent",
        "Animation": "HTML.Animation",
        "Node": "HTML.Node",
        "PointerEvent": "HTML.PointerEvent",
        "MouseWheelEvent": "HTML.MouseWheelEvent",
        "Gamepad": "HTML.Gamepad",
        "GamepadButton": "HTML.GamepadButton",
        "ImageBitmap": "HTML.ImageBitmap",
        "MediaStream": "HTML.MediaStream",
        "Window": "HTML.Window",
        "DeviceOrientationEvent": "HTML.DeviceOrientationEvent",
        "FocusEvent": "HTML.FocusEvent",
        "ProgressEvent": "HTML.ProgressEvent",
        "ClipboardEvent": "HTML.ClipboardEvent",
        "Worker": "HTML.Worker",
        "MediaStreamTrack": "HTML.MediaStreamTrack",
        "EventTarget": "HTML.EventTarget",
        "DOMPointReadOnly": "HTML.DomPointReadOnly",
        "XMLHttpRequest": "HTML.HttpRequest",
        "HTMLDivElement": "HTML.DivElement",

        // dart:web_gl as WebGL
        "WebGLBuffer": "WebGL.Buffer",
        "WebGLProgram": "WebGL.Program",
        "WebGLRenderingContext": "WebGL.RenderingContext",
        "WebGL2RenderingContext": "WebGL.RenderingContext2",
        "WebGLShader": "WebGL.Shader",
        "WebGLTransformFeedback": "WebGL.TransformFeedback",
        "WebGLQuery": "WebGL.Query",
        "WebGLUniformLocation": "WebGL.UniformLocation",
        "WebGLFramebuffer": "WebGL.Framebuffer",
        "WebGLVertexArrayObject": "WebGL.VertexArrayObject",
        "WebGLTexture": "WebGL.Texture",
        "WebGLRenderbuffer": "WebGL.Renderbuffer",
        "WebGLContextAttributes": "JsArray<dynamic>",

        // dart:web_audio as Audio
        "AudioNode": "Audio.AudioNode",
        "AudioContext": "Audio.AudioContext",
        "GainNode": "Audio.GainNode",
        "AudioBuffer": "Audio.AudioBuffer",

        // other
        "XMLHttpRequestResponseType": typeString,
        "XMLHttpRequestEventMap": typeDynamic,
        "AddEventListenerOptions": typeDynamic,
        "EventListenerOptions": typeDynamic,

        // webXR stuff which dart's API doesn't cover right now
        "XRWebGLLayer": typeDynamic,
        "XRSession": typeDynamic,
        "XRReferenceSpace": typeDynamic,
        "XRFrame": typeDynamic,
        "XRRenderState": typeDynamic,
        "XRInputSource": typeDynamic,
        "XRInputSourceEvent": typeDynamic,
        "XRRigidTransform": typeDynamic,
        "XRSpace": typeDynamic,
        "XRPose": typeDynamic,
    };
}

class Accessor {
    static const Accessor public = Accessor._("public");
    static const Accessor private = Accessor._("private");
    static const Accessor protected = Accessor._("protected");

    final String name;
    static const Map<String, Accessor> byName = <String,Accessor> {
        "public" : public,
        "private" : private,
        "protected": protected
    };

    const Accessor._(String this.name);

    static Accessor process(dynamic item) {
        item = (item == null || item is String) ? item : item.value;
        if (item != null && byName.containsKey(item)) {
            return byName[item]!;
        }
        return Accessor.public;
    }
}

class ArrayBrackets {
    int count = 0;

    TypeRef? toType() {
        if (count == 0) { return null; }
        TypeRef type = new TypeRef()..type = StaticTypes.typeDynamic;
        for (int i=0; i<count; i++) {
            type = new TypeRef()..type = StaticTypes.typeList..generics.add(new GenericRef()..type = type);
        }
        return type;
    }

    @override
    String toString() => "A${"[]"*count}";
}

abstract class ForbiddenNames {
    static const Set<String> names = <String>{
        "continue",
        "class",
        "return",
        "interface",
        "break",
        "this",
    };

    static const Set<String> ignoredMembers = <String>{
        //"toString",
    };
}