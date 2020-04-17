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
    String name;
    List<String> docs;
    final List<String> notes = <String>[];

    void process(dynamic input) {
        if (!(input is List<dynamic>)) { return; }
        final List<dynamic> data = input;
        this.processList(data);
    }
    void processList(List<dynamic> input) { print("${this.runtimeType}: $input"); }

    void getTypeRefs(Set<TypeRef> references);
    void processTypeRefs(Set<TypeRef> references) { getTypeRefs(references); }

    String getName() => name;

    @override
    String toString() => "(${displayString()})";

    String displayName() => (this.name == null || this.name.isEmpty) ? "unnamed" : this.name;
    String displayString() => "${this.runtimeType} ${displayName()}";
}

mixin HasGenerics on Component {
    final Set<GenericRef> generics = <GenericRef>{};

    @override
    void processTypeRefs(Set<TypeRef> references) {
        final Set<TypeRef> intermediary = <TypeRef>{};
        this.getTypeRefs(intermediary);

        //print("Refs in ${this.name} -------------- $intermediary");

        references.addAll(intermediary.where((TypeRef ref) {
            //print("${ref.runtimeType} ${ref.name} ---");
            if (ref.type != null || ref.name == null ) { return true; }
            for (final GenericRef generic in generics) {
                //print("vs ${generic.runtimeType} ${generic.type.name} $generic");
                if (ref.name == generic.getName()) {
                    //print("excluding type $ref from $this as it is in $generics (${ref.name} == ${generic.type.name})");
                    ref.genericOf = this;
                    return false;
                }
            }
            return true;
        }));
    }
}