import "components.dart";

class TypeRef<T extends InheritableDef> extends Component {
    final T type;
    final Set<TypeRef<InheritableDef>> generics = <TypeRef<InheritableDef>>{};
    bool array = false;

    TypeRef(T this.type);

    @override
    String toString() => "(${type != null ? type.name : (name == null ? "unnamed" : name)}${generics.isEmpty ? "" : "<${generics.join(",")}>"})";
}

class ClassRef extends TypeRef<ClassDef> {
    ClassRef(ClassDef type) : super(type);
}
class InterfaceRef extends TypeRef<InterfaceDef> {
    InterfaceRef(InterfaceDef type) : super(type);
}
class UnresolvedRef extends TypeRef<InheritableDef> {
    UnresolvedRef(String name) : super(null) {
        this.name = name;
    }
}
class GenericRef extends UnresolvedRef {
    GenericRef(String name) : super(name);
}
