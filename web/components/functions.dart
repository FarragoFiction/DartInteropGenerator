
import "components.dart";

class FunctionDeclaration extends Component with HasGenerics {
    //final Set<GenericRef> generics = <GenericRef>{};
    final Set<Parameter> arguments = <Parameter>{};
    TypeRef? type;

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 export
        // 2 function
        // 3 name
        this.name = input[3];
        // 4 type arguments
        if (input[4] != null) {
            for (final dynamic item in input[4][1]) {
                if (item is GenericRef) {
                    this.generics.add(item);
                } else {
                    print("Function non-generic $item in ${input[4]} -> $input");
                }
            }
        }
        // 5 function arguments
        if (input[5][1] != null) {
            for (final dynamic item in input[5][1]) {
                if (item is Parameter) {
                    this.arguments.add(item);
                    item.parentComponent = this;
                } else {
                    print("Function non-parameter $item in ${input[5][1]} -> $input");
                }
            }
        }
        // 6 :
        // 7 return type
        if (input[7] is TypeRef) {
            this.type = input[7];
        } else if (input[7] is ArrayBrackets) {
            this.type = input[7].toType();
        } else {
            print("Method non-type returned: ${input[7]} in $input");
        }
        // 8 semicolon

        this.type?.parentComponent = this;
        checkForbiddenParameterNames(arguments);
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
            ..writeLine("/* top level function */")
            ..writeDocs(this.docs, this.notes);
        if (altName != null) {
            writer.writeLine('@JS("${getName()}")');
        } else {
            writer.writeLine('@JS()');
        }
        writer.writeIndented("external ");
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

    static void checkForbiddenParameterNames(Iterable<Parameter> params) {
        for (final Parameter param in params) {
            if (ForbiddenNames.names.contains(param.getName())) {
                param.altName = "${param.getName()}_js";
            }
        }
    }
}

class Parameter extends Component {
    TypeRef? type;
    bool optional = false;
    bool isArgs = false;

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 name
        if (input[1] is List<dynamic>) {
            // name and optional
            this.name = input[1][0];
            this.optional = input[1][1] != null;
        } else {
            // args
            //print("args ...");
            this.name = "args";
            this.optional = true;
            this.isArgs = true;
        }
        // 2 colon
        // 3 new (because of course this happens sometimes for whatever reason?)
        // 4 type
        if (input[4] is TypeRef) {
            this.type = input[4];
            this.type!.parentComponent = this;
        } else {
            // a string...
        }
    }

    @override
    void getTypeRefs(Set<TypeRef> references) { this.type?.processTypeRefs(references); }

    @override
    String toString() => "$type $name";

    @override
    void writeOutput(OutputWriter writer) {
        this.type?.writeOutput(writer);
        if (this.optional && !this.type!.isNullable) {
            writer.write("?");
        }
        writer
            ..write(" ")
            ..write(this.getJsName());

        /*if(optional) {
            writer.write("/*?*/");
        }*/
    }
}

class GenericRef extends Component {
    TypeRef? type;
    TypeRef? extend;

    @override
    void processList(List<dynamic> input) {
        // 0 type
        if (input[0] is TypeRef) {
            this.type = input[0];
            this.type!.parentComponent = this;
        } else if (input[0] is ArrayBrackets) {
            this.type = input[0].toType();
        } else {
            print("GenericRef non-type: ${input[0]} in $input");
        }
        // 1 optional
        // 2 extends type
        if ((input[2] != null) && (input[2][1] == null)) {
            print("GenericRef: ${input[2]}");
            this.extend = input[2][2];
        }
    }

    @override
    void getTypeRefs(Set<TypeRef> references) {
        this.type?.processTypeRefs(references);
        this.extend?.processTypeRefs(references);
    }

    @override
    String getName() => this.type?.getName() ?? "unnamed";

    @override
    String toString() => "$type${this.extend != null ? " extends $extend" : ""}";

    @override
    void writeOutput(OutputWriter writer) {
        this.type?.writeOutput(writer);
        if (this.extend != null) {
            writer.write(" extends ");
            this.extend!.writeOutput(writer);
        }
    }
}