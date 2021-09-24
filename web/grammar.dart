import "package:petitparser/petitparser.dart";

/*class TSDGrammar extends GrammarParser {
    TSDGrammar() : super(const TSDGrammarDefinition());
}*/

class TSDGrammarDefinition extends GrammarDefinition {
    static const bool useTokens = false;
    const TSDGrammarDefinition();

    Parser<dynamic> DEFINE() => ref1(token, "define");
    Parser<dynamic> DECLARE() => ref1(token, "declare");
    Parser<dynamic> MODULE() => ref1(token, "module");
    Parser<dynamic> EXPORT() => ref1(token, "export");
    Parser<dynamic> TYPE() => ref1(token, "type");
    Parser<dynamic> CLASS() => ref1(token, "class");
    Parser<dynamic> ENUM() => ref1(token, "enum");
    Parser<dynamic> CONSTRUCTOR() => ref1(token, "constructor");
    Parser<dynamic> INTERFACE() => ref1(token, "interface");
    Parser<dynamic> PRIVATE() => ref1(token, "private");
    Parser<dynamic> PROTECTED() => ref1(token, "protected");
    Parser<dynamic> READONLY() => ref1(token, "readonly");
    Parser<dynamic> CONST() => ref1(token, "const");
    Parser<dynamic> LET() => ref1(token, "let");
    Parser<dynamic> VAR() => ref1(token, "var");
    Parser<dynamic> FUNCTION() => ref1(token, "function");
    Parser<dynamic> ABSTRACT() => ref1(token, "abstract");
    Parser<dynamic> STATIC() => ref1(token, "static");
    Parser<dynamic> GET() => ref1(token, "get");
    Parser<dynamic> SET() => ref1(token, "set");
    Parser<dynamic> IN() => ref1(token, "in");
    Parser<dynamic> KEYOF() => ref1(token, "keyof");
    Parser<dynamic> EXTENDS() => ref1(token, "extends");
    Parser<dynamic> IMPLEMENTS() => ref1(token, "implements");
    Parser<dynamic> TYPEOF() => ref1(token, "typeof");

    //#############################################################################

    Parser<dynamic> LETTER() => letter();
    Parser<dynamic> DIGIT() => digit();

    Parser<dynamic> NEWLINE() => pattern("\n\r");

    static const Map<String, String> escapeChars = <String,String>{
        '\\': '\\',
        '/': '/',
        '"': '"',
        "'": "'",
        'b': '\b',
        'f': '\f',
        'n': '\n',
        'r': '\r',
        't': '\t'
    };

    Parser<dynamic> characterPrimitiveDoubleQuote() => ref0(characterNormalDoubleQuote) | ref0(characterEscape) | ref0(characterUnicode);
    Parser<dynamic> characterNormalDoubleQuote() => pattern('^"\\');
    Parser<dynamic> characterPrimitiveSingleQuote() => ref0(characterNormalSingleQuote) | ref0(characterEscape) | ref0(characterUnicode);
    Parser<dynamic> characterNormalSingleQuote() => pattern("^'\\");
    Parser<dynamic> characterEscape() => char('\\') & pattern(escapeChars.keys.join());
    Parser<dynamic> characterUnicode() => string('\\u') & pattern('0-9A-Fa-f').times(4);
    Parser<dynamic> stringSingleQuotes() => char("'") & ref0(characterPrimitiveSingleQuote).star().flatten() & char("'");
    Parser<dynamic> stringDoubleQuotes() => char('"') & ref0(characterPrimitiveDoubleQuote).star().flatten() & char('"');
    Parser<dynamic> stringPrimitive() => ref0(stringDoubleQuotes) | ref0(stringSingleQuotes);

    Parser<dynamic> WHITESPACE() => whitespace();

    Parser<dynamic> SINGLE_LINE_COMMENT() => string('//') & ref0(NEWLINE).neg().starLazy(ref0(NEWLINE)) & ref0(NEWLINE).optional();
    Parser<dynamic> MULTILINE_COMMENT() => string("/*") & (ref0(MULTILINE_COMMENT) | string("*/").neg()).star() & string("*/");

    Parser<dynamic> DOC_COMMENT() =>
        ref1(token, "/**") &
        any().starLazy(ref1(token, "*/")).flatten().map((String input) {
            return input.split(NEWLINE().toPattern()).where((String s) => !s.isEmpty).map((String line) {
                String trimmed = line.trim();
                if (trimmed.startsWith("*")) {
                    trimmed = trimmed.substring(1).trim();
                }
                return trimmed;
            }).toList();
        }) &
        ref1(token, "*/");

    //#############################################################################

    Parser<dynamic> IDENTIFIER_START() => ref0(IDENTIFIER_START_NO_DOLLAR) | char('\$');
    Parser<dynamic> IDENTIFIER_START_NO_DOLLAR() => ref0(LETTER) | char('_');
    Parser<dynamic> IDENTIFIER_PART() => ref0(IDENTIFIER_START) | ref0(DIGIT);
    Parser<dynamic> IDENTIFIER() => (ref0(IDENTIFIER_START) & ref0(IDENTIFIER_PART).star()).flatten();

    Parser<dynamic> ARRAY_BRACKETS() => ref1(token, "[") & ref0(identifier).optional() & ref1(token, "]");

    //#############################################################################

    /// overall file structure
    Parser<dynamic> tsdFile() => ( ref0(module) | ref0(interfaceTopLevel) | ref0(constant) | ref0(typeDeclaration) | ref0(classTopLevel) | ref0(enumDeclaration) ).star();

    /// a valid single name, starting with a letter, can have numbers and underscores
    Parser<dynamic> identifier() => ref1(token, ref0(IDENTIFIER));

    /// a type which also allows lambdas, for arguments and return types
    Parser<dynamic> typeSingle() => ref0(typeNoLambdaSingle) |  ref0(lambda) | (ref0(constrainedObject) & ref0(arrayBracketsStar));
    //(ref1(token, "(") & ref0(lambda) & ref1(token, ")") & ref0(arrayBracketsStar)) |
    /// a type, which might be a union
    Parser<dynamic> type() => ref0(typeUnion) | (ref1(token, "(") & ref0(typeUnion) & ref1(token, ")") & ref0(arrayBracketsPlus));
    Parser<dynamic> typeUnion() => ref0(typeIntersection).separatedBy(ref1(token, "|"), includeSeparators: false);
    Parser<dynamic> typeNoLambda() => (ref0(typeNoLambdaSingle)).separatedBy(ref1(token, "|"), includeSeparators: false) | (ref1(token, "(") & ref0(type) & ref1(token, ")")) | ref0(typeNoLambdaSingle);
    Parser<dynamic> typeIntersection() => (ref0(typeSingle)).separatedBy(ref1(token, "&"), includeSeparators: false);

    /// a set of different string options...
    Parser<dynamic> stringUnion() => ref0(stringPrimitive).separatedBy(ref1(token,"|"), includeSeparators: false);
    /// at least one set of array brackets
    Parser<dynamic> arrayBracketsPlus() => ref0(ARRAY_BRACKETS).plus();
    /// any number of array brackets
    Parser<dynamic> arrayBracketsStar() => ref0(ARRAY_BRACKETS).star();
    /// exactly one set of array brackets
    Parser<dynamic> arrayBrackets() => ref0(ARRAY_BRACKETS);

    /// thing.thing.thing etc
    Parser<dynamic> qualified() => ref0(identifier).separatedBy(ref1(token, "."), includeSeparators: false); //ref0(identifier) & (ref1(token, '.') & ref0(identifier)).star();
    /// full type name with generics and array-ness
    Parser<dynamic> typeNoLambdaSingle() => ref0(qualified) & ref0(typeArguments).optional() & ref0(arrayBracketsStar);
    /// parameter with optional ? on the end
    Parser<dynamic> argumentType() => ref0(type) & ref1(token, "?").optional() & ((ref0(EXTENDS) | ref1(token, "=")) & ref0(KEYOF).optional() & ref0(type)).optional();
    /// parameter list for type arguments
    Parser<dynamic> argumentTypeList() => argumentType().separatedBy(ref1(token, ","), includeSeparators: false);
    /// generic type block
    Parser<dynamic> typeArguments() => ref1(token, '<') & ref0(argumentTypeList) & ref1(token, '>');

    /// type parameter name T etc
    Parser<dynamic> typeParameter() => ref0(identifier);
    /// generic list for definitions <T extends whatever>
    Parser<dynamic> typeParameters() => ref1(token, "<") & ref0(typeParameter) & (ref1(token, ",") & ref0(typeParameter)).star() & ref1(token, ">");

    /// lambda
    Parser<dynamic> lambda() =>  lambdaArray() | lambdaDef() | lambdaClosure();
    Parser<dynamic> lambdaDef() => ref0(functionArguments) & ref1(token, "=>") & ref0(type);
    Parser<dynamic> lambdaArray() => ref1(token, "(") & ref0(lambdaDef) & ref1(token, ")") & ref0(arrayBracketsStar);
    Parser<dynamic> lambdaClosure() => (ref1(token, "{") & ref0(functionArguments) & ref1(token, ":") & ref0(type) & ref1(token, ";") & ref1(token, "}"));

    /// module declaration
    Parser<dynamic> module() => ref0(DOC_COMMENT).optional() & ref0(DECLARE) & ref0(MODULE) & ref0(qualified) & ref0(moduleBody);
    /// module enclosure
    Parser<dynamic> moduleBody() => ref1(token, "{") & ref0(moduleContent).star() & ref1(token, "}");
    /// things allowed to be inside a module
    Parser<dynamic> moduleContent() => ref0(typeDeclaration) | ref0(interfaceDeclaration) | ref0(classDeclaration) | ref0(constant) | ref0(functionDeclaration) | ref0(enumDeclaration);

    /// consts in modules
    Parser<dynamic> constant() =>
        ref0(DOC_COMMENT).optional() &
        (ref0(EXPORT) | ref0(DECLARE)).optional() &
        (ref0(CONST) | ref0(LET) | ref0(VAR)) &
        ref0(identifier) &
        ((ref1(token, ":") & ref0(type)) | (ref1(token, "=") & ref1(token, any()).starLazy(char(";")))) &
        ref1(token, ";");
    /// functions in modules
    Parser<dynamic> functionDeclaration() =>
        ref0(DOC_COMMENT).optional() &
        ref0(EXPORT).optional() &
        ref0(FUNCTION) &
        ref0(identifier) &
        ref0(typeArguments).optional() &
        ref0(functionArguments) &
        ref1(token, ":") &
        ref0(type) &
        ref1(token, ";");

    /// type declaration, union or otherwise
    Parser<dynamic> typeDeclaration() => ref0(typeUnionDeclaration) | ref0(typeThingy) | ref0(otherTypeThingy);
    /// a type union
    Parser<dynamic> typeUnionDeclaration() =>
        ref0(DOC_COMMENT).optional() &
        ref0(EXPORT).optional() &
        ref0(TYPE) &
        ref0(typeNoLambda) &
        ref1(token, "=") &
        ref1(token,"|").optional() &
        //(ref0(type) | ref0(stringPrimitive)).separatedBy(ref1(token, "|"), includeSeparators: false) &
        (ref0(typeUnion) | ref0(stringUnion)) &
        ref1(token, ";");
    /// that other weird type thing
    Parser<dynamic> typeThingy() =>
        ref0(DOC_COMMENT).optional() &
        ref0(EXPORT).optional() &
        ref0(TYPE) &
        ref0(typeNoLambda) &
        ref1(token, "=") &
        ref0(constrainedObject) &
        ref1(token, ";");
    /// some kind of type modifier... we really don't care about these for dart so I guess we can just kinda... dispose of them?
    Parser<dynamic> otherTypeThingy() =>
        ref0(DOC_COMMENT).optional() &
        ref0(EXPORT).optional() &
        ref0(TYPE) &
        ref0(typeNoLambda) &
        ref1(token, "=") &
        ref1(token, char(";").neg().starLazy(char(";")).flatten()) &
        ref1(token, ";");


    /// index type query operator: keyof THING
    Parser<dynamic> indexQuery() => ref0(KEYOF) & ref0(constrainedObjectType);
    /// indexed access operator: T[\K]
    Parser<dynamic> indexAccess() => ref0(identifier) & ref1(token, "[") & ref0(identifier) & ref1(token, "]");

    /// array access?
    Parser<dynamic> arrayAccess() =>
        ref0(DOC_COMMENT).optional() &
        ref0(READONLY).optional() &
        ref1(token, "[") &
        ref0(identifier) &
        ref1(token, ":") &
        ref0(constrainedObjectType) &
        ref1(token, "]") &
        ref1(token, ":") &
        ref0(constrainedObjectType) &
        ref1(token, ";");

    /// object with specific field types, including index query stuff...
    Parser<dynamic> constrainedObject() =>
        ref1(token, "{") &
        (ref0(arrayAccess) | ref0(field) | ref0(method) | ref0(constrainedObjectLine) | ref0(objectKeyDefinition)).star() &
        ref1(token, "}");
    /// a line inside a constrained object?
    Parser<dynamic> constrainedObjectLine() =>
        ref0(DOC_COMMENT).optional() &
        ref0(READONLY).optional() &
        ((ref1(token, "[") &
        ref0(identifier) &
        ((ref0(IN) & ref0(indexQuery)) | (ref1(token, ":") & ref0(constrainedObjectType))) &
        ref1(token, "]")) |
        ref0(identifier)) &
        ref1(token, ":") &
        ref0(constrainedObjectType) &
        ref1(token, ";");
    Parser<dynamic> constrainedObjectType() => ref0(constrainedObjectTypeSingle).separatedBy(ref1(token, "|"), includeSeparators: false);
    Parser<dynamic> constrainedObjectTypeSingle() => ref0(indexAccess) | (ref0(qualified) & ref0(constrainedObjectTypeArguments).optional() & ref1(token, "[]").optional()) | ref0(constrainedObject);
    Parser<dynamic> constrainedObjectTypeArguments() => ref1(token, '<') & ref0(constrainedObjectTypeList) & ref1(token, '>');
    Parser<dynamic> constrainedObjectTypeList() => ref0(constrainedObjectType).separatedBy(ref1(token, ","), includeSeparators: false);
    Parser<dynamic> objectKeyDefinition() => ref0(stringPrimitive) & ref1(token, ":") & (ref0(type) | ref0(arrayBrackets)) & ref1(token, ";");

    /// interface, inside a module
    Parser<dynamic> interfaceDeclaration() =>
        ref0(DOC_COMMENT).optional() &
        ref0(EXPORT).optional() &
        ref0(INTERFACE) &
        ref0(typeNoLambda) &
        (ref0(EXTENDS) & ref0(typeNoLambda)).optional() &
        ref1(token, "{") &
        ref0(interfaceContent).star() &
        ref1(token, "}");
    /// interface, top level
    Parser<dynamic> interfaceTopLevel() => ref0(interfaceDeclaration);
    /// stuff that can go inside an interface
    Parser<dynamic> interfaceContent() => ref0(field) | ref0(method) | ref0(arrayAccess);

    /// class, inside a module
    Parser<dynamic> classDeclaration() =>
        ref0(DOC_COMMENT).optional() &
        ref0(EXPORT).optional() &
        ref0(ABSTRACT).optional() &
        ref0(CLASS) &
        ref0(typeNoLambda) &
        (ref0(EXTENDS) & ref0(typeNoLambda)).optional() &
        (ref0(IMPLEMENTS) & ref0(typeNoLambda).separatedBy(ref1(token,","), includeSeparators: false)).optional() &
        ref1(token, "{") &
        ref0(classContent).star() &
        ref1(token, "}");
    /// stuff that can go inside a class
    Parser<dynamic> classContent() => ref0(constructor) | ref0(field) | ref0(method) | ref0(getter) | ref0(setter) | ref0(arrayAccess) | ref0(DOC_COMMENT); // make sure comment goes last
    /// class constructor
    Parser<dynamic> constructor() => ref0(DOC_COMMENT).optional() & ref0(PRIVATE).optional() & ref0(CONSTRUCTOR) & ref0(functionArguments) & ref1(token, ";");

    /// a single name : type argument pair
    Parser<dynamic> functionArgument() => ref0(DOC_COMMENT).optional() & ((ref0(identifier) & ref1(token, "?").optional()) | ref1(token, "...args")) & ref1(token, ":") & ref1(token, "new").optional() & (ref0(type) | ref0(stringPrimitive));
    /// a single name : type argument pair
    Parser<dynamic> functionArgumentList() => ref0(functionArgument).separatedBy(ref1(token, ","), includeSeparators: false);
    /// a list of name : type pairs
    Parser<dynamic> functionArguments() => ref1(token, "(") & ref0(functionArgumentList).optional() & ref1(token, ")");

    /// field accessor
    Parser<dynamic> accessor() => ref0(PRIVATE) | ref0(PROTECTED);
    /// a class field
    Parser<dynamic> field() =>
        ref0(DOC_COMMENT).optional() &
        ref0(accessor).optional() &
        ref0(ABSTRACT).optional() &
        ref0(STATIC).optional() &
        ref0(READONLY).optional() &
        ref1(token, '"').optional() &
        ref0(identifier) &
        ref1(token, '"').optional() &
        ref1(token, "?").optional() &
        (((ref1(token, ":") & ((ref0(TYPEOF) & ref0(qualified)) | ref0(type) | ref0(stringUnion) | ref0(constrainedObject) | ref0(arrayBrackets))) & ref1(token, ";").optional())
        | ref1(token, ";"));
    /// a class getter method
    Parser<dynamic> getter() =>
        ref0(DOC_COMMENT).optional() &
        ref0(accessor).optional() &
        ref0(ABSTRACT).optional() &
        ref0(STATIC).optional() &
        ref0(GET) &
        ref0(identifier) &
        ref1(token, "()") &
        (ref1(token, ":") & ref0(type)).optional() &
        ref1(token, ";");
    /// a class setter method
    Parser<dynamic> setter() =>
        ref0(DOC_COMMENT).optional() &
        ref0(accessor).optional() &
        ref0(ABSTRACT).optional() &
        ref0(STATIC).optional() &
        ref0(SET) &
        ref0(identifier) &
        ref1(token, "(") &
        ref0(functionArgument) &
        ref1(token, ")") &
        ref1(token, ";");
    /// a class method
    Parser<dynamic> method() =>
        ref0(DOC_COMMENT).optional() &
        ref0(accessor).optional() &
        ref0(ABSTRACT).optional() &
        ref0(STATIC).optional() &
        ref0(READONLY).optional() &
        ref0(identifier) &
        ref1(token, "?").optional() &
        ref0(typeArguments).optional() &
        ref0(functionArguments) &
        ref1(token, ":") &
        ref0(type) &
        ref1(token, ";");

    /// enumeration
    Parser<dynamic> enumDeclaration() =>
        ref0(DOC_COMMENT).optional() &
        (ref0(EXPORT) | ref0(DECLARE)).optional() &
        ref0(CONST).optional() &
        ref0(ENUM) &
        ref0(identifier) &
        ref1(token, "{") &
        ref0(enumValue).plus() &
        ref1(token, "}");
    /// entries in an enum
    Parser<dynamic> enumValue() =>
        ref0(DOC_COMMENT).optional() &
        ref1(token, '"').optional() &
        ref0(identifier) &
        ref1(token, '"').optional() &
        (
            ref1(token, "=") &
            ( ref0(stringPrimitive) | ref0(DIGIT).plus().flatten().map(int.parse) )
        ).optional() &
        ref1(token, ",").optional();

    /// top level class declaration
    Parser<dynamic> classTopLevel() => ref0(DECLARE) & ref0(classDeclaration);

    //#############################################################################

    Parser<dynamic> token(Object input) {
        if (input is Parser) {
            if (useTokens) {
                return input.token().trim(ref0(WHITESPACE));
            } else {
                return input.trim(ref0(WHITESPACE));
            }
        } else if (input is String) {
            //return token(input.length == 1 ? char(input) : string(input));
            return token(input.toParser());
        } else if (input is Function) {
            return token(ref(input));
        }
        throw ArgumentError.value(input, 'invalid token parser');
    }

    @override
    Parser<dynamic> start() => ref0(tsdFile).end();
}