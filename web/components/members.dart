
import "components.dart";

abstract class Member extends Component {
    Accessor accessor;
    bool static = false;
    bool abstract = false;
    bool readonly = false;

    bool get private => this.accessor == Accessor.private || this.accessor == Accessor.protected || this.name.startsWith("_");

    @override
    void writeOutput(OutputWriter writer) {
        writer
            ..writeLine()
            ..writeDocs(this.docs, this.notes)
            ..writeLine("// $name: ${this.runtimeType}");
        print("Member missing output: $runtimeType ${getName()}");
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
        this.readonly = input[4] != null;
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
            ..writeDocs(this.docs, this.notes);
        writeGetter(this, type, writer);
        if (!readonly) {
            writeSetter(this, type, writer);
        }
    }

    static void writeGetter(Member member, TypeRef type, OutputWriter writer) {
        if (member.altName != null) {
            writer.writeLine('@JS("${member.getName()}")');
        }
        writer.writeIndented("external ");
        if (member.static) {
            writer.write("static ");
        }
        type.writeOutput(writer);
        writer
            ..write(" get ")
            ..write(member.getJsName())
            ..write(";\n")
        ;
    }

    static void writeSetter(Member member, TypeRef type, OutputWriter writer) {
        if (member.altName != null) {
            writer.writeLine('@JS("${member.getName()}")');
        }
        writer.writeIndented("external ");
        if (member.static) {
            writer.write("static ");
        }
        writer
            ..write("set ")
            ..write(member.getJsName())
            ..write("(")
        ;
        type.writeOutput(writer);
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

        // make sure generic typed arguments are marked as such
        for (final GenericRef ref in generics) {
            ref.type.genericOf = this;
        }
        for (final Parameter arg in arguments) {
            HasGenerics.setGenerics(this, this, arg.type);
        }
        HasGenerics.setGenerics(this, this, this.type);
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

    @override
    void writeOutput(OutputWriter writer) {
        writer
            ..writeLine()
            ..writeDocs(this.docs, this.notes);
        if (altName != null) {
            writer.writeLine('@JS("${getName()}")');
        }
        writer.writeIndented("external ");
        if (static) {
            writer.write("static ");
        }
        type.writeOutput(writer);
        writer
            ..write(" ")
            ..write(this.getJsName());

        if (!this.generics.isEmpty) {
            writer.write("<");
            for (final GenericRef ref in generics) {
                ref.writeOutput(writer);
                if (ref != generics.last) {
                    writer.write(", ");
                }
            }
            writer.write(">");
        }

        writer.write("(");

        for (final Parameter parameter in this.arguments) {
            parameter.writeOutput(writer);
            if (parameter != arguments.last) {
                writer.write(", ");
            }
        }

        writer.write(");\n");
    }
}

abstract class GetterSetter {}

class Getter extends Member implements GetterSetter {
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

    @override
    void writeOutput(OutputWriter writer) {
        writer
            ..writeLine()
            ..writeDocs(this.docs, this.notes);
        Field.writeGetter(this, type, writer);
    }
}

class Setter extends Member implements GetterSetter {
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

    @override
    void writeOutput(OutputWriter writer) {
        writer
            ..writeLine()
            ..writeDocs(this.docs, this.notes);
        Field.writeSetter(this, argument.type, writer);
    }
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
        final ClassDef parent = owner.parentClass;

        // wish I didn't have to ignore this but then I also wish the actual null operator *worked*
        // ignore: prefer_null_aware_operators
        final Constructor parentConstructor = parent == null ? null : parent.constructor;

        writer
            ..writeLine()
            ..writeDocs(this.docs, this.notes)
            //..writeLine("// Constructor")
            ..writeIndented("external ")
            ..write(owner.getName())
            ..write("(")
        ;

        for (final Parameter parameter in this.arguments) {
            parameter.writeOutput(writer);
            if (parameter != arguments.last) {
                writer.write(", ");
            }
        }

        writer.write(")");
        if (parentConstructor != null) {
            writer.write(":super._js()");
        }
        writer.write(";\n");


        writer
            ..writeIndented("external ")
            ..write(owner.getName())
            ..write("._js()")
        ;

        if (parentConstructor != null) {
            writer.write(":super._js()");
        }
        writer.write(";\n");
    }

    static void writeBlankConstructor(TypeDef clazz, OutputWriter writer) {
        final ClassDef parent = clazz.parentClass;

        // wish I didn't have to ignore this but then I also wish the actual null operator *worked*
        // ignore: prefer_null_aware_operators
        final Constructor parentConstructor = parent == null ? null : parent.constructor;

        writer
            ..writeIndented("external ")
            ..write(clazz.getName())
            ..write("()")
        ;

        if (parentConstructor != null) {
            writer.write(":super._js()");
        }
        writer.write(";\n");
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

    @override
    void writeOutput(OutputWriter writer) {
        writer
            ..writeLine()
            ..writeDocs(docs, notes)
            ..writeLine("/* array access */");
    }
}