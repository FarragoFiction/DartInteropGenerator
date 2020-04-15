import "components.dart";

class TypeDef extends Component {
    final Set<TypeRef> inherits = <TypeRef>{};
    Iterable<TypeRef> extend;
    Iterable<TypeRef> implement;

    final Set<GenericRef> generics = <GenericRef>{};
    final Set<Member> members = <Member>{};
    Iterable<Method> methods;
    Iterable<Field> fields;

    TypeDef() {
        extend = inherits.where((TypeRef ref) => ref.type != null && ref.type is ClassDef);
        implement = inherits.where((TypeRef ref) => ref.type != null && ref.type is InterfaceDef);
        methods = members.whereType();
        fields = members.whereType();
    }

    Iterable<String> getPrintComponents() => members.map((Member m) => m.toString());

    @override
    String toString() => "${super.toString()}:{${getPrintComponents().join(", ")}}";
    @override
    String displayName() => "${super.displayName()}${generics.isEmpty ? "" : "<${generics.join(",")}>"}";
}

class ClassDef extends TypeDef {
    Constructor constructor;

    @override
    void processList(List<dynamic> input) {

        // 0 docs
        this.docs = input[0];
        // 1 export?
        // 2 abstract?
        // 3 class keyword
        // 4 name and generics
        this.name = input[4].name;
        this.generics.addAll(input[4].generics);
        // 5 extends
        if (input[5] != null) {
            this.inherits.add(input[5][1]);
        }
        // 6 implements
        if (input[6] != null) {
            for (final dynamic item in input[6][1]) {
                this.inherits.add(item);
            }
        }
        // 7 open brace
        // 8 entries
        for(final dynamic item in input[8]) {
            if (item is Constructor) {
                this.constructor = item;
            } else if (item is Member) {
                this.members.add(item);
            } else if (item is List<String>) {
                // stray comment, discard unfortunately
            } else {
                print("Class non-member: $item");
            }
        }
        // 11 close brace
    }
}

class InterfaceDef extends TypeDef {
    @override
    void processList(List<dynamic> input) {

        // 0 docs
        this.docs = input[0];
        // 1 export?
        // 2 interface keyword
        // 3 name and generics
        this.name = input[3].name;
        this.generics.addAll(input[3].generics);
        // 4 extends
        if (input[4] != null) {
            this.inherits.add(input[4][1]);
        }
        // 5 open brace
        // 6 entries
        for(final dynamic item in input[6]) {
            if (item is Member) {
                this.members.add(item);
            } else if (item is List<String>) {
                // stray comment, discard unfortunately
            } else {
                print("Interface non-member: $item");
            }
        }
        // 7 close brace
    }
}