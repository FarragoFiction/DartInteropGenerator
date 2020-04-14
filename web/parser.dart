import "package:petitparser/petitparser.dart";

import "components/components.dart";
import "grammar.dart";

class TSDParser extends GrammarParser {
    TSDParser() : super(const TSDParserDefinition());
}

class TSDParserDefinition extends TSDGrammarDefinition {
    const TSDParserDefinition();

    T Function(dynamic data) process<T extends Component>(T Function() object) => (dynamic data) => object()..process(data);
    dynamic union(dynamic data) {
        if (data == null || data.length < 1) {
            return null;
        } else if (data.length == 1) {
            return data[0];
        } else {
            final TypeUnionRef ref = new TypeUnionRef();
            for (final dynamic item in data) {
                ref.unionRefs.add(item);
            }
            return ref;
        }
    }

    // reduction of text
    @override
    Parser<dynamic> DOC_COMMENT() => super.DOC_COMMENT().map((dynamic data) => new List<String>.from(data[1]));
    @override
    Parser<dynamic> identifier() => super.identifier().map((dynamic data) => data.value);

    // types
    @override
    Parser<dynamic> typeUnion() => super.typeUnion().map(union);
    @override
    Parser<dynamic> typeIntersection() => super.typeIntersection().map(union);
    @override
    Parser<dynamic> stringUnion() => super.stringUnion().map((dynamic data) {
        if (data is List<dynamic>) {
            return new TypeRef()..type=StaticTypes.typeString..notes.add(data.toString());
        } else {
            print("Invalid string union $data");
        }
    });

    @override
    Parser<dynamic> type() => super.type().map((dynamic data) {
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
    });
    @override
    Parser<dynamic> typeSingle() => super.typeSingle();
    @override
    Parser<dynamic> typeNoLambda() => super.typeNoLambda().map(union);
    @override
    Parser<dynamic> typeNoLambdaSingle() => super.typeNoLambdaSingle().map((dynamic data) {
        final TypeRef ref = new TypeRef()..name=data[0].join(".");
        //print(data);
        if (data[1] != null) {
            final List<dynamic> items = data[1][1];
            for(final dynamic item in items) {
                if (item is GenericRef) {
                    ref.generics.add(item);
                } else {
                    print("Generic non-TypeRef: $item in ${data[1][1]} -> $data");
                }
            }
        }
        ref.array = data[2].count;
        return ref;
    });
    @override
    Parser<dynamic> arrayBrackets() => super.arrayBrackets().map((dynamic data) => new ArrayBrackets());
    @override
    Parser<dynamic> arrayBracketsPlus() => super.arrayBracketsPlus().map((dynamic data) => new ArrayBrackets()..count = data.length);
    @override
    Parser<dynamic> arrayBracketsStar() => super.arrayBracketsStar().map((dynamic data) => new ArrayBrackets()..count = data.length);

    @override
    Parser<dynamic> argumentType() => super.argumentType().map(process(() => new GenericRef()));
    
    @override
    Parser<dynamic> lambda() => super.lambda().map((dynamic data) => new TypeRef()..type = StaticTypes.typeDynamic..notes.add(data.toString()) ); //TODO: give lambdas a proper output

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

    /*@override
    Parser<dynamic> typeDeclaration() => super.typeDeclaration().map((dynamic data) {
        if (data is TypeModifier) { return null; } // we don't care about these for dart maybe?
        return data;
    });*/
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
}