import "components.dart";

class Enum extends Component {
    final Set<EnumEntry> values = <EnumEntry>{};

    @override
    void processList(List<dynamic> input) {
        int nextGenerated = 0;
        // 0 docs
        // 1 export
        // 2 const
        // 3 enum
        // 4 name
        this.name = input[4];
        // 5 {
        // 6 values
        for (final dynamic item in input[6]) {
            final EnumEntry entry = new EnumEntry();
            // 0 docs
            entry.docs = item[0];
            // 1 "
            // 2 name
            entry.name = item[2];
            // 3 "
            // 4 = value
            if (item[4] != null) {
                // 0 =
                // 1 value
                entry.value = item[4][1];
                if (entry.value is int) {
                    nextGenerated = entry.value++;
                }
            } else {
                entry.value = nextGenerated++;
            }
            // 5 ,
            this.values.add(entry);
        }
        // 7 }
    }

    @override
    void getTypeRefs(Set<TypeRef> references) {}

    @override
    String toString() => "${super.toString()}:$values";

    @override
    void writeOutput(OutputWriter writer) {
        writer
            ..writeLine()
            ..writeLine("/* enum */")
            ..writeDocs(docs, notes);

        if (this.altName != null) {
            writer.writeLine('@JS("${this.getName()}")');
        }
        writer
            ..writeIndented("abstract class ")
            ..write(this.getJsName())
            ..write(" {\n")
            ..indent+=1;

        for (final EnumEntry entry in this.values) {
            writer
                ..writeLine()
                ..writeDocs(entry.docs, null)
                ..writeIndented("static const ");
            if (entry.value is int) {
                writer.write("int ");
            } else if (entry.value is String) {
                writer.write("String ");
            } else {
                writer.write("dynamic ");
            }
            writer
                ..write(entry.name)
                ..write(" = ")
                ..write(entry.value.toString())
                ..write(";\n");
        }

        writer
            ..indent-=1
            ..writeLine("}");
    }
}

class EnumEntry {
    List<String>? docs;
    late String name;
    late dynamic value;

    @override
    String toString() => "$name = $value";
}