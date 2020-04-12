
import "components.dart";

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
    String toString() => "$type${this.extend != null ? " extends $extend" : ""}";
}