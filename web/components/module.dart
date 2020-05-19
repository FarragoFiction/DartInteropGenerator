
import "components.dart";

class Module extends Component {
    final Map<String, Component> components = <String, Component>{};

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];

        // 1 declare keyword
        // 2 module keyword

        // 3 name
        this.name = input[3].join(".");

        // 4 body
        final List<dynamic> content = input[4][1]; // between braces
        for (final dynamic object in content) {
            if (object is Component) {
                if (object.name == "PostProcessOptions") {
                    print(object);
                }
                components[object.name] = object;
            } else {
                print("Module non-component: $object");
            }
        }
    }

    @override
    void processTypeRefs(Set<TypeRef> references, [Set<String> exclusions]) { getTypeRefs(references, exclusions); }

    @override
    void getTypeRefs(Set<TypeRef> references, [Set<String> exclusions]) {
        for (final Component c in components.values) {
            if (!exclusions.contains(c.getName())) {
                c.processTypeRefs(references);
            }/* else {
                print("Excluding ${c.runtimeType} ${c.getName()} as it is a js class");
            }*/
        }
    }

    @override
    String toString() => "${super.toString()}:$components";

    String getFileName() => name.toLowerCase().replaceAll(".", "_");

    @override
    void writeOutput(OutputWriter writer, [List<String> importNames]) {
        writer
            ..writeLine('@JS("$name")')
            ..writeLine('library $name;')
            ..writeLine()
            ..writeLine('import "dart:html" as HTML;')
            ..writeLine('import "dart:js";')
            ..writeLine('import "dart:math" as Math;')
            ..writeLine('import "dart:typed_data";')
            ..writeLine('import "dart:web_audio" as Audio;')
            ..writeLine('import "dart:web_gl" as WebGL;')
            ..writeLine()
            ..writeLine('import "package:js/js.dart";')
        ;

        if (importNames != null) {
            writer.writeLine();
            for (final String importName in importNames) {
                if (importName == this.getFileName()) { continue; }
                writer.writeLine('import "$importName.dart";');
            }
        }

        writer.writeLine();
        final TSDFile parent = this.parentComponent;
        if (!parent.topLevelComponents.isEmpty) {
            writer.writeLine('export "interop_globals.dart";');
        }
        writer.writeLine('export "promise.dart";');

        for (final Component component in components.values) {
            if (component == null) { continue; }
            if ((!component.shouldWriteToFile) || component.getName().startsWith("_")) { continue; }
            component.writeOutput(writer);
        }
    }

    @override
    void merge(Component otherComponent) {
        if (!(otherComponent is Module)) { throw Exception("Only merge modules with modules dunkass"); }
        final Module other = otherComponent;

        for (final String compName in other.components.keys) {
            if (this.components.containsKey(compName)) {
                // handle conflicts
                final Component thisComp = this.components[compName];
                final Component thatComp = other.components[compName];

                if (thatComp is ClassDef) {
                    if (thisComp is InterfaceDef) {
                        // if we have an interface and the other one has a class, overwrite
                        this.components[compName] = thatComp;
                        //print("class replaces interface $compName");
                    } else if (thisComp is ClassDef) {
                        // conflicting classes
                        //print("class conflict: $compName");
                        thisComp.merge(thatComp);
                    }
                } else if (thatComp is InterfaceDef) {
                    if (thisComp is ClassDef) {
                        // no-op, we take precedence already
                        //print("interface ignored with class: $compName");

                        // actually, turns out we probably need to do this
                        thisComp.merge(thatComp);
                    } else if (thisComp is InterfaceDef) {
                        // interface merger
                        //print("interface conflict: $compName");
                        thisComp.merge(thatComp);
                    }
                } else {
                    print("Module merge conflict: $compName");
                }
            } else {
                // no conflict, merge directly
                this.components[compName] = other.components[compName];
            }
        }
    }
}