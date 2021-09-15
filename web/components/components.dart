import "components.dart";

export "constrainedobject.dart";
export "enums.dart";
export "functions.dart";
export "inheritables.dart";
export "members.dart";
export "module.dart";
export "reference.dart";
export "statictypes.dart";
export "tsdfile.dart";
export "typedeclaration.dart";
export "variable.dart";

abstract class Component {
    Component? parentComponent;
    String? name;
    String? altName;
    List<String>? docs;
    final List<String> notes = <String>[];

    bool shouldWriteToFile = true;

    void process(dynamic input) {
        if (!(input is List<dynamic>)) { return; }
        final List<dynamic> data = input;
        this.processList(data);
    }
    void processList(List<dynamic> input) { print("${this.runtimeType}: $input"); }

    void getTypeRefs(Set<TypeRef> references);
    void processTypeRefs(Set<TypeRef> references) { getTypeRefs(references); }

    Iterable<TypeRef>? getOtherTypesForGenericCheck() => null;

    void checkTypeNames(Set<String> types){
        final String baseName = getName();
        if (types.contains(baseName)) {
            altName = "${baseName}_js";
        }
    }

    String getName() => name ?? "NO_NAME";
    String getJsName() => this.altName ?? this.getName();

    void writeOutput(OutputWriter writer) {
        print("Component missing output: $runtimeType ${getName()}");
    }

    @override
    String toString() => "(${displayString()})";

    String displayName() => (this.name == null || this.name!.isEmpty) ? "unnamed" : this.name!;
    String displayString() => "${this.runtimeType} ${displayName()}";

    static String makeNameSafe(String? name) {
        return name ?? "unnamed";
    }

    void merge(Component otherComponent) {
        // don't handle this by default
    }
}

mixin HasGenerics on Component {
    final Set<GenericRef> generics = <GenericRef>{};

    void processTypeRefsForGenerics(Set<TypeRef> references) {
        final Set<TypeRef> intermediary = <TypeRef>{};
        this.getTypeRefs(intermediary);

        for (final TypeRef ref in intermediary) {
            //print("${ref.runtimeType} ${ref.name} ---");
            if (ref.type != null || ref.name == null ) {
                references.add(ref);
                continue;
            }

            setGenerics(this, this, ref);
            references.add(ref);
        }
    }

    static void setGenerics(Component parent, HasGenerics genericOwner, TypeRef? checkType) {
        if (checkType == null) { return; }

        for (final GenericRef generic in genericOwner.generics) {
            if (checkType.getName() == generic.getName()) {
                //print("excluding type $ref from $this as it is in $generics (${ref.name} == ${generic.type.name})");
                checkType.genericOf = parent;
            }
        }
        for (final GenericRef generic in checkType.generics) {
            setGenerics(parent, genericOwner, generic.type);
        }

        final Iterable<TypeRef>? extra = checkType.getOtherTypesForGenericCheck();
        if (extra != null) {
            for (final TypeRef ref in extra) {
                setGenerics(parent, genericOwner, ref);
            }
        }

        if (parent.parentComponent != null) {
            setGenerics(parent.parentComponent!, parent.parentComponent! as HasGenerics, checkType);
        }
    }
}

class OutputWriter {
    final StringBuffer buffer = new StringBuffer();
    int indent = 0;

    void writeLine([String string = ""]) => buffer.writeln("${"\t" * indent}$string");
    void write(String string) => buffer.write(string);
    void writeIndented(String string) => buffer.write("${"\t" * indent}$string");
    void writeDocs(List<String>? docs, List<String>? comments) {
        final int docsLength = docs == null ? 0 : docs.length;
        final int commentsLength = comments == null ? 0 : comments.length;
        if (docsLength == 0 && commentsLength == 0) { return; }

        if (docsLength > 0) {
            for (final String line in docs!) {
                writeIndented("/// ");
                write(line);
                write("\n");
            }
        }

        if(docsLength > 0 && commentsLength > 0) {
            writeLine("/// ");
        }

        if (commentsLength > 0) {
            writeLine("/// Conversion notes:");
            for (final String line in comments!) {
                writeIndented("/// ");
                write(line);
                write("\n");
            }
        }
    }

    @override
    String toString() => buffer.toString();
}