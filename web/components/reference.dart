import "components.dart";

class TypeRef extends Component {//} with HasGenerics {

    TypeDef type;
    final Set<GenericRef> generics = <GenericRef>{};
    int array = 0;
    Component genericOf;

    @override
    void getTypeRefs(Set<TypeRef> references) {
        references.add(this);
        this.type?.processTypeRefs(references);
        for (final GenericRef ref in generics) {
            ref.processTypeRefs(references);
        }
    }

    @override
    String getName() => this.type != null ? this.type.name : this.name;

    @override
    String toString() => "(${this.getName() == null ? "unnamed" : this.getName()}${generics.isEmpty ? "" : "<${generics.join(",")}>"})";
}

class TypeUnionRef extends TypeRef {
    Set<TypeRef> unionRefs = <TypeRef>{};

    @override
    void getTypeRefs(Set<TypeRef> references) {
        super.getTypeRefs(references);
        for (final TypeRef ref in unionRefs) {
            ref.processTypeRefs(references);
        }
    }

    @override
    String toString() => "( ${this.unionRefs.join(" | ")} )";
}

class LambdaRef extends TypeRef {
    LambdaRef() {
        this.type = StaticTypes.typeDynamic;
    }
}