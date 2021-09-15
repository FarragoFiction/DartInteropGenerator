
import "components.dart";

abstract class Member extends Component {
    Accessor? accessor;
    bool static = false;
    bool abstract = false;
    bool readonly = false;

    Set<Member> ancestors = <Member>{};
    Set<Member> descendants = <Member>{};

    bool get private => this.accessor == Accessor.private || this.accessor == Accessor.protected || this.name!.startsWith("_");

    @override
    void writeOutput(OutputWriter writer) {
        writer
            ..writeLine()
            ..writeDocs(this.docs, this.notes)
            ..writeLine("// $name: ${this.runtimeType}");
        print("Member missing output: $runtimeType ${getName()}");
    }
}

mixin FieldLike on Member {
    TypeRef? getFieldType();
}

class Field extends Member implements FieldLike {
    TypeRef? type;

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
        this.type?.parentComponent = this;
    }

    @override
    TypeRef? getFieldType() => type;

    @override
    void getTypeRefs(Set<TypeRef> references) {
        if (this.getJsName().startsWith("_")) { return; }
        this.type?.processTypeRefs(references);
    }

    @override
    String displayString() => "${super.displayString()}${type == null ? "" : ": $type"}";

    @override
    void writeOutput(OutputWriter writer) {
        writer
            ..writeLine()
            ..writeDocs(this.docs, this.notes);
        if (!this.ancestors.isEmpty) {
            writer.writeLine("@override");
        }
        writeGetter(this, type!, writer);
        if (!readonly) {
            if (!this.ancestors.isEmpty) {
                writer.writeLine("@override");
            }
            writeSetter(this, type!, writer);
        }
    }

    static void writeGetter(Member member, TypeRef type, OutputWriter writer, [String? displayName]) {
        displayName ??= member.getName();

        if (member.altName != null) {
            writer.writeLine('@JS("$displayName")');
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

    static void writeSetter(Member member, TypeRef type, OutputWriter writer, [String? displayName]) {
        displayName ??= member.getName();

        if (member.altName != null) {
            writer.writeLine('@JS("$displayName")');
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
    TypeRef? type;
    //Set<GenericRef> generics = <GenericRef>{};
    List<Parameter> arguments = <Parameter>[];

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
                    item.parentComponent = this;
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
            ref.type?.genericOf = this;
        }
        for (final Parameter arg in arguments) {
            HasGenerics.setGenerics(this, this, arg.type);
        }
        HasGenerics.setGenerics(this, this, this.type);
        this.type?.parentComponent = this;
        FunctionDeclaration.checkForbiddenParameterNames(arguments);
    }

    @override
    void getTypeRefs(Set<TypeRef> references) {
        if (this.getJsName().startsWith("_")) { return; }
        for (final GenericRef ref in generics) {
            ref.processTypeRefs(references);
        }
        for (final Parameter ref in arguments) {
            ref.processTypeRefs(references);
        }
        this.type?.processTypeRefs(references);
    }

    int countRequiredParams() {
        for (int i=0; i<this.arguments.length; i++) {
            if (this.arguments[i].optional) {
                return i;
            }
        }
        return arguments.length;
    }

    @override
    String displayString() => "${super.displayString()}${generics.isEmpty ? "" : "<${generics.join(",")}>"}: $arguments -> $type";

    @override
    void writeOutput(OutputWriter writer) {
        writer
            ..writeLine()
            ..writeDocs(this.docs, this.notes);
        if (!this.ancestors.isEmpty) {
            writer.writeLine("@override");
        }
        if (altName != null) {
            writer.writeLine('@JS("${getName()}")');
        }
        writer.writeIndented("external ");
        if (static) {
            writer.write("static ");
        }
        type?.writeOutput(writer);
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

        bool optionalsStarted = false;
        for (final Parameter parameter in this.arguments) {
            if (!optionalsStarted) {
                if (parameter.optional) {
                    optionalsStarted = true;
                    writer.write("[");
                }
            } else {
                if (!parameter.optional) {
                    print("BAD OPTIONAL PARAMETER IN ${this.getName()}: ${parameter.getName()}");
                }
            }
            parameter.writeOutput(writer);
            if (parameter != arguments.last) {
                writer.write(", ");
            }
        }
        if (optionalsStarted) {
            writer.write("]");
        }

        writer.write(");\n");
    }

    LambdaRef toLambda() => new LambdaRef()
        ..name = name
        ..returnType = type
        ..generics.addAll(generics)
        ..altName = altName
        ..docs = docs
        ..notes.addAll(notes)
        ..arguments.addAll(arguments)
    ;
}

abstract class GetterSetter {}

class Getter extends Member implements GetterSetter, FieldLike {
    TypeRef? type;
    late String fieldName;

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
        this.fieldName = input[5];
        this.name = "${fieldName}_getter";
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

        this.type?.parentComponent = this;
    }

    @override
    TypeRef? getFieldType() => type;

    @override
    void getTypeRefs(Set<TypeRef> references) {
        if (this.getJsName().startsWith("_")) { return; }
        this.type?.processTypeRefs(references);
    }

    @override
    void writeOutput(OutputWriter writer) {
        writer
            ..writeLine()
            ..writeDocs(this.docs, this.notes);
        if (!this.ancestors.isEmpty) {
            writer.writeLine("@override");
        }
        Field.writeGetter(this, type!, writer, fieldName);
    }

    @override
    void checkTypeNames(Set<String> types){
        final String baseName = fieldName;
        if (types.contains(baseName)) {
            altName = "${baseName}_js";
        }
    }

    @override
    String getJsName() => this.altName != null ? this.altName! : this.fieldName;
}

class Setter extends Member implements GetterSetter, FieldLike {
    Parameter? argument;
    late String fieldName;

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
        this.fieldName = input[5];
        this.name = "${fieldName}_setter";
        // 6 (
        // 7 arg
        this.argument = input[7];
        //this.argument.parentComponent = this;
        //ConstrainedObject.markImportant(argument.type);
        // 8 )
        // 9 semicolon

        this.argument?.parentComponent = this;
    }

    @override
    TypeRef? getFieldType() => argument?.type;

    @override
    void getTypeRefs(Set<TypeRef> references) {
        if (this.getJsName().startsWith("_")) { return; }
        this.argument?.processTypeRefs(references);
    }

    @override
    void writeOutput(OutputWriter writer) {
        writer
            ..writeLine()
            ..writeDocs(this.docs, this.notes);
        if (!this.ancestors.isEmpty) {
            writer.writeLine("@override");
        }
        Field.writeSetter(this, argument!.type!, writer, fieldName);
    }

    @override
    void checkTypeNames(Set<String> types){
        final String baseName = fieldName;
        if (types.contains(baseName)) {
            altName = "${baseName}_js";
        }
    }

    @override
    String getJsName() => this.altName != null ? this.altName! : this.fieldName;
}

class Constructor extends Component {
    late bool private;
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
                    item.parentComponent = this;
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
        final TypeDef owner = parentComponent! as TypeDef;
        final ClassDef? parent = owner.parentClass as ClassDef?;

        // wish I didn't have to ignore this but then I also wish the actual null operator *worked*
        // ignore: prefer_null_aware_operators
        final Constructor? parentConstructor = parent == null ? null : parent.constructor;

        writer
            ..writeLine()
            ..writeDocs(this.docs, this.notes)
            ..writeIndented("external factory ")
            ..write(parentComponent!.getName())
            ..write("(")
        ;

        bool optionalsStarted = false;
        for (final Parameter parameter in this.arguments) {
            if (!optionalsStarted) {
                if (parameter.optional) {
                    optionalsStarted = true;
                    writer.write("[");
                }
            } else {
                if (!parameter.optional) {
                    print("BAD OPTIONAL PARAMETER IN ${this.getName()}: ${parameter.getName()}");
                }
            }
            parameter.writeOutput(writer);
            if (parameter != arguments.last) {
                writer.write(", ");
            }
        }
        if (optionalsStarted) {
            writer.write("]");
        }

        writer.write(")");
        /*if (parentConstructor != null) {
            writer.write(":super._js()");
        }*/
        writer.write(";\n");


        /*writer
            ..writeIndented("external ")
            ..write(parentComponent.getName())
            ..write("._js()")
        ;

        if (parentConstructor != null) {
            writer.write(":super._js()");
        }
        writer.write(";\n");*/
    }

    static void writeBlankConstructor(TypeDef clazz, OutputWriter writer) {
        final ClassDef? parent = clazz.parentClass as ClassDef?;

        // wish I didn't have to ignore this but then I also wish the actual null operator *worked*
        // ignore: prefer_null_aware_operators
        final Constructor? parentConstructor = parent == null ? null : parent.constructor;

        writer
            ..writeIndented("external factory ")
            ..write(clazz.getName())
            ..write("()")
        ;

        /*if (parentConstructor != null) {
            writer.write(":super._js()");
        }*/
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