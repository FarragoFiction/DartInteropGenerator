import "components.dart";

class Enum extends Component {
    final Set<EnumEntry> values = <EnumEntry>{};

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        // 1 export
        // 2 enum
        // 3 name
        this.name = input[3];
        // 4 {
        // 5 values
        for (final dynamic item in input[5]) {
            final EnumEntry entry = new EnumEntry();
            // 0 docs
            entry.docs = item[0];
            // 1 name
            entry.name = item[1];
            // 2 =
            // 3 number
            entry.value = item[3];
            // 4 ,
            this.values.add(entry);
        }
        // 6 }
    }

    @override
    void getTypeRefs(Set<TypeRef> references) {}

    @override
    String toString() => "${super.toString()}:$values";
}

class EnumEntry {
    List<String> docs;
    String name;
    int value;

    @override
    String toString() => "$name = $value";
}