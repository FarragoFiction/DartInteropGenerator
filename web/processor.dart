import "package:petitparser/petitparser.dart";

import "components/components.dart";
import "parser.dart";
import "grammar.dart";

class Processor {
    final Map<String, TypeDef> presetTypes = <String, TypeDef>{};
    final Set<String> jsClasses = <String>{};

    Processor() {
        presetTypes.addAll(StaticTypes.mapping);
    }

    void process(String input) {
        final GrammarParser processor = new TSDParser();

        final DateTime startTime = new DateTime.now();
        print("Starting parse");

        final Result<dynamic> result = processor.parse(input);
        print("Parsed in ${new DateTime.now().difference(startTime)}: ${result.isSuccess ? "success" : result}");
        //print(result);
        //print("Done in ${new DateTime.now().difference(startTime)}");

        if (result.isFailure) { return; }

        //return;

        final TSDFile tsd = result.value;
        print("modules: ${tsd.modules.length}, other components: ${tsd.topLevelComponents.length}");
        print(tsd.modules.values.map((Module m) => m.name).toList());
        //print(tsd.modules);
        //print(tsd.topLevelComponents);

        final Set<TypeDef> typeDefs = <TypeDef>{};
        tsd.getTypeDefs(typeDefs);

        //prune the js classes out because we don't want the mixins
        typeDefs.removeWhere((TypeDef def) => jsClasses.contains(def.getName()));

        final Set<TypeRef> typeRefs = <TypeRef>{};
        tsd.processTypeRefs(typeRefs, jsClasses);
        final Set<Enum> enums = <Enum>{};
        tsd.processEnums(enums);

        print("TypeDefs: ${typeDefs.length}");
        print(typeDefs.map((TypeDef t) => t.name).toList());

        print("TypeRefs: ${typeRefs.length}");
        print(typeRefs);

        print("Enums: ${enums.length}");
        print(enums.map((Enum t) => t.name).toList());

        // start with the preset types
        final Map<String, TypeDef> typeMap = new Map<String,TypeDef>.from(presetTypes);
        // add all the defined classes, minus the already pruned JS ones
        typeMap.addAll(new Map<String,TypeDef>.fromIterable(typeDefs, key: (dynamic t) => t.getName()));
        // add all the enums as ints
        typeMap.addAll(new Map<String,TypeDef>.fromIterable(enums, key: (dynamic t) => t.getName(), value: (dynamic t) => StaticTypes.typeInt));

        final Set<String> unresolved = <String>{};

        for (final TypeRef ref in typeRefs) {
            if (ref.type == null) {
                final String name = ref.getName();
                if (typeMap.containsKey(name)) {
                    ref.type = typeMap[name];
                } else {
                    unresolved.add(name);
                }
            }
        }

        print("Unresolved types: ${unresolved.length}");
        print(unresolved);
    }
}