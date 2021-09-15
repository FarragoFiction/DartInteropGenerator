
import "components.dart";

abstract class TypeDeclaration extends TypeDef {
    @override
    void writeOutput(OutputWriter writer) {}
    @override
    void writeReference(OutputWriter writer, Set<GenericRef> generics) => writer.write("dynamic");
}

class TypeUnionDef extends TypeDeclaration {
    Set<TypeRef> unionTypes = <TypeRef>{};
    bool isNullableUnion = false;

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 export
        // 2 type
        // 3 type object
        final TypeRef ref = input[3];
        this.name = ref.name;
        this.generics.addAll(ref.generics);
        for (final GenericRef ref in generics) {
            ref.parentComponent = this;
        }
        // 4 =
        // 5 some weird extra |
        // 6 list of types
        if (input[6] is TypeUnionRef) {
            this.unionTypes.addAll(input[6].unionRefs);
        } else if (input[6] is TypeRef) {
            // string ref
            this.unionTypes.add(input[6]);
        } else {
            print("TypeUnionDef non-type: ${input[6]} in $input");
        }
        // 7 semicolon

        for (final TypeRef ref in unionTypes) {
            ref.parentComponent = this;
        }
    }

    @override
    void getTypeRefs(Set<TypeRef> references) {
        for (final GenericRef ref in generics) {
            ref.processTypeRefs(references);
        }
        for (final TypeRef ref in unionTypes) {
            ref.processTypeRefs(references);
        }
    }

    @override
    Iterable<String> getPrintComponents() => this.unionTypes.map((TypeRef r) => r.toString());

    @override
    void writeReference(OutputWriter writer, Set<GenericRef> generics) {
        final Set<TypeRef> filtered = unionTypes.where((TypeRef ref) => ref.type != StaticTypes.typeVoid).toSet();
        if (filtered.length == 1 && !generics.isEmpty) {
            //print("union type generic input: $generics");
            generics.first.writeOutput(writer);
        } else {
            writer.write("dynamic");
        }
    }
}

class TypeThingy extends TypeDeclaration {
    late ConstrainedObject object;

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 export
        // 2 type
        // 3 type object
        final TypeRef ref = input[3];
        this.name = ref.name;
        this.generics.addAll(ref.generics);
        for (final GenericRef ref in generics) {
            ref.parentComponent = this;
        }
        // 4 =
        // 5 closure
        object = input[5];
        print("THINGY: $object");
        object.parentComponent = this;
        // 6 semicolon
    }

    @override
    void getTypeRefs(Set<TypeRef> references) {
        for (final GenericRef ref in generics) {
            ref.processTypeRefs(references);
        }
        references.add(object);
    }

    @override
    void writeOutput(OutputWriter writer) {
        writer.writeLine("// THINGY ${getJsName()}");
    }

}

class TypeModifier extends TypeDeclaration {
    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 export
        // 2 type
        // 3 type object
        final TypeRef ref = input[3];
        this.name = ref.name;
        this.generics.addAll(ref.generics);
        if (generics.isEmpty) {
            print("Type modifier with no generics? ${this.name}");
        }
        for (final GenericRef ref in generics) {
            ref.parentComponent = this;
        }
        // 4 =
        // 5 some clump of text
        // 6 semicolon
    }

    @override
    void getTypeRefs(Set<TypeRef> references) {
        for (final GenericRef ref in generics) {
            ref.processTypeRefs(references);
        }
    }

    @override
    void writeReference(OutputWriter writer, Set<GenericRef> generics) => generics.first.writeOutput(writer);
}