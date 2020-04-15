
import "components.dart";

abstract class TypeDeclaration extends TypeDef {}

class TypeUnionDef extends TypeDeclaration {
    Set<TypeRef> unionTypes = <TypeRef>{};

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
    }

    @override
    Iterable<String> getPrintComponents() => this.unionTypes.map((TypeRef r) => r.toString());
}

class TypeThingy extends TypeDeclaration {
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
        // 4 =
        // 5 closure
        // 6 semicolon
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
        // 4 =
        // 5 some clump of text
        // 6 semicolon
    }
}