
import "components.dart";

class Variable extends Component {
    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];
        // 1 export
        // 2 const/var/etc
        // 3 name
        this.name = input[3];
        // 4 value
        // 5 semicolon
    }
}