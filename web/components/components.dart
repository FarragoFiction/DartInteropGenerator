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

class Component {
    String name;
    List<String> docs;
    final List<String> notes = <String>[];

    void process(dynamic input) {
        if (!(input is List<dynamic>)) { return; }
        final List<dynamic> data = input;
        this.processList(data);
    }
    void processList(List<dynamic> input) { print("${this.runtimeType}: $input"); }

    @override
    String toString() => "(${displayString()})";

    String displayName() => (this.name == null || this.name.isEmpty) ? "unnamed" : this.name;
    String displayString() => "${this.runtimeType} ${displayName()}";
}