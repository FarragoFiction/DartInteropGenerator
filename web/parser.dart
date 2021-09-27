import "package:petitparser/petitparser.dart";

import "components/components.dart";
import "grammar.dart";

/*class TSDParser extends GrammarParser {
    TSDParser() : super(const TSDParserDefinition());
}*/

class TSDParserDefinition extends TSDGrammarDefinition {
    const TSDParserDefinition();

    static T printErrors<T>(T Function(dynamic data) func, dynamic data) {
        try {
            return func(data);
        // ignore: avoid_catching_errors
        } on Error {
            print(data);
            print(func);
            rethrow;
        }
    }
    dynamic Function(dynamic data) handleErrors(dynamic Function(dynamic data) func) => (dynamic data) => printErrors(func, data);

    T Function(dynamic data) process<T extends Component>(T Function() object) => (dynamic data) => printErrors((dynamic data) => object()..process(data), data);
    dynamic union(dynamic data) {
        if (data == null || data.length < 1) {
            return null;
        } else if (data.length == 1) {
            return data[0];
        } else {
            final TypeUnionRef ref = new TypeUnionRef();
            for (final dynamic item in data) {
                if (item is TypeRef) {
                    ref.unionRefs.add(item);
                    item.parentComponent = ref;
                } else {
                    print("Union invalid TypeRef: $item in $data");
                }
            }
            return ref;
        }
    }

    @override
    Parser<dynamic> tsdFile() => super.tsdFile().map(process(() => new TSDFile()));

    // reduction of text
    @override
    Parser<dynamic> DOC_COMMENT() => super.DOC_COMMENT().map((dynamic data) => new List<String>.from(data[1]));
    @override
    Parser<dynamic> identifier() => super.identifier().map((dynamic data) => (data == null || data is String) ? data : data.value);

    // types
    @override
    Parser<dynamic> typeUnion() => super.typeUnion().map(handleErrors(union));
    @override
    Parser<dynamic> typeIntersection() => super.typeIntersection().map(handleErrors(union));
    @override
    Parser<dynamic> stringUnion() => super.stringUnion().map(handleErrors((dynamic data) {
        if (data is List<dynamic>) {
            return new TypeRef()..type=StaticTypes.typeString..notes.add(data.toString());
        } else {
            print("Invalid string union $data");
        }
    }));

    @override
    Parser<dynamic> type() => super.type().map(handleErrors((dynamic data) {
        if (data == null) { return null; }
        if (data is TypeRef) {
            return data;
        } else if (data is List<dynamic> && data.length == 1) {
            return data[0];
        } else {
            if(data[1] != null && data[1] is TypeRef) {
                data[1].array = data[3].count;
            }
            return data[1];
        }
    }));
    @override
    Parser<dynamic> typeSingle() => super.typeSingle().map(handleErrors((dynamic data) {
        if (data is TypeRef) {
            return data;
        } else if (data is List<dynamic>) {
            if (data[0] is TypeRef && data[1] is ArrayBrackets) {
                return data[0]..array += data[1].count;
            }
        } else {
            print("SingleType invalid TypeRef: $data, ${data.runtimeType}");
        }
    }));
    @override
    Parser<dynamic> typeNoLambda() => super.typeNoLambda().map(handleErrors(union));
    @override
    Parser<dynamic> typeNoLambdaSingle() => super.typeNoLambdaSingle().map(handleErrors((dynamic data) {
        //print(data[0]);
        final TypeRef ref = new TypeRef()..name=data[0].join(".");
        //print(data);
        if (data[1] != null) {
            final List<dynamic> items = data[1][1];
            for(final dynamic item in items) {
                if (item is GenericRef) {
                    ref.generics.add(item);
                    item.parentComponent = ref;
                } else {
                    print("Generic non-TypeRef: $item in ${data[1][1]} -> $data");
                }
            }
        }
        ref.array = data[2].count;
        return ref;
    }));
    @override
    Parser<dynamic> arrayBrackets() => super.arrayBrackets().map(handleErrors((dynamic data) => new ArrayBrackets()..count = 1));
    @override
    Parser<dynamic> arrayBracketsPlus() => super.arrayBracketsPlus().map(handleErrors((dynamic data) => new ArrayBrackets()..count = data.length));
    @override
    Parser<dynamic> arrayBracketsStar() => super.arrayBracketsStar().map(handleErrors((dynamic data) => new ArrayBrackets()..count = data.length));

    @override
    Parser<dynamic> argumentType() => super.argumentType().map(process(() => new GenericRef()));
    @override
    Parser<dynamic> argumentArrayType() => super.argumentArrayType().map(handleErrors((dynamic data) {
        // 0 [
        // 1 list of types
        final GenericRef array = new GenericRef();
        TypeRef? arrayType;
        final List<dynamic> items = data[1];
        for (final dynamic item in items) {
            if(item is GenericRef) {
                arrayType ??= item.type;
                if (item.type?.name != arrayType?.name) {
                    arrayType = new TypeRef()..type = StaticTypes.typeDynamic;
                    break;
                }
            }
        }
        arrayType ??= new TypeRef()..type = StaticTypes.typeDynamic;
        array.type = arrayType..array = 1;
        arrayType.notes.add("Exact list: [${items.whereType<GenericRef>().map((GenericRef t) => t.getName()).join(", ")}]");
        // 2 ]
        return array;
    }));

    //@override
    //Parser<dynamic> lambda() => super.lambda().map((dynamic data) => data[1]);
    @override
    //Parser<dynamic> lambdaDef() => super.lambdaDef().map(handleErrors((dynamic data) => new LambdaRef()..notes.add(data.toString()) )); //TODO: give lambdas a proper output
    Parser<dynamic> lambdaDef() => super.lambdaDef().map(process(() => new LambdaRef()));
    @override
    Parser<dynamic> lambdaArray() => super.lambdaArray().map(handleErrors((dynamic data) {
        // 0 (
        // 1 lambda
        final TypeRef l = data[1];
        // 2 )
        // 3 brackets
        if (data[3] != null && data[3] is ArrayBrackets) {
            l.array = data[3].count;
        }
        return l;
    }));
    @override
    //Parser<dynamic> lambdaClosure() => super.lambdaClosure().map(handleErrors((dynamic data) => new LambdaRef()..notes.add("${data[1]} => ${data[3]}")));
    Parser<dynamic> lambdaClosure() => super.lambdaClosure().map(process(() => new LambdaRef()));

    // function stuff
    @override
    Parser<dynamic> functionArgument() => super.functionArgument().map(process(() => new Parameter()));

    // main objects
    @override
    Parser<dynamic> module() => super.module().map(process(() => new Module()));
    @override
    Parser<dynamic> classDeclaration() => super.classDeclaration().map(process(() => new ClassDef()));
    @override
    Parser<dynamic> interfaceDeclaration() => super.interfaceDeclaration().map(process(() => new InterfaceDef()));
    @override
    Parser<dynamic> enumDeclaration() => super.enumDeclaration().map(process(() => new Enum()));
    @override
    Parser<dynamic> constrainedObject() => super.constrainedObject().map(process(() => new ConstrainedObject()));
    @override
    Parser<dynamic> classTopLevel() => super.classTopLevel().map(handleErrors((dynamic data) => data[1]));

    @override
    Parser<dynamic> typeUnionDeclaration() => super.typeUnionDeclaration().map(process(() => new TypeUnionDef()));
    @override
    Parser<dynamic> typeThingy() => super.typeThingy().map(process(() => new TypeThingy()));
    @override
    Parser<dynamic> otherTypeThingy() => super.otherTypeThingy().map(process(() => new TypeModifier()));

    // members
    @override
    Parser<dynamic> constructor() => super.constructor().map(process(() => new Constructor()));
    @override
    Parser<dynamic> field() => super.field().map(process(() => new Field()));
    @override
    Parser<dynamic> method() => super.method().map(process(() => new Method()));
    @override
    Parser<dynamic> getter() => super.getter().map(process(() => new Getter()));
    @override
    Parser<dynamic> setter() => super.setter().map(process(() => new Setter()));
    @override
    Parser<dynamic> constant() => super.constant().map(process(() => new Variable()));
    @override
    Parser<dynamic> functionDeclaration() => super.functionDeclaration().map(process(() => new FunctionDeclaration()));
    @override
    Parser<dynamic> arrayAccess() => super.arrayAccess().map(process(() => new ArrayAccess()));
}