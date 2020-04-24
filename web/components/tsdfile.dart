
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
    }

    void processEnums(Set<Enum> enums) {
        for (final Module m in modules.values) {
            for (final Component c in m.components.values) {
                if (c is Enum) {
                    enums.add(c);
                }
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
            } /*else {
                print("Excluding ${ref.runtimeType} ${ref.getName()} as it is a js class");
            }*/
        }
    }

    @override
    void writeOutput(OutputWriter writer) { }

    @override
    String toString() => "TSDFile";
}