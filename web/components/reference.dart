import "components.dart";

class TypeRef extends Component {
    TypeDef type;
    final Set<TypeRef> generics = <TypeRef>{};
    int array = 0;
    bool generic = false;

    @override
    String toString() => "(${type != null ? type.name : (name == null ? "unnamed" : name)}${generics.isEmpty ? "" : "<${generics.join(",")}>"})";
}
