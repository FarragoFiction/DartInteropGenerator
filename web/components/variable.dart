
import "components.dart";

class Variable extends Component {
    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 export
        // 2 const/var/etc
        // 3 name
        this.name = input[3];
        // 4 value
        // 5 semicolon
    }

    @override
    void getTypeRefs(Set<TypeRef> references) {}

    @override
    void writeOutput(OutputWriter writer) {
        writer
            ..writeLine()
            ..writeLine("/* var */")
            ..writeDocs(docs, notes);

        if (this.altName != null) {
            writer.writeLine('@JS("${this.getName()}")');
        } else {
            writer.writeLine('@JS()');
        }
        writer.writeIndented("external ");
        /*if (member.static) {
            writer.write("static ");
        }*/
        //type.writeOutput(writer);
        writer
            ..write("dynamic")
            ..write(" get ")
            ..write(this.getJsName())
            ..write(";\n")
        ;
    }
}