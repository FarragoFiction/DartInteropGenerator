import "components.dart";

class TypeDef extends Component with HasGenerics{
    final Set<TypeRef> inherits = <TypeRef>{};
    Iterable<TypeRef> extend;
    Iterable<TypeRef> implement;

    //final Set<GenericRef> generics = <GenericRef>{};
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
    void getTypeRefs(Set<TypeRef> references) {
        for (final TypeRef ref in inherits) {
            ref.processTypeRefs(references);
        }
        for (final Member ref in members) {
            ref.processTypeRefs(references);
        }
    }

    @override
    void merge(Component otherComponent) {
        if (!(otherComponent is TypeDef)) { throw Exception("only merge typedefs with other typedefs dunkass"); }
        final TypeDef other = otherComponent;

        final Map<String,Member> mapped = new Map<String,Member>.fromIterable(this.members, key: (dynamic m) => m.name);
        for (final Member member in other.members) {
            if (!mapped.containsKey(member.name)) {
                this.members.add(member);
            }
        }
    }

    @override
    String toString() => "${super.toString()}:{${getPrintComponents().join(", ")}}";
    @override
    String displayName() => "${super.displayName()}${generics.isEmpty ? "" : "<${generics.join(",")}>"}";

    void writeReference(OutputWriter writer, Set<GenericRef> gen) {
        writer.write(Component.makeNameSafe(name));
        if (!gen.isEmpty) {
            writer.write("<");
            for (final GenericRef ref in gen) {
                ref.writeOutput(writer);
                if (gen.last != ref) {
                    writer.write(",");
                }
            }
            writer.write(">");
        }
    }

    @override
    void writeOutput(OutputWriter writer) {
        final String safeName = Component.makeNameSafe(name);
        
        writer
            ..writeLine()
            ..writeDocs(this.docs, this.notes)
            ..writeIndented('@JS(');
        if (name != safeName) {
            writer
                ..write('"')
                ..write(name)
                ..write('"');
        }
        writer
            ..write(')\n')
            ..writeIndented(writeType())
            ..write(" ");
        writeReference(writer, generics);
        writer.write(" ");

        if (!extend.isEmpty) {
            writer.write("extends ");
            extend.first.writeOutput(writer);
            writer.write(" ");
        }

        if (!implement.isEmpty) {
            writer.write("implements ");
            for (final TypeRef ref in implement) {
                ref.writeOutput(writer);
                if (implement.last != ref) {
                    writer.write(", ");
                }
            }
            writer.write(" ");
        }

        writer
            ..write("{\n")
            ..indent += 1;

        writeContents(writer);

        writer..indent-=1..writeLine("}");
    }

    String writeType() => "type";
    void writeContents(OutputWriter writer) {
        for (final Member member in members) {
            if (member.accessor == Accessor.private || member.name.startsWith("_")) { continue; }
            member.writeOutput(writer);
        }
    }

    @override
    void processTypeRefs(Set<TypeRef> references) => this.processTypeRefsForGenerics(references);
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
        for (final GenericRef ref in generics) {
            ref.type.genericOf = this;
        }
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

    @override
    void getTypeRefs(Set<TypeRef> references) {
        super.getTypeRefs(references);
        this.constructor?.processTypeRefs(references);
    }

    @override
    void merge(Component otherComponent) {
        super.merge(otherComponent);
        final ClassDef c = otherComponent;
        if (this.constructor == null && c.constructor != null) {
            this.constructor = c.constructor;
        }
    }

    @override
    void writeContents(OutputWriter writer) {
        this.constructor?.writeOutput(writer);
        super.writeContents(writer);
    }

    @override
    String writeType() => "class";
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
        for (final GenericRef ref in generics) {
            ref.type.genericOf = this;
        }
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

    @override
    String writeType() => "abstract class";

    @override
    void writeContents(OutputWriter writer) {
        for (final Member member in members) {
            member.writeOutput(writer);
        }
    }
}