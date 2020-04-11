
import "components.dart";

class Member extends Component {
    Accessor accessor;
    bool static;
    bool abstract;

    bool get private => this.accessor == Accessor.private || this.accessor == Accessor.protected || this.name.startsWith("_") || this.docs.contains("@hidden");
}

class Field extends Member {
    TypeRef type;

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 accessor
        this.accessor = Accessor.process(input[1]);
        // 2 abstract
        this.abstract = input[2] != null;
        // 3 static
        this.static = input[3] != null;
        // 4 readonly
        // 5 name
        this.name = input[5];
        // 6 optional
        // 7 value or semicolon
        if (input[7] is List<dynamic>) {
            if (input[7][1] is TypeRef) {
                this.type = input[7][1];
            } else {
                print("Field non-type: ${input[7][1]}");
            }
        }
    }
}

class Method extends Member {
    TypeRef type;

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 accessor
        this.accessor = Accessor.process(input[1]);
        // 2 abstract
        this.abstract = input[2] != null;
        // 3 static
        this.static = input[3] != null;
        // 4 readonly
        // 5 name
        this.name = input[5];
        // 6 optional
        // 7 generics
        // 8 arguments
        // 9 colon
        // 10 return type
        this.type = input[10];
        // 11 semicolon
    }
}

class Getter extends Member {
    TypeRef type;

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 accessor
        this.accessor = Accessor.process(input[1]);
        // 2 abstract
        this.abstract = input[2] != null;
        // 3 static
        this.static = input[3] != null;
        // 4 get
        // 5 name
        this.name = input[5];
        // 6 ()
        // 7 type
        if (input[7] is List<dynamic>) {
            this.type = input[7][1];
        }
        // 8 semicolon
    }
}

class Setter extends Member {
    Parameter argument;

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 accessor
        this.accessor = Accessor.process(input[1]);
        // 2 abstract
        this.abstract = input[2] != null;
        // 3 static
        this.static = input[3] != null;
        // 4 set
        // 5 name
        this.name = input[5];
        // 6 (
        // 7 arg
        this.argument = input[7];
        // 8 )
        // 9 semicolon
    }
}

class Constructor extends Component {
    bool private;

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 private
        this.private = input[1] != null;
        // 2 constructor
        // 3 args
        // 4 semicolon
    }
}