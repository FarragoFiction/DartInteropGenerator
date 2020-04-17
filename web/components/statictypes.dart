import "components.dart";

abstract class StaticTypes {
    //static final ClassDef typeVoid = new ClassDef()..name="void";
    static final ClassDef typeDynamic = new ClassDef()..name="dynamic";

    static final ClassDef typeString = new ClassDef()..name="String";
    //static final ClassDef typeNum = new ClassDef()..name="num";
    static final ClassDef typeInt = new ClassDef()..name="int";
    //static final ClassDef typeDouble = new ClassDef()..name="double";
    //static final ClassDef typeBool = new ClassDef()..name="bool";
    //static final ClassDef typeFunction = new ClassDef()..name="Function";

    static final ClassDef typeList = new ClassDef()..name="List";
    //static final ClassDef typeSet = new ClassDef()..name="Set";
    //static final ClassDef typeFloat32List = new ClassDef()..name="Float32List";
    //static final ClassDef typeInt32List = new ClassDef()..name="Int32List";
    //static final ClassDef typeUint32List = new ClassDef()..name="Uint32List";
    //static final ClassDef typeUint16List = new ClassDef()..name="Uint16List";

    //static final ClassDef typeByteBuffer = new ClassDef()..name="ByteBuffer";

    static final Map<String, TypeDef> mapping = new Map<String,TypeDef>.fromIterable(rawMapping.entries, key: (dynamic entry) => entry.key, value: (dynamic item) {
        final MapEntry<String,dynamic> entry = item;
        if (entry.value is TypeDef) {
            return entry.value;
        } else if (entry.value is String) {
            return new TypeDef()..name = entry.value;
        } else {
            throw Exception("Invalid type mapping entry: ${entry.value}");
        }
    });
    static final Map<String, dynamic> rawMapping = <String, dynamic> {
        "void": "void",
        "null": "void",
        "any": typeDynamic,
        "this": typeDynamic, // weird
        "unknown": typeDynamic,
        "undefined": typeDynamic, // this one is weird
        "object": typeDynamic, // object literals
        "Function": "Function",
        "Promise": "Promise",
        "Error": "Error",
        "Event": "Event",

        "string": typeString,
        "String": typeString,
        "number": "num",
        "Number": "num",
        "int": typeInt,
        "float": "double",
        "double": "double",
        "boolean": "bool",
        "Boolean": "bool",

        "Array": typeList,
        "ArrayLike": typeList,
        "ReadonlyArray": typeList,
        "Set": "Set",

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

        // dart:html
        "HTMLElement": "HTML.Element",
        "HTMLImageElement": "HTML.ImageElement",
        "Document": "HTML.Document",
        "Blob": "HTML.Blob",
        "File": "HTML.File",
        "ImageData": "HTML.ImageData",

        // other
        "XMLHttpRequestResponseType": typeString,
        "XMLHttpRequestEventMap": typeDynamic,
        "AddEventListenerOptions": typeDynamic,
        "EventListenerOptions": typeDynamic,
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
        if (item != null && byName.containsKey(item.value)) {
            return byName[item.value];
        }
        return Accessor.public;
    }
}

class ArrayBrackets {
    int count = 0;

    TypeRef toType() {
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