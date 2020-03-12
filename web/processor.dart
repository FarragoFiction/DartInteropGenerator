import "dart:io";

import "package:args/args.dart";
import "package:path/path.dart" as Path;
import "package:petitparser/petitparser.dart";

const String inputArg = "input";

Future<void> main(List<String> arguments) async {
    final ArgParser parser = new ArgParser()..addOption(inputArg, defaultsTo: "input.txt");

    final ArgResults argResults = parser.parse(arguments);

    final File inputFile = new File(Path.join(Path.dirname(Platform.script.toFilePath()), argResults[inputArg]));
    final String data = await inputFile.readAsString();

    final GrammarParser processor = new TSDGrammar();
    final Result<dynamic> result = processor.parse(data);
    print(result);
}

class TSDGrammar extends GrammarParser {
    TSDGrammar() : super(TSDGrammarDefinition());
}

class TSDGrammarDefinition extends GrammarDefinition {
    Parser<dynamic> DEFINE() => ref(token, "define");
    Parser<dynamic> DECLARE() => ref(token, "declare");
    Parser<dynamic> MODULE() => ref(token, "module");
    Parser<dynamic> EXPORT() => ref(token, "export");
    Parser<dynamic> TYPE() => ref(token, "type");
    Parser<dynamic> CLASS() => ref(token, "class");
    Parser<dynamic> CONSTRUCTOR() => ref(token, "constructor");
    Parser<dynamic> INTERFACE() => ref(token, "interface");
    Parser<dynamic> PRIVATE() => ref(token, "private");
    Parser<dynamic> PROTECTED() => ref(token, "protected");
    Parser<dynamic> READONLY() => ref(token, "readonly");
    Parser<dynamic> ABSTRACT() => ref(token, "abstract");
    Parser<dynamic> STATIC() => ref(token, "static");
    Parser<dynamic> GET() => ref(token, "get");
    Parser<dynamic> SET() => ref(token, "set");
    Parser<dynamic> IN() => ref(token, "in");
    Parser<dynamic> KEYOF() => ref(token, "keyof");
    Parser<dynamic> EXTENDS() => ref(token, "extends");
    Parser<dynamic> IMPLEMENTS() => ref(token, "implements");

    //#############################################################################

    Parser<dynamic> LETTER() => letter();
    Parser<dynamic> DIGIT() => digit();

    Parser<dynamic> NEWLINE() => pattern("\n\r");

    Parser<dynamic> WHITESPACE() => whitespace();

    Parser<dynamic> SINGLE_LINE_COMMENT() => string('//') & ref(NEWLINE).neg().star() & ref(NEWLINE).optional();
    Parser<dynamic> MULTILINE_COMMENT() => string("/*") & (ref(MULTILINE_COMMENT) | string("*/").neg()).star() & string("*/");

    Parser<dynamic> DOC_COMMENT_LINE() => string("* ").trim() & ref(token, ref(NEWLINE).neg().star().flatten());
    Parser<dynamic> DOC_COMMENT_FIRST_LINE() => string("/**").trim() & ref(token, ref(NEWLINE).neg().star().flatten()).optional();
    Parser<dynamic> MULTI_LINE_DOC_COMMENT() => ref(DOC_COMMENT_FIRST_LINE) & ref(DOC_COMMENT_LINE).star() & ref(token, "*/");
    Parser<dynamic> SINGLE_LINE_DOC_COMMENT() => ref(token, "/**") & ref(token, string("*/").neg().star().trim().flatten()) & ref(token, "*/") & ref(NEWLINE).optional();
    Parser<dynamic> DOC_COMMENT() => ref(MULTI_LINE_DOC_COMMENT) | ref(SINGLE_LINE_DOC_COMMENT);

    //#############################################################################

    Parser<dynamic> IDENTIFIER_START() => ref(IDENTIFIER_START_NO_DOLLAR) | char('\$');
    Parser<dynamic> IDENTIFIER_START_NO_DOLLAR() => ref(LETTER) | char('_');
    Parser<dynamic> IDENTIFIER_PART() => ref(IDENTIFIER_START) | ref(DIGIT);
    Parser<dynamic> IDENTIFIER() => (ref(IDENTIFIER_START) & ref(IDENTIFIER_PART).star()).flatten();

    //#############################################################################

    /// overall file structure
    Parser<dynamic> tsdFile() => ( ref(module) | ref(interfaceTopLevel) ).star();

    /// a valid single name, starting with a letter, can have numbers and underscores
    Parser<dynamic> identifier() => ref(token, ref(IDENTIFIER));

    /// a type which also allows lambdas, for arguments and return types
    Parser<dynamic> typeSingle() => ref(typeNoLambdaSingle) | (ref(token, "(") & ref(lambda) & ref(token, ")") & ref(token, "[]").optional()) | ref(lambda) | ref(constrainedObject);
    /// a type potentially surrounded by parentheses, can be a union
    Parser<dynamic> type() => ref(typeUnion);// | (ref(token, "(") & ref(typeUnion) & ref(token, ")"));
    Parser<dynamic> typeUnion() => (ref(typeSingle)).separatedBy(ref(token, "|"), includeSeparators: false);
    //Parser<dynamic> typeBracketed() => (ref(token, "(") & ref(typeSingle) & ref(token, ")")) | ref(typeSingle);
    Parser<dynamic> typeNoLambda() => (ref(typeNoLambdaSingle)).separatedBy(ref(token, "|"), includeSeparators: false) | (ref(token, "(") & ref(type) & ref(token, ")")) | ref(typeNoLambdaSingle);

    /// thing.thing.thing etc
    Parser<dynamic> qualified() => ref(identifier) & (ref(token, '.') & ref(identifier)).star();
    /// full type name with generics and array-ness
    Parser<dynamic> typeNoLambdaSingle() => ref(qualified) & ref(typeArguments).optional() & ref(token, "[]").optional();
    /// parameter with optional ? on the end
    Parser<dynamic> argumentType() => ref(type) & ref(token, "?").optional();
    /// generic type block
    Parser<dynamic> typeArguments() => ref(token, '<') & ref(typeList) & ref(token, '>');
    /// list of types for generics
    Parser<dynamic> typeNoLambdaList() => ref(typeNoLambda).separatedBy(ref(token, ","), includeSeparators: false);
    /// list of types for arguments
    Parser<dynamic> typeList() => ref(typeSingle).separatedBy(ref(token, ","), includeSeparators: false);

    /// type parameter name T etc
    Parser<dynamic> typeParameter() => ref(identifier);
    /// generic list for definitions <T extends whatever>
    Parser<dynamic> typeParameters() => ref(token, "<") & ref(typeParameter) & (ref(token, ",") & ref(typeParameter)).star() & ref(token, ">");

    /// lambda
    Parser<dynamic> lambda() => (ref(functionArguments) & ref(token, "=>") & ref(type)) | (ref(token, "(") & ref(lambda) & (ref(token, ")")) & (ref(token, "[]")));

    /// module declaration
    Parser<dynamic> module() => ref(DOC_COMMENT).optional() & ref(DECLARE) & ref(MODULE) & ref(identifier) & ref(moduleBody);
    /// module enclosure
    Parser<dynamic> moduleBody() => ref(token, "{") & ref(moduleContent).star() & ref(token, "}");
    /// things allowed to be inside a module
    Parser<dynamic> moduleContent() => ref(typeDeclaration) | ref(interface) | ref(classDeclaration);

    /// type declaration, union or otherwise
    Parser<dynamic> typeDeclaration() => ref(typeUnionDeclaration) | ref(typeThingy);
    /// a type union
    Parser<dynamic> typeUnionDeclaration() => ref(DOC_COMMENT).optional() & ref(EXPORT).optional() & ref(TYPE) & ref(typeNoLambda) & ref(token, "=") & ref(typeNoLambda).separatedBy(ref(token, "|"), includeSeparators: false) & ref(token, ";");
    /// that other weird type thing
    Parser<dynamic> typeThingy() => ref(DOC_COMMENT).optional() & ref(EXPORT).optional() & ref(TYPE) & ref(typeNoLambda) & ref(token, "=") & ref(constrainedObject) & ref(token, ";");


    /// index type query operator: keyof THING
    Parser<dynamic> indexQuery() => ref(KEYOF) & ref(constrainedObjectType);
    /// indexed access operator: T[\K]
    Parser<dynamic> indexAccess() => ref(identifier) & ref(token, "[") & ref(identifier) & ref(token, "]");

    /// object with specific field types, including index query stuff...
    Parser<dynamic> constrainedObject() =>
        ref(token, "{") &
        ref(constrainedObjectLine).star() &
        ref(token, "}");
    /// a line inside a constrained object?
    Parser<dynamic> constrainedObjectLine() =>
        ref(DOC_COMMENT).optional() &
        ref(READONLY).optional() &
        ref(token, "[") &
        ref(identifier) &
        ((ref(IN) & ref(indexQuery)) | (ref(token, ":") & ref(constrainedObjectType))) &
        ref(token, "]") &
        ref(token, ":") &
        ref(constrainedObjectType) &
        ref(token, ";");
    Parser<dynamic> constrainedObjectType() => ref(indexAccess) | (ref(qualified) & ref(constrainedObjectTypeArguments).optional() & ref(token, "[]").optional());
    Parser<dynamic> constrainedObjectTypeArguments() => ref(token, '<') & ref(constrainedObjectTypeList) & ref(token, '>');
    Parser<dynamic> constrainedObjectTypeList() => ref(constrainedObjectType).separatedBy(ref(token, ","), includeSeparators: false);

    /// interface, inside a module
    Parser<dynamic> interface() => ref(DOC_COMMENT).optional() & ref(EXPORT).optional() & ref(INTERFACE) & ref(typeNoLambda) & (ref(EXTENDS) & ref(typeNoLambda)).optional() & ref(token, "{") & ref(interfaceContent).star() & ref(token, "}");
    /// interface, top level
    Parser<dynamic> interfaceTopLevel() => ref(interface);
    /// stuff that can go inside an interface
    Parser<dynamic> interfaceContent() => ref(field) | ref(method);

    /// class, inside a module
    Parser<dynamic> classDeclaration() =>
        ref(DOC_COMMENT).optional() &
        ref(EXPORT).optional() &
        ref(ABSTRACT).optional() &
        ref(CLASS) &
        ref(typeNoLambda) &
        (ref(EXTENDS) & ref(typeNoLambda)).optional() &
        (ref(IMPLEMENTS) & ref(typeNoLambda)).optional() &
        ref(token, "{") &
        ref(classContent).star() &
        ref(constructor).optional() &
        ref(classContent).star() &
        ref(token, "}");
    /// stuff that can go inside a class
    Parser<dynamic> classContent() => ref(getter) | ref(setter) | ref(field) | ref(method);
    /// class constructor
    Parser<dynamic> constructor() => ref(DOC_COMMENT).optional() & ref(CONSTRUCTOR) & ref(functionArguments) & ref(token, ";");

    /// a single name : type argument pair
    Parser<dynamic> functionArgument() => ref(DOC_COMMENT).optional() & ref(identifier) & ref(token, "?").optional() & ref(token, ":") & ref(type);
    /// a single name : type argument pair
    Parser<dynamic> functionArgumentList() => ref(functionArgument).separatedBy(ref(token, ","), includeSeparators: false);
    /// a list of name : type pairs
    Parser<dynamic> functionArguments() => ref(token, "(") & ref(functionArgumentList).optional() & ref(token, ")");

    /// field accessor
    Parser<dynamic> accessor() => ref(PRIVATE) | ref(PROTECTED);
    /// a class field
    Parser<dynamic> field() =>
        ref(DOC_COMMENT).optional() &
        ref(accessor).optional() &
        ref(STATIC).optional() &
        ref(READONLY).optional() &
        ref(identifier) &
        ref(token, "?").optional() &
        (ref(token, ":") & (ref(type) | ref(constrainedObject))).optional() &
        ref(token, ";");
    /// a class getter method
    Parser<dynamic> getter() =>
        ref(DOC_COMMENT).optional() &
        ref(accessor).optional() &
        ref(STATIC).optional() &
        ref(GET) &
        ref(identifier) &
        ref(token, "()") &
        ref(token, ":") & ref(type) &
        ref(token, ";");
    /// a class setter method
    Parser<dynamic> setter() =>
        ref(DOC_COMMENT).optional() &
        ref(accessor).optional() &
        ref(STATIC).optional() &
        ref(SET) &
        ref(identifier) &
        ref(token, "(") &
        ref(functionArgument) &
        ref(token, ")") &
        ref(token, ";");
    /// a class method
    Parser<dynamic> method() =>
        ref(DOC_COMMENT).optional() &
        ref(accessor).optional() &
        ref(STATIC).optional() &
        ref(READONLY).optional() &
        ref(identifier) &
        ref(typeArguments).optional() &
        ref(functionArguments) &
        ref(token, ":") &
        ref(type) &
        ref(token, ";");

    //#############################################################################

    Parser<dynamic> token(Object input) {
        if (input is Parser) {
            return input.token().trim(ref(WHITESPACE));
        } else if (input is String) {
            return token(input.length == 1 ? char(input) : string(input));
        } else if (input is Function) {
            return token(ref(input));
        }
        throw ArgumentError.value(input, 'invalid token parser');
    }

    @override
    Parser<dynamic> start() => ref(method);//.end();
}