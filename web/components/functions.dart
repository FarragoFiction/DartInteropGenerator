
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
}