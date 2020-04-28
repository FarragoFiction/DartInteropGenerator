
import "components.dart";

class TSDFile extends Component {
    Map<String, Module> modules = <String,Module>{};
    Set<Component> topLevelComponents = <Component>{};

    @override
    void processList(List<dynamic> input) {
        for (final dynamic item in input) {
            if (item is Module) {
                if (!modules.containsKey(item.name)) {
                    modules[item.name] = item;
                } else {
                    final Module module = modules[item.name];
                    //module.components.addAll(item.components);
                    module.merge(item);
                }
            } else if (item is Component) {
                this.topLevelComponents.add(item);
            } else {
                print("TSDFile top level object: $item");
            }
        }
    }

    void getTypeDefs(Set<TypeDef> definitions) {
        for (final Module m in modules.values) {
            for (final Component c in m.components.values) {
                if (c is TypeDef) {
                    definitions.add(c);
                }
            }
        }
        for (final Component c in topLevelComponents) {
            if (c is TypeDef) {
                definitions.add(c);
            }
        }
    }

    @override
    void checkTypeNames(Set<String> types) {
        for (final Module m in modules.values) {
            for (final Component c in m.components.values) {
                c.checkTypeNames(types);
            }
        }
        for (final Component c in topLevelComponents) {
            c.checkTypeNames(types);
        }
    }

    void processEnums(Set<Enum> enums) {
        for (final Module m in modules.values) {
            for (final Component c in m.components.values) {
                if (c is Enum) {
                    enums.add(c);
                }
            }
        }
        for (final Component c in topLevelComponents) {
            if (c is Enum) {
                enums.add(c);
            }
        }
    }

    @override
    void processTypeRefs(Set<TypeRef> references, [Set<String> exclusions]) { getTypeRefs(references, exclusions); }

    @override
    void getTypeRefs(Set<TypeRef> references, [Set<String> exclusions]) {
        for (final Module ref in modules.values) {
            ref.processTypeRefs(references, exclusions);
        }
        for (final Component ref in topLevelComponents) {
            if (!exclusions.contains(ref.getName())) {
                ref.processTypeRefs(references);
            } else {
                ref.shouldWriteToFile = false;
                //print("Excluding ${ref.runtimeType} ${ref.getName()} as it is a js class");
            }
        }
    }

    @override
    void writeOutput(OutputWriter writer, [List<String> importNames]) {
        writer
            ..writeLine('@JS()')
            ..writeLine('library InteropGlobals;')
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
                writer.writeLine('import "$importName.dart";');
            }
        }

        for (final Component component in topLevelComponents) {
            if (component == null) { continue; }
            if ((!component.shouldWriteToFile) || component.getName().startsWith("_")) { continue; }
            component.writeOutput(writer);
        }
    }

    @override
    String toString() => "TSDFile";
}