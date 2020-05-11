import "package:petitparser/petitparser.dart";

import "components/components.dart";
import "parser.dart";

class Processor {
    static const String topLevelFilename = "interop_globals";

    final Map<String, TypeDef> presetTypes = <String, TypeDef>{};
    final Set<String> jsClasses = <String>{};

    final Map<String, String> manualFixes = <String,String>{};

    Processor() {
        presetTypes.addAll(StaticTypes.mapping);
    }

    Map<String,String> process(String input) {
        // ################################################## PARSE ##################################################

        final GrammarParser processor = new TSDParser();

        final DateTime startTime = new DateTime.now();
        print("Starting parse");

        final Result<dynamic> result = processor.parse(input);
        print("${new DateTime.now().difference(startTime)}: Parse ${result.isSuccess ? "success" : result}");
        //print(result);
        //print("Done in ${new DateTime.now().difference(startTime)}");

        if (result.isFailure) {
            throw Exception("Parse failed");
        }

        // ################################################## CONVERT TO INTERMEDIARIES ##################################################

        final TSDFile tsd = result.value;
        //print("modules: ${tsd.modules.length}, other components: ${tsd.topLevelComponents.length}");
        //print(tsd.modules.values.map((Module m) => m.name).toList());
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

        /*print("TypeDefs: ${typeDefs.length}");
        print(typeDefs.map((TypeDef t) => t.name).toList());

        print("TypeRefs: ${typeRefs.length}");
        print(typeRefs);

        print("Enums: ${enums.length}");
        print(enums.map((Enum t) => t.name).toList());*/

        // start with the preset types
        final Map<String, TypeDef> typeMap = new Map<String, TypeDef>.from(presetTypes);
        // add all the defined classes, minus the already pruned JS ones
        typeMap.addAll(new Map<String, TypeDef>.fromIterable(typeDefs, key: (dynamic t) => t.getName()));
        // add all the enums as ints
        typeMap.addAll(new Map<String, TypeDef>.fromIterable(enums, key: (dynamic t) => t.getName(), value: (dynamic t) => StaticTypes.typeInt));

        final Set<String> unresolved = <String>{};

        final Set<ConstrainedObject> inlineObjects = <ConstrainedObject>{};

        for (final TypeRef ref in typeRefs) {
            if (ref is ConstrainedObject) {
                inlineObjects.add(ref);
            } else if (ref.type == null) {
                final String name = ref.getName();
                if (typeMap.containsKey(name)) {
                    ref.type = typeMap[name];
                } else if (ref.genericOf == null) {
                    //print("${ref.getName()} not in typeMap${ref.owner == null ? "" : " (from ${ref.owner.getName()})"}");
                    // if it's not a generic, stick it in the unresolved list
                    unresolved.add(name);
                }
            }
        }

        //print("Unresolved types: ${unresolved.length}");
        //print(unresolved);

        // do a pass to correct member names for types
        final Set<String> typeNames = typeDefs.map((TypeDef def) => def.getName()).toSet();
        typeNames.addAll(ForbiddenNames.names);
        tsd.checkTypeNames(typeNames);

        print("${new DateTime.now().difference(startTime)}: Intermediary conversion complete");

        // ################################################## SORT OUT INHERITANCE ##################################################

        fixInheritance(tsd, inlineObjects);

        print("${new DateTime.now().difference(startTime)}: Inheritance fixed");

        // ################################################## WRITE ##################################################

        // write all the outputs and hand them back
        final Map<String,String> outputs = write(tsd);

        print("${new DateTime.now().difference(startTime)}: Applying manual fixes");

        applyManualFixes(outputs);

        print("${new DateTime.now().difference(startTime)}: Done");

        return outputs;
    }

    void fixInheritance(TSDFile tsd, Set<ConstrainedObject> inlinedObjects) {
        // set up inheritance relationships
        for (final TypeDef type in tsd.allTypes()) {
            for(final TypeRef inheritRef in type.inherits) {
                if (inheritRef.type == null || !(inheritRef.type is ClassDef || inheritRef.type is InterfaceDef)) {
                    print("weird inherit in ${type.getName()}: ${inheritRef.type != null ? inheritRef.type.runtimeType : "null"} $inheritRef");
                } else {
                    type.ancestors.add(inheritRef.type);
                    inheritRef.type.descendants.add(type);
                }
            }
        }

        // ################################################## relationships between members ##################################################

        for (final TypeDef type in tsd.allTypes()) {
            for (final Member member in type.members) {
                // check each direction
                for (final dynamic dir in inheritanceDirections) {
                    visit(type, dir[0], (TypeDef def) {
                        if (def == type) {
                            return true;
                        }
                        for (final Member dMember in def.members) {
                            if (member.getName() == dMember.getName()) {
                                dir[1](member).add(dMember);
                                return false;
                            } else if ((member is Field && dMember is GetterSetter && ((dMember.getName() == "${member.getName()}_setter") || (dMember.getName() == "${member.getName()}_getter"))) ||
                                       (dMember is Field && member is GetterSetter && ((member.getName() == "${dMember.getName()}_setter") || (member.getName() == "${dMember.getName()}_getter")))) {
                                // relating fields to getters and setters, and vice versa
                                dir[1](member).add(dMember);
                                return false;
                            }
                        }
                        return true;
                    });
                }
            }
        }

        // ################################################## lambdas vs functions ##################################################
        final Map<Method, LambdaRef> toReplace = <Method, LambdaRef>{};

        // find all the candidates for fixing
        for (final TypeDef type in tsd.allTypes()) {
            for (final Member member in type.members) {
                if (member is Method) {
                    visit(member, (Member m) => m.ancestors, (Member m) {
                        if (m == member) {
                            return true;
                        }

                        if (m is Field) {
                            if (m.type is LambdaRef) {
                                // this is likely a lambda field!
                                toReplace[member] = m.type;

                                return false;
                            }
                        }

                        return true;
                    });
                }
            }
        }

        // do the replacement
        for (final Method method in toReplace.keys) {
            final TypeDef type = method.parentComponent;

            final Field replacementField = new Field()
                ..name = method.name
                ..type = toReplace[method]
                ..ancestors = method.ancestors
                ..descendants = method.descendants
                ..parentComponent = type
            ;

            for (final Member member in method.ancestors) {
                member.descendants
                    ..remove(method)
                    ..add(replacementField)
                ;
            }

            for (final Member member in method.descendants) {
                member.ancestors
                    ..remove(method)
                    ..add(replacementField)
                ;
            }

            type
                ..members.remove(method)
                ..members.add(replacementField);
        }

        // ################################################## omitted optionals ##################################################

        for (final TypeDef type in tsd.allTypes()) {
            for (final Member member in type.members) {
                if (member is Method) {
                    Method ancestorWithMostParameters = member;
                    final int baseReq = member.countRequiredParams();
                    int fewestRequiredParameters = baseReq;

                    visit<Method>(member, (Method m) => m.ancestors.whereType(), (Method m) {
                        if (m == member) { return true; }
                        if (m.arguments.length > ancestorWithMostParameters.arguments.length) {
                            ancestorWithMostParameters = m;
                        }
                        final int req = m.countRequiredParams();
                        if (req < fewestRequiredParameters) {
                            fewestRequiredParameters = req;
                        }
                        return true;
                    });

                    if (ancestorWithMostParameters != member) {
                        for (int i=member.arguments.length; i<ancestorWithMostParameters.arguments.length; i++) {
                            final Parameter other = ancestorWithMostParameters.arguments[i];
                            final Parameter p = new Parameter()
                                ..parentComponent = type
                                ..name = other.name
                                ..type = other.type
                                ..optional = true
                            ;

                            member.arguments.add(p);
                        }
                    }
                    if (member.getName() == "createCylinderEmitter") {
                        print("${member.getName()} from ${member.parentComponent.getName()}: $fewestRequiredParameters < $baseReq?");
                    }
                    if (fewestRequiredParameters < baseReq) {
                        for (int i=fewestRequiredParameters; i<baseReq; i++) {
                            member.arguments[i].optional |= true;
                        }
                    }
                }
            }
        }

        // ################################################## js object template interfaces ##################################################

        for (final InterfaceDef type in tsd.allTypes().whereType()) {
            if (type.descendants.isEmpty && type.methods.isEmpty) {
                // nothing implements this interface, and it has no methods... probably safe to make an object?
                type.isObjectTemplate = true;
            }
        }

        // ################################################## object templates for inlined objects ##################################################

        final Map<String,InlinedObjectType> inlinedObjectTypes = <String,InlinedObjectType>{};
        final Set<String> typeNames = tsd.allTypes().map((TypeDef d) => d.getName()).toSet();

        int mergeCount = 0;
        for (final ConstrainedObject obj in inlinedObjects) {
            if (obj.type == null && !obj.fields.isEmpty) {
                final InlinedObjectType type = new InlinedObjectType()
                    ..basedOn=obj
                    ..members.addAll(obj.fields)
                ;
                obj.type = type;

                if (typeNames.contains(type.getName())) {
                    type.name = "${type.name}Object";
                }

                if (inlinedObjectTypes.containsKey(type.getName())) {
                    final InlinedObjectType existing = inlinedObjectTypes[type.getName()];

                    existing.merge(type);
                    mergeCount++;

                    obj.type = existing;
                } else {
                    inlinedObjectTypes[type.getName()] = type;
                }
            }
        }

        for(final InlinedObjectType t in inlinedObjectTypes.values) {
            t.processGenerics();
        }
        print("inlined object templates: ${inlinedObjects.length}, merged $mergeCount");
        tsd.topLevelComponents.addAll(inlinedObjectTypes.values);

        // ################################################## missing concrete implementations ##################################################
        // IMPORTANT: this section MUST be last because it's lax with relations

        for (final TypeDef type in tsd.allTypes()) {
            if (type.isAbstract) { continue; } // don't care about implementing if we're abstract

            final Map<String, Member> toImplement = <String, Member>{};

            /*for (final TypeDef ancestor in type.ancestors) {
                if (!ancestor.isAbstract) {
                    continue;
                } // and we only care about implementing if the ancestor IS abstract

                //final Map<String, Member> toImplement = <String, Member>{};
                visit(ancestor, (TypeDef def) => def.ancestors, (TypeDef def) {
                    for (final Member dMember in def.members) {
                        bool found = false;
                        for (final Member member in type.members) {
                            if (dMember.getName() == member.getName()) {
                                // force implementation of setters in classes where the abstract isn't readonly
                                if (dMember is Field && member is Field) {
                                    if (!dMember.readonly) {
                                        member.readonly = false;
                                    }
                                }

                                found = true;
                                break;
                            }
                        }
                        if (!found) {
                            if (!toImplement.containsKey(dMember.getName())) {
                                toImplement[dMember.getName()] = dMember;
                            }
                        }
                    }

                    return true;
                });
            }*/

            visit(type, (TypeDef def) => def.ancestors, (TypeDef def) {

                for (final TypeRef iRef in def.implement) {
                    final TypeDef iDef = iRef.type;
                    if (!iDef.isAbstract) {
                        continue;
                    }
                    final List<Member> checkMembers = <Member>[...type.members, ...def.members];
                    for (final Member dMember in iDef.members) {
                        bool found = false;
                        for (final Member member in checkMembers) {
                            if (dMember.getName() == member.getName()) {
                                // force implementation of setters in classes where the abstract isn't readonly
                                if (dMember is Field && member is Field) {
                                    if (!dMember.readonly) {
                                        member.readonly = false;
                                    }
                                }

                                found = true;
                                break;
                            }
                        }
                        if (!found) {
                            if (!toImplement.containsKey(dMember.getName())) {
                                toImplement[dMember.getName()] = dMember;
                            }
                        }
                    }
                }

                return true;
            });

            // implement what we need to implement
            for (final Member member in toImplement.values) {
                // if the thing we need to implement *is* implemented in a concrete parent, then skip it
                bool foundInAncestorClass = false;
                for (final TypeDef ancestor in type.ancestors) {
                    if (ancestor.isAbstract) { continue; }
                    for (final Member m in ancestor.members) {
                        if (member.getName() == m.getName()) {
                            foundInAncestorClass = true;
                            break;
                        }
                    }
                }
                if (foundInAncestorClass) {
                    continue;
                }

                // if it it's implemented in an abstract ancestor, then do something about that
                if (member is Field) {
                    final Set<Member> toRemove = <Member>{};
                    for (final GetterSetter gs in type.members.whereType()) {
                        if (gs is Getter) {
                            if (gs.getName() == "${member.getName()}_getter") {
                                toRemove.add(gs);
                            }
                        } else if (gs is Setter) {
                            if (gs.getName() == "${member.getName()}_setter") {
                                toRemove.add(gs);
                            }
                        }
                    }
                    type.members.removeAll(toRemove);
                    type.members.add(member);
                } else if (member is GetterSetter) {
                    final Set<Member> toAdd = <Member>{};
                    for (final Field field in type.members.whereType()) {
                        if (field.name == member.getName().substring(0, member.getName().length-7)) {
                            // do nothing as we already have a matching field
                        } else {
                            toAdd.add(member);
                        }
                    }
                    type.members.addAll(toAdd);
                } else {
                    type.members.add(member);
                }
            }
        }
    }

    Map<String,String> write(TSDFile tsd) {
        final Map<String, String> outputs = <String,String>{};
        final List<String> importNames = <String>["promise"];

        for (final Module module in tsd.modules.values) {
            importNames.add(module.getFileName());
        }
        if (!tsd.topLevelComponents.isEmpty) {
            importNames.add(topLevelFilename);
        }
        importNames.sort();

        for (final Module module in tsd.modules.values) {
            final OutputWriter writer = new OutputWriter();
            module.writeOutput(writer, importNames);
            outputs[module.getFileName()] = writer.toString();
        }

        if (!tsd.topLevelComponents.isEmpty) {
            final OutputWriter writer = new OutputWriter();
            tsd.writeOutput(writer, importNames);
            outputs[topLevelFilename] = writer.toString();
        }

        return outputs;
    }

    void applyManualFixes(Map<String,String> data) {
        final Set<String> appliedFixes = <String>{};

        for (final String fileName in data.keys) {
            String fileContent = data[fileName];

            //int id = 0;
            for (final String fixKey in manualFixes.keys) {

                final Iterable<Match> matches = fixKey.allMatches(fileContent);

                if (!matches.isEmpty) {
                    //print("Applying fix $id ${matches.length} time${matches.length > 1 ? "s" : ""} to $fileName");

                    if (appliedFixes.contains(fixKey)) {
                        throw Exception("Fix applied twice: $fixKey");
                    }
                    final String fixValue = manualFixes[fixKey];

                    fileContent = fileContent.replaceAll(fixKey, fixValue);
                    appliedFixes.add(fixKey);
                }

                //id++;
            }

            data[fileName] = fileContent;
        }

        for (final String fixKey in manualFixes.keys) {
            if (!appliedFixes.contains(fixKey)) {
                print("Fix not applied: $fixKey");
            }
        }
    }

    /// recursive visitor function
    /// thing to visit
    /// function which returns the set of next ones to visit
    /// action to do to the visited thing - if it returns false don't continue
    static void visit<T>(T type, Iterable<T> Function(T type) getList, bool Function(T type) action) {
        if (!action(type)) { return; }
        for (final T t in getList(type)) {
            visit(t, getList, action);
        }
    }
    static final Set<List<dynamic>> inheritanceDirections = <List<dynamic>>{
        <dynamic>[(TypeDef def) => def.ancestors,   (Member def) => def.ancestors],
        <dynamic>[(TypeDef def) => def.descendants, (Member def) => def.descendants],
    };

    static void processTypeRef<T extends Member>(T type, TypeRef Function(T type) getRef) {
        TypeRef ref;
        try {
            ref = getRef(type);
        // ignore: avoid_catching_errors
        } on RangeError {
            print("error");
            return;
        }

        if (ref == null || ref.type == null) { return; }

        final Set<TypeRef> ancestorTypeRefs = <TypeRef>{};
        visit<Member>(type, (Member m) => m.ancestors, (Member member) {
            if (member == type) { return true; }
            if (!(member is T)) {
                print("${type.getName()}: ${member.getName()} is ${member.runtimeType}, not $T");
                return true; }
            try {
                ancestorTypeRefs.add(getRef(member));
            // ignore: avoid_catching_errors
            } on RangeError {
                // nothin'
            }
            return true;
        });

        if (ancestorTypeRefs.length == 1) {
            //print("${ref.type.getName()} vs ${ancestorTypeRefs.first.type.getName()}");
            if (ref.type == ancestorTypeRefs.first.type) {
                return;
            }
        }

        final Set<TypeDef> superTypes = getParentTypes(ref.type);

        for (final TypeRef aRef in ancestorTypeRefs) {
            if (aRef == null || aRef.type == null || aRef.type == StaticTypes.typeDynamic) { continue; }
            if(aRef.type == ref.type) {
                // it's the same, do nothing
            } else if (superTypes.contains(aRef.type)) {
                // ok, cool, we have this type
            } else {
                // uhoh, one of the refs isn't a supertype of the current ref
                print("dynamic fallback from ${ref.type.getName()} by ${aRef.type.getName()} in ${type.parentComponent.getName()}.${type.getName()}");
                print(superTypes.map((TypeDef d) => d.getName()).toList());
                print(ancestorTypeRefs);
                ref.type = StaticTypes.typeDynamic;
                return;
            }
        }
    }

    static Set<TypeDef> getParentTypes(TypeDef type) {
        final Set<TypeDef> superTypes = <TypeDef>{};
        visit(type, (TypeDef type) => type.ancestors, (TypeDef def) {
            if (def == type) { return true; }
            superTypes.add(def);
            return true;
        });
        return superTypes;
    }
}


