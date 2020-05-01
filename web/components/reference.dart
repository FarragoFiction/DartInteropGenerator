import "components.dart";

class TypeRef extends Component with HasGenerics {

    TypeDef type;
    //final Set<GenericRef> generics = <GenericRef>{};
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

    @override
    void writeOutput(OutputWriter writer) {
        if (this.getName().startsWith("_")) {
            writer.write("dynamic");
            return;
        }
        writer.write("JsArray<" * array);
        if (type != null) {
            type.writeReference(writer, generics);
        } else if (genericOf != null) {
            writer.write(name);
        } else {
            //writer.write("[unresolved type $name]");
            print("Unresolved type $name");
            writer.write("dynamic /* unresolved: $name */");
        }
        writer.write(">" * array);
    }
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

    @override
    void writeOutput(OutputWriter writer) {
        if (unionRefs.length == 1) {
            unionRefs.first.writeOutput(writer);
        } else {
            final Set<TypeRef> check = <TypeRef>{};
            for (final TypeRef ref in unionRefs) {
                if (ref.type != StaticTypes.typeVoid) {
                    check.add(ref);
                }
            }
            if (check.length == 1) {
                check.first.writeOutput(writer);
            } else {
                writer.write("dynamic");
            }
        }
    }

    @override
    Iterable<TypeRef> getOtherTypesForGenericCheck() => unionRefs.where((TypeRef ref) => ref.type != StaticTypes.typeVoid);
}

class LambdaRef extends TypeRef {
    LambdaRef() {
        this.type = StaticTypes.typeJsFunction;
    }
}