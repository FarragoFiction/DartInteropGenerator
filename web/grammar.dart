import "package:petitparser/petitparser.dart";

class TSDGrammar extends GrammarParser {
    TSDGrammar() : super(const TSDGrammarDefinition());
}

class TSDGrammarDefinition extends GrammarDefinition {
    const TSDGrammarDefinition();

    Parser<dynamic> DEFINE() => ref(token, "define");
    Parser<dynamic> DECLARE() => ref(token, "declare");
    Parser<dynamic> MODULE() => ref(token, "module");
    Parser<dynamic> EXPORT() => ref(token, "export");
    Parser<dynamic> TYPE() => ref(token, "type");
    Parser<dynamic> CLASS() => ref(token, "class");
    Parser<dynamic> ENUM() => ref(token, "enum");
    Parser<dynamic> CONSTRUCTOR() => ref(token, "constructor");
    Parser<dynamic> INTERFACE() => ref(token, "interface");
    Parser<dynamic> PRIVATE() => ref(token, "private");
    Parser<dynamic> PROTECTED() => ref(token, "protected");
    Parser<dynamic> READONLY() => ref(token, "readonly");
    Parser<dynamic> CONST() => ref(token, "const");
    Parser<dynamic> LET() => ref(token, "let");
    Parser<dynamic> VAR() => ref(token, "var");
    Parser<dynamic> FUNCTION() => ref(token, "function");
    Parser<dynamic> ABSTRACT() => ref(token, "abstract");
    Parser<dynamic> STATIC() => ref(token, "static");
    Parser<dynamic> GET() => ref(token, "get");
    Parser<dynamic> SET() => ref(token, "set");
    Parser<dynamic> IN() => ref(token, "in");
    Parser<dynamic> KEYOF() => ref(token, "keyof");
    Parser<dynamic> EXTENDS() => ref(token, "extends");
    Parser<dynamic> IMPLEMENTS() => ref(token, "implements");
    Parser<dynamic> TYPEOF() => ref(token, "typeof");

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

    Parser<dynamic> characterPrimitiveDoubleQuote() => ref(characterNormalDoubleQuote) | ref(characterEscape) | ref(characterUnicode);
    Parser<dynamic> characterNormalDoubleQuote() => pattern('^"\\');
    Parser<dynamic> characterPrimitiveSingleQuote() => ref(characterNormalSingleQuote) | ref(characterEscape) | ref(characterUnicode);
    Parser<dynamic> characterNormalSingleQuote() => pattern("^'\\");
    Parser<dynamic> characterEscape() => char('\\') & pattern(escapeChars.keys.join());
    Parser<dynamic> characterUnicode() => string('\\u') & pattern('0-9A-Fa-f').times(4);
    Parser<dynamic> stringSingleQuotes() => char("'") & ref(characterPrimitiveSingleQuote).star().flatten() & char("'");
    Parser<dynamic> stringDoubleQuotes() => char('"') & ref(characterPrimitiveDoubleQuote).star().flatten() & char('"');
    Parser<dynamic> stringPrimitive() => ref(stringDoubleQuotes) | ref(stringSingleQuotes);

    Parser<dynamic> WHITESPACE() => whitespace();

    Parser<dynamic> SINGLE_LINE_COMMENT() => string('//') & ref(NEWLINE).neg().starLazy(ref(NEWLINE)) & ref(NEWLINE).optional();
    Parser<dynamic> MULTILINE_COMMENT() => string("/*") & (ref(MULTILINE_COMMENT) | string("*/").neg()).star() & string("*/");

    Parser<dynamic> DOC_COMMENT() =>
        ref(token, "/**") &
        any().starLazy(ref(token, "*/")).flatten().map((String input) {
            return input.split(NEWLINE()).where((String s) => !s.isEmpty).map((String line) {
                String trimmed = line.trim();
                if (trimmed.startsWith("*")) {
                    trimmed = trimmed.substring(1).trim();
                }
                return trimmed;
            }).toList();
        }) &
        ref(token, "*/");

    //#############################################################################

    Parser<dynamic> IDENTIFIER_START() => ref(IDENTIFIER_START_NO_DOLLAR) | char('\$');
    Parser<dynamic> IDENTIFIER_START_NO_DOLLAR() => ref(LETTER) | char('_');
    Parser<dynamic> IDENTIFIER_PART() => ref(IDENTIFIER_START) | ref(DIGIT);
    Parser<dynamic> IDENTIFIER() => (ref(IDENTIFIER_START) & ref(IDENTIFIER_PART).star()).flatten();

    Parser<dynamic> ARRAY_BRACKETS() => ref(token, "[") & ref(identifier).optional() & ref(token, "]");

    //#############################################################################

    /// overall file structure
    Parser<dynamic> tsdFile() => ( ref(module) | ref(interfaceTopLevel) | ref(variableDeclaration) | ref(typeDeclaration) | ref(classTopLevel) ).star();

    /// a valid single name, starting with a letter, can have numbers and underscores
    Parser<dynamic> identifier() => ref(token, ref(IDENTIFIER));

    /// a type which also allows lambdas, for arguments and return types
    Parser<dynamic> typeSingle() => ref(typeNoLambdaSingle) | (ref(token, "(") & ref(lambda) & ref(token, ")") & ref(ARRAY_BRACKETS).star()) | ref(lambda) | (ref(constrainedObject) & ref(ARRAY_BRACKETS).star());
    /// a type, which might be a union
    Parser<dynamic> type() => ref(typeUnion) | (ref(token, "(") & ref(typeUnion) & ref(token, ")") & ref(ARRAY_BRACKETS));
    Parser<dynamic> typeUnion() => ref(typeIntersection).separatedBy(ref(token, "|"), includeSeparators: false);
    Parser<dynamic> typeNoLambda() => (ref(typeNoLambdaSingle)).separatedBy(ref(token, "|"), includeSeparators: false) | (ref(token, "(") & ref(type) & ref(token, ")")) | ref(typeNoLambdaSingle);
    Parser<dynamic> typeIntersection() => (ref(typeSingle)).separatedBy(ref(token, "&"), includeSeparators: false);

    /// a set of different string options...
    Parser<dynamic> stringUnion() => ref(stringPrimitive).separatedBy(ref(token,"|"), includeSeparators: false);

    /// thing.thing.thing etc
    Parser<dynamic> qualified() => ref(identifier).separatedBy(ref(token, "."), includeSeparators: false); //ref(identifier) & (ref(token, '.') & ref(identifier)).star();
    /// full type name with generics and array-ness
    Parser<dynamic> typeNoLambdaSingle() => ref(qualified) & ref(typeArguments).optional() & ref(ARRAY_BRACKETS).star();
    /// parameter with optional ? on the end
    Parser<dynamic> argumentType() => ref(type) & ref(token, "?").optional() & (ref(EXTENDS) & ref(KEYOF).optional() & ref(type)).optional();
    /// parameter list for type arguments
    Parser<dynamic> argumentTypeList() => argumentType().separatedBy(ref(token, ","), includeSeparators: false);
    /// generic type block
    Parser<dynamic> typeArguments() => ref(token, '<') & ref(argumentTypeList) & ref(token, '>');

    /// type parameter name T etc
    Parser<dynamic> typeParameter() => ref(identifier);
    /// generic list for definitions <T extends whatever>
    Parser<dynamic> typeParameters() => ref(token, "<") & ref(typeParameter) & (ref(token, ",") & ref(typeParameter)).star() & ref(token, ">");

    /// lambda
    Parser<dynamic> lambda() => (ref(functionArguments) & ref(token, "=>") & ref(type)) | (ref(token, "(") & ref(lambda) & (ref(token, ")")) & (ref(ARRAY_BRACKETS))) | (ref(token, "{") & ref(functionArguments) & ref(token, ":") & ref(type) & ref(token, ";") & ref(token, "}"));

    /// module declaration
    Parser<dynamic> module() => ref(DOC_COMMENT).optional() & ref(DECLARE) & ref(MODULE) & ref(qualified) & ref(moduleBody);
    /// module enclosure
    Parser<dynamic> moduleBody() => ref(token, "{") & ref(moduleContent).star() & ref(token, "}");
    /// things allowed to be inside a module
    Parser<dynamic> moduleContent() => ref(typeDeclaration) | ref(interfaceDeclaration) | ref(classDeclaration) | ref(constant) | ref(functionDeclaration) | ref(enumDeclaration);

    /// consts in modules
    Parser<dynamic> constant() =>
        ref(DOC_COMMENT).optional() &
        ref(EXPORT).optional() &
        (ref(CONST) | ref(LET) | ref(VAR)) &
        ref(identifier) &
        ((ref(token, ":") & ref(type)) | (ref(token, "=") & ref(token, any()).starLazy(char(";")))) &
        ref(token, ";");
    /// functions in modules
    Parser<dynamic> functionDeclaration() =>
        ref(DOC_COMMENT).optional() &
        ref(EXPORT).optional() &
        ref(FUNCTION) &
        ref(identifier) &
        ref(typeArguments).optional() &
        ref(functionArguments) &
        ref(token, ":") &
        ref(type) &
        ref(token, ";");

    /// type declaration, union or otherwise
    Parser<dynamic> typeDeclaration() => ref(typeUnionDeclaration) | ref(typeThingy) | ref(otherTypeThingy);
    /// a type union
    Parser<dynamic> typeUnionDeclaration() =>
        ref(DOC_COMMENT).optional() &
        ref(EXPORT).optional() &
        ref(TYPE) &
        ref(typeNoLambda) &
        ref(token, "=") &
        ref(token,"|").optional() &
        (ref(type) | ref(stringPrimitive)).separatedBy(ref(token, "|"), includeSeparators: false) &
        ref(token, ";");
    /// that other weird type thing
    Parser<dynamic> typeThingy() =>
        ref(DOC_COMMENT).optional() &
        ref(EXPORT).optional() &
        ref(TYPE) &
        ref(typeNoLambda) &
        ref(token, "=") &
        ref(constrainedObject) &
        ref(token, ";");
    /// some kind of type modifier... we really don't care about these for dart so I guess we can just kinda... dispose of them?
    Parser<dynamic> otherTypeThingy() =>
        ref(DOC_COMMENT).optional() &
        ref(EXPORT).optional() &
        ref(TYPE) &
        ref(typeNoLambda) &
        ref(token, "=") &
        ref(token, char(";").neg().starLazy(char(";")).flatten()) &
        ref(token, ";");


    /// index type query operator: keyof THING
    Parser<dynamic> indexQuery() => ref(KEYOF) & ref(constrainedObjectType);
    /// indexed access operator: T[\K]
    Parser<dynamic> indexAccess() => ref(identifier) & ref(token, "[") & ref(identifier) & ref(token, "]");

    /// object with specific field types, including index query stuff...
    Parser<dynamic> constrainedObject() =>
        ref(token, "{") &
        (ref(constrainedObjectLine) | ref(objectKeyDefinition)| ref(field) | ref(method) ).star() &
        ref(token, "}");
    /// a line inside a constrained object?
    Parser<dynamic> constrainedObjectLine() =>
        ref(DOC_COMMENT).optional() &
        ref(READONLY).optional() &
        ((ref(token, "[") &
        ref(identifier) &
        ((ref(IN) & ref(indexQuery)) | (ref(token, ":") & ref(constrainedObjectType))) &
        ref(token, "]")) |
        ref(identifier)) &
        ref(token, ":") &
        ref(constrainedObjectType) &
        ref(token, ";");
    Parser<dynamic> constrainedObjectType() => ref(constrainedObjectTypeSingle).separatedBy(ref(token, "|"), includeSeparators: false);
    Parser<dynamic> constrainedObjectTypeSingle() => ref(indexAccess) | (ref(qualified) & ref(constrainedObjectTypeArguments).optional() & ref(token, "[]").optional()) | ref(constrainedObject);
    Parser<dynamic> constrainedObjectTypeArguments() => ref(token, '<') & ref(constrainedObjectTypeList) & ref(token, '>');
    Parser<dynamic> constrainedObjectTypeList() => ref(constrainedObjectType).separatedBy(ref(token, ","), includeSeparators: false);
    Parser<dynamic> objectKeyDefinition() => ref(stringPrimitive) & ref(token, ":") & (ref(type) | ref(ARRAY_BRACKETS)) & ref(token, ";");

    /// interface, inside a module
    Parser<dynamic> interfaceDeclaration() =>
        ref(DOC_COMMENT).optional() &
        ref(EXPORT).optional() &
        ref(INTERFACE) &
        ref(typeNoLambda) &
        (ref(EXTENDS) & ref(typeNoLambda)).optional() &
        ref(token, "{") &
        ref(interfaceContent).star() &
        ref(token, "}");
    /// interface, top level
    Parser<dynamic> interfaceTopLevel() => ref(interfaceDeclaration);
    /// stuff that can go inside an interface
    Parser<dynamic> interfaceContent() => ref(field) | ref(method) | ref(constrainedObjectLine);

    /// class, inside a module
    Parser<dynamic> classDeclaration() =>
        ref(DOC_COMMENT).optional() &
        ref(EXPORT).optional() &
        ref(ABSTRACT).optional() &
        ref(CLASS) &
        ref(typeNoLambda) &
        (ref(EXTENDS) & ref(typeNoLambda)).optional() &
        (ref(IMPLEMENTS) & ref(typeNoLambda).separatedBy(ref(token,","), includeSeparators: false)).optional() &
        ref(token, "{") &
        ref(classContent).star() &
        ref(constructor).optional() &
        ref(classContent).star() &
        ref(token, "}");
    /// stuff that can go inside a class
    Parser<dynamic> classContent() => ref(getter) | ref(setter) | ref(field) | ref(method) | ref(constrainedObjectLine) | ref(DOC_COMMENT); // make sure comment goes last
    /// class constructor
    Parser<dynamic> constructor() => ref(DOC_COMMENT).optional() & ref(PRIVATE).optional() & ref(CONSTRUCTOR) & ref(functionArguments) & ref(token, ";");

    /// a single name : type argument pair
    Parser<dynamic> functionArgument() => ref(DOC_COMMENT).optional() & ((ref(identifier) & ref(token, "?").optional()) | ref(token, "...args")) & ref(token, ":") & (ref(type) | ref(stringPrimitive));
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
        ref(ABSTRACT).optional() &
        ref(STATIC).optional() &
        ref(READONLY).optional() &
        ref(identifier) &
        ref(token, "?").optional() &
        (((ref(token, ":") & ((ref(TYPEOF) & ref(qualified)) | ref(type) | ref(stringUnion) | ref(constrainedObject) | ref(ARRAY_BRACKETS))) & ref(token, ";").optional())
        | ref(token, ";"));
    /// a class getter method
    Parser<dynamic> getter() =>
        ref(DOC_COMMENT).optional() &
        ref(accessor).optional() &
        ref(ABSTRACT).optional() &
        ref(STATIC).optional() &
        ref(GET) &
        ref(identifier) &
        ref(token, "()") &
        (ref(token, ":") & ref(type)).optional() &
        ref(token, ";");
    /// a class setter method
    Parser<dynamic> setter() =>
        ref(DOC_COMMENT).optional() &
        ref(accessor).optional() &
        ref(ABSTRACT).optional() &
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
        ref(ABSTRACT).optional() &
        ref(STATIC).optional() &
        ref(READONLY).optional() &
        ref(identifier) &
        ref(token, "?").optional() &
        ref(typeArguments).optional() &
        ref(functionArguments) &
        ref(token, ":") &
        ref(type) &
        ref(token, ";");

    /// enumeration
    Parser<dynamic> enumDeclaration() =>
        ref(DOC_COMMENT).optional() &
        ref(EXPORT).optional() &
        ref(ENUM) &
        ref(identifier) &
        ref(token, "{") &
        ref(enumValue).plus() &
        ref(token, "}");
    /// entries in an enum
    Parser<dynamic> enumValue() =>
        ref(DOC_COMMENT).optional() &
        ref(identifier) &
        ref(token, "=") &
        ref(token, any()).starLazy(char(",") | char("}")) &
        ref(token, ",").optional();

    /// top level variable declaration
    Parser<dynamic> variableDeclaration() =>
        ref(DOC_COMMENT).optional() &
        ref(DECLARE) &
        ref(VAR) &
        ref(identifier) &
        ref(token, ":") &
        (ref(constrainedObject)) &
        ref(token, ";");

    /// top level class declaration
    Parser<dynamic> classTopLevel() => ref(DECLARE) & ref(classDeclaration);

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
    Parser<dynamic> start() => ref(tsdFile).end();
}