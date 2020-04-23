
import "components.dart";

abstract class Member extends Component {
    Accessor accessor;
    bool static;
    bool abstract;

    bool get private => this.accessor == Accessor.private || this.accessor == Accessor.protected || this.name.startsWith("_");

    @override
    void writeOutput(OutputWriter writer) {
        writer
            ..writeLine()
            ..writeDocs(this.docs, this.notes)
            ..writeLine("// $name: ${this.runtimeType}");
    }
}

class Field extends Member {
    TypeRef type;

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 accessor
        this.accessor = Accessor.process(input[1]);
        // 2 abstract
        this.abstract = input[2] != null;
        // 3 static
        this.static = input[3] != null;
        // 4 readonly
        // 5 name
        this.name = input[5];
        // 6 optional
        // 7 value or semicolon
        if (input[7] is List<dynamic>) {
            if (input[7][1] is TypeRef) {
                this.type = input[7][1];
            } else if (input[7][1] is ArrayBrackets) {
                this.type = input[7][1].toType();
            } else if (input[7][1] is List<dynamic>) {
                this.type = new TypeRef()..type=StaticTypes.typeDynamic..notes.add(input[7][1].join(" "));
            } else {
                print("Field non-type: ${input[7][1]} in ${input[7]} -> $input");
            }
        }
    }

    @override
    void getTypeRefs(Set<TypeRef> references) { this.type?.processTypeRefs(references); }

    @override
    String displayString() => "${super.displayString()}${type == null ? "" : ": $type"}";

    @override
    void writeOutput(OutputWriter writer) {
        writer
            ..writeLine()
            ..writeDocs(this.docs, this.notes)
            ..writeIndented("external ");
        this.type.writeOutput(writer);
        writer
            ..write(" get ")
            ..write(name)
            ..write(";\n")
            ..writeIndented("external set ")
            ..write(name)
            ..write("(")
        ;
        this.type.writeOutput(writer);
        writer.write(" value);\n");
    }
}

class Method extends Member with HasGenerics {
    TypeRef type;
    //Set<GenericRef> generics = <GenericRef>{};
    Set<Parameter> arguments = <Parameter>{};

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 accessor
        this.accessor = Accessor.process(input[1]);
        // 2 abstract
        this.abstract = input[2] != null;
        // 3 static
        this.static = input[3] != null;
        // 4 readonly
        // 5 name
        this.name = input[5];
        // 6 optional
        // 7 generics
        if (input[7] != null) {
            for (final dynamic item in input[7][1]) {
                if (item is GenericRef) {
                    this.generics.add(item);
                } else {
                    print("Function non-generic $item in ${input[7]} -> $input");
                }
            }
        }
        // 8 arguments
        if (input[8][1] != null) {
            for (final dynamic item in input[8][1]) {
                if (item is Parameter) {
                    this.arguments.add(item);
                } else {
                    print("Function non-parameter $item in ${input[8][1]} -> $input");
                }
            }
        }
        // 9 colon
        // 10 return type
        if (input[10] is TypeRef) {
            this.type = input[10];
        } else if (input[10] is ArrayBrackets) {
            this.type = input[10].toType();
        } else {
            print("Method non-type returned: ${input[10]} in $input");
        }
        // 11 semicolon
    }

    @override
    void getTypeRefs(Set<TypeRef> references) {
        for (final GenericRef ref in generics) {
            ref.processTypeRefs(references);
        }
        for (final Parameter ref in arguments) {
            ref.processTypeRefs(references);
        }
        this.type?.processTypeRefs(references);
    }

    @override
    String displayString() => "${super.displayString()}${generics.isEmpty ? "" : "<${generics.join(",")}>"}: $arguments -> $type";
}

class Getter extends Member {
    TypeRef type;

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 accessor
        this.accessor = Accessor.process(input[1]);
        // 2 abstract
        this.abstract = input[2] != null;
        // 3 static
        this.static = input[3] != null;
        // 4 get
        // 5 name
        this.name = input[5];
        // 6 ()
        // 7 type
        if (input[7] is List<dynamic>) {
            if (input[7][1] is TypeRef) {
                this.type = input[7][1];
            } else if (input[7][1] is ArrayBrackets) {
                this.type = input[7][1].toType();
            } else {
                print("Getter non-type: ${input[7][1]} in ${input[7]} -> $input");
            }
        }
        // 8 semicolon
    }

    @override
    void getTypeRefs(Set<TypeRef> references) { this.type?.processTypeRefs(references); }
}

class Setter extends Member {
    Parameter argument;

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 accessor
        this.accessor = Accessor.process(input[1]);
        // 2 abstract
        this.abstract = input[2] != null;
        // 3 static
        this.static = input[3] != null;
        // 4 set
        // 5 name
        this.name = input[5];
        // 6 (
        // 7 arg
        this.argument = input[7];
        // 8 )
        // 9 semicolon
    }

    @override
    void getTypeRefs(Set<TypeRef> references) { this.argument?.processTypeRefs(references); }
}

class Constructor extends Component {
    bool private;
    Set<Parameter> arguments = <Parameter>{};

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 private
        this.private = input[1] != null;
        // 2 constructor
        // 3 args
        if (input[3][1] != null) {
            for (final dynamic item in input[3][1]) {
                if (item is Parameter) {
                    this.arguments.add(item);
                } else {
                    print("Constructor non-parameter $item in ${input[3][1]} -> $input");
                }
            }
        }
        // 4 semicolon
    }

    @override
    void getTypeRefs(Set<TypeRef> references) {
        for (final Parameter ref in arguments) {
            ref.processTypeRefs(references);
        }
    }

    @override
    void writeOutput(OutputWriter writer) {
        writer
            ..writeLine()
            ..writeDocs(this.docs, this.notes)
            ..writeLine("// Constructor");
    }
}

class ArrayAccess extends Member {
    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 readonly
        // 2 [
        // 3 var name
        // 4 :
        // 5 key type
        this.name = input[5].toString();
        // 6 ]
        // 7 :
        // 8 return type
        // 9 semicolon
    }

    @override
    void getTypeRefs(Set<TypeRef> references) {}
}