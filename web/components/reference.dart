import "components.dart";

class TypeRef extends Component with HasGenerics {

    TypeDef type;
    //final Set<GenericRef> generics = <GenericRef>{};
    int array = 0;
    Component genericOf;

    @override
    void getTypeRefs(Set<TypeRef> references) {
        references.add(this);
        this.type?.processTypeRefs(references);
        for (final GenericRef ref in generics) {
            ref.processTypeRefs(references);
        }
    }

    @override
    String getName() => this.type != null ? this.type.name : this.name;

    @override
    String toString() => "(${this.getName() == null ? "unnamed" : this.getName()}${generics.isEmpty ? "" : "<${generics.join(",")}>"})";

    @override
    void writeOutput(OutputWriter writer) {
        if (this.getName().startsWith("_")) {
            writer.write("dynamic");
            return;
        }
        writer.write("List<" * array);
        if (type != null) {
            type.writeReference(writer, generics);
        } else if (genericOf != null) {
            writer.write(name);
        } else {
            //writer.write("[unresolved type $name]");
            print("Unresolved type $name");
            writer.write("dynamic /* unresolved: $name */");
        }
        writer.write(">" * array);
    }
}

class TypeUnionRef extends TypeRef {
    Set<TypeRef> unionRefs = <TypeRef>{};

    @override
    void getTypeRefs(Set<TypeRef> references) {
        for (final TypeRef ref in unionRefs) {
            ref.processTypeRefs(references);
        }
    }

    @override
    String toString() => "( ${this.unionRefs.join(" | ")} )";

    @override
    void writeOutput(OutputWriter writer) {
        if (unionRefs.length == 1) {
            unionRefs.first.writeOutput(writer);
        } else {
            final Set<TypeRef> check = <TypeRef>{};
            for (final TypeRef ref in unionRefs) {
                if (ref.type != StaticTypes.typeVoid) {
                    check.add(ref);
                }
            }
            if (check.length == 1) {
                check.first.writeOutput(writer);
            } else {
                // evaluate whether the types end up the same
                final Set<String> typeOutputs = check.map((TypeRef ref) {
                    final OutputWriter w = new OutputWriter();
                    ref.writeOutput(w);
                    return w.toString();
                }).toSet();

                // if there's only one final output, write it else dynamic
                if (typeOutputs.length == 1) {
                    //print("union type ref merged to ${typeOutputs.first}");
                    writer.write(typeOutputs.first);
                } else {
                    writer.write("dynamic");
                }
            }
        }
    }

    @override
    Iterable<TypeRef> getOtherTypesForGenericCheck() => unionRefs.where((TypeRef ref) => ref.type != StaticTypes.typeVoid);
}

class LambdaRef extends TypeRef {
    final List<Parameter> arguments = <Parameter>[];
    TypeRef returnType;

    @override
    set parentComponent(Component value) {
        super.parentComponent = value;

        for (final Parameter p in arguments) {
            p.parentComponent = value;
        }
    }

    @override
    void processList(List<dynamic> input) {
        List<dynamic> params;
        dynamic returns;

        if (input[0] == "{") {
            // lambda closure
            params = input[1][1];
            returns = input[3];
        } else if (input[1] == "(") {
            // lambda array
            this.array = 1;
            params = input[1][0][1];
            returns = input[1][2];
        } else {
            // basic lambda
            params = input[0][1];
            returns = input[2];
        }

        if (params != null) {
            for (final dynamic item in params) {
                arguments.add(item);
            }
        }
        returnType = returns;
        if (returnType == null) {
            print("LAMBDA: $input");
        }
        FunctionDeclaration.checkForbiddenParameterNames(arguments);
    }

    @override
    void getTypeRefs(Set<TypeRef> references) {
        for (final Parameter ref in arguments) {
            ref.processTypeRefs(references);
        }
        returnType?.processTypeRefs(references);
    }

    @override
    String toString() => "( ${this.arguments.join(", ")} ) => ${returnType?.getName()}";

    @override
    void writeOutput(OutputWriter writer) {
        returnType.writeOutput(writer);
        writer.write(" Function(");

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
    }

    @override
    Iterable<TypeRef> getOtherTypesForGenericCheck() sync* {
        yield this.returnType;
        yield* this.arguments.map((Parameter p) => p.type);
    }
}