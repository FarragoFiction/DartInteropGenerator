
import "components.dart";

class FunctionDeclaration extends Component with HasGenerics {
    //final Set<GenericRef> generics = <GenericRef>{};
    final Set<Parameter> arguments = <Parameter>{};
    TypeRef type;

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 export
        // 2 function
        // 3 name
        this.name = input[3];
        // 4 type arguments
        if (input[4] != null) {
            for (final dynamic item in input[4][1]) {
                if (item is GenericRef) {
                    this.generics.add(item);
                } else {
                    print("Function non-generic $item in ${input[4]} -> $input");
                }
            }
        }
        // 5 function arguments
        if (input[5][1] != null) {
            for (final dynamic item in input[5][1]) {
                if (item is Parameter) {
                    this.arguments.add(item);
                } else {
                    print("Function non-parameter $item in ${input[5][1]} -> $input");
                }
            }
        }
        // 6 :
        // 7 return type
        if (input[7] is TypeRef) {
            this.type = input[7];
        } else if (input[7] is ArrayBrackets) {
            this.type = input[7].toType();
        } else {
            print("Method non-type returned: ${input[7]} in $input");
        }
        // 8 semicolon
    }

    @override
    void getTypeRefs(Set<TypeRef> references) {
        for (final GenericRef ref in generics) {
            ref.processTypeRefs(references);
        }
        for (final Parameter ref in arguments) {
            ref.processTypeRefs(references);
        }
        this.type?.processTypeRefs(references);
    }

    @override
    String displayString() => "${super.displayString()}${generics.isEmpty ? "" : "<${generics.join(",")}>"}: $arguments -> $type";
}

class Parameter extends Component {
    TypeRef type;

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 name
        if (input[1] is List<dynamic>) {
            // name and optional
            this.name = input[1][0];
        } else {
            // args
        }
        // 2 colon
        // 3 type
        if (input[3] is TypeRef) {
            this.type = input[3];
        } else {
            // a string...
        }
    }

    @override
    void getTypeRefs(Set<TypeRef> references) { this.type?.processTypeRefs(references); }

    @override
    String toString() => "$type $name";
}

class GenericRef extends Component {
    TypeRef type;
    TypeRef extend;

    @override
    void processList(List<dynamic> input) {
        // 0 type
        if (input[0] is TypeRef) {
            this.type = input[0];
        } else if (input[0] is ArrayBrackets) {
            this.type = input[0].toType();
        } else {
            print("GenericRef non-type: ${input[0]} in $input");
        }
        // 1 optional
        // 2 extends type
        if (input[2] != null) {
            this.extend = input[2][2];
        }
    }

    @override
    void getTypeRefs(Set<TypeRef> references) {
        this.type?.processTypeRefs(references);
        this.extend?.processTypeRefs(references);
    }

    @override
    String getName() => this.type.getName();

    @override
    String toString() => "$type${this.extend != null ? " extends $extend" : ""}";

    @override
    void writeOutput(OutputWriter writer) {
        this.type.writeOutput(writer);
    }
}