import "components.dart";

abstract class StaticTypes {
    static final ClassDef typeDynamic = new ClassDef()..name="dynamic";
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