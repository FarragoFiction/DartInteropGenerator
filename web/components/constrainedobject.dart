
import "components.dart";

class ConstrainedObject extends TypeRef {
    ConstrainedObject() {
        this.name = "object";
    }

    final Set<Field> fields = <Field>{};

    @override
    void processList(List<dynamic> input) {
        // 0 open brace
        // 1 list of contents
        for (final dynamic item in input[1]) {
            if (item is Field) {
                // field
                //print("field: $item");
                fields.add(item);
            } else if (item is Method) {
                // method
                //print("method: $item");

                final LambdaRef lambda = item.toLambda();
                final Field field = new Field()
                    ..name = item.name
                    ..type = lambda
                    ..docs = item.docs
                    ..notes.addAll(item.notes)
                    ..altName = item.altName
                ;
                fields.add(field);

            } else if (item is ArrayAccess) {
                // array access
                //print("array access");
            } else if (item is List<dynamic>){
                if (item.length == 4) {
                    // object key def
                    //print("object key def: $item");
                    final Field field = new Field()
                        ..name = item[0][1];
                    if (item[2] is TypeRef) {
                        field.type = item[2];
                    } else if (item[2] is ArrayBrackets) {
                        field.type = item[2].toType();
                    } else {
                        print("WEIRD FIELD STUFF: ${item[2]}");
                    }
                    fields.add(field);
                } else {
                    // object line
                    print("object line: $item");
                }
            }
        }
        // 2 close brace

        for (final Field f in fields) {
            f.parentComponent = this;
        }
    }

    @override
    void getTypeRefs(Set<TypeRef> references) {
        references.add(this);
        for (final Field ref in fields) {
            ref.processTypeRefs(references);
        }
    }

    @override
    String toString() => "{ ${fields.join(", ")} }";

    @override
    void writeOutput(OutputWriter writer) {
        if (type != null) {
            // if we have a type generated, use that
            super.writeOutput(writer);
            //writer.write("dynamic /* object defined */");
        } else {
            // otherwise, dynamic it is
            writer.write("dynamic /* object */");
        }
    }

    @override
    Iterable<TypeRef> getOtherTypesForGenericCheck() => fields.map((Field f) => f.type!);

    static void writeObjectTemplateClass<T extends Component>(OutputWriter writer, String jsName, Map<String, T> fields, {Component Function(T c)? process, String? name, Iterable<GenericRef>? generics, List<String>? docs, List<String>? notes}) {
        process ??= (Component c) => c;
        name ??= jsName;

        writer
            ..writeLine()
            ..writeDocs(docs, notes)
            ..writeIndented('@JS(');
        if (name != jsName) {
            writer
                ..write('"')
                ..write(name)
                ..write('"');
        }
        writer
            ..write(')\n')
            ..writeLine("@anonymous")
            ..writeIndented("class ")
            ..write(jsName);

        if (generics != null && !generics.isEmpty) {
            writer.write("<");
            for (final GenericRef ref in generics) {
                ref.writeOutput(writer);
                if (generics.last != ref) {
                    writer.write(",");
                }
            }
            writer.write(">");
        }

        writer
            ..write(" {\n")
            ..indent += 1;

        // the constructor
        if (!fields.isEmpty) {
            writer
                ..writeLine()
                ..writeIndented("external factory ")
                ..write(jsName)..write("({");

            for (final String name in fields.keys) {
                final T type = fields[name]!;

                process(type).writeOutput(writer);
                writer..write(" ")..write(name);

                if (name != fields.keys.last) {
                    writer.write(", ");
                }
            }

            writer.write("});\n");
        }

        // all the fields
        for (final String name in fields.keys) {
            final T type = fields[name]!;
            writer
                ..writeLine()
                ..writeDocs(type.docs, type.notes)
                ..writeIndented("external ");
            process(type).writeOutput(writer);
            writer
                ..write(" get ")
                ..write(name)
                ..write(";\n")
                ..writeIndented("external set ")
                ..write(name)
                ..write("( ");
            process(type).writeOutput(writer);
            writer.write(" value );\n");
        }

        writer
            ..indent -= 1
            ..writeLine("}");
    }
}

class InlinedObjectType extends TypeDef {
    late ConstrainedObject basedOn;

    @override
    void writeOutput(OutputWriter writer) {
        //writer.writeLine("// object ${getName()}: ${fields.map((Field f) => "${f.type} ${f.getJsName()}").toList()}");

        ConstrainedObject.writeObjectTemplateClass(
            writer,
            this.getName(),
            new Map<String, TypeRef>.fromIterable(fields, key: (dynamic f) => f.getJsName(), value: (dynamic f) => f.type),
            generics: generics
        );
    }

    void processGenerics() {
        for (final Field f in fields) {
            if (f.type!.genericOf != null) {
                this.generics.add(new GenericRef()..type=f.type);
                print("${this.getName()} generic: ${f.type!.getName()}");
            }
        }
    }

    @override
    void getTypeRefs(Set<TypeRef> references) {} // maybe?
    @override
    void processTypeRefs(Set<TypeRef> references) {}

    @override
    String getName() {
        if(this.name == null) {
            final List<String> parts = <String>[];

            if (basedOn.parentComponent == null) {
                print("Object with no parent: $basedOn");
            }

            Component obj = basedOn;
            while (obj.parentComponent != null) {
                obj = obj.parentComponent!;

                if (!(obj is TypeRef || obj is GenericRef)) {
                    /*if (obj.getJsName() == null) {
                        print("obj: $obj, ${obj.runtimeType}");
                    }*/
                    if (obj is Constructor) {
                        parts.add("constructor");
                    } else {
                        parts.add(obj.getJsName());
                    }
                }
            }

            this.name = parts.reversed.map((String s) => s.isEmpty ? "_" : "${s.substring(0,1).toUpperCase()}${s.substring(1)}").join();
        }
        return this.name!;
    }
}