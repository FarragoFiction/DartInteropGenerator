
import "components.dart";

class Module extends Component {
    final List<Component> components = <Component>[];

    @override
    void processList(List<dynamic> input) {
        // 0 docs
        this.docs = input[0];

        // 1 declare keyword
        // 2 module keyword

        // 3 name
        this.name = input[3].join(".");

        // 4 body
        final List<dynamic> content = input[4][1]; // between braces
        for (final dynamic object in content) {
            if (object is Component) {
                components.add(object);
            } else {
                print("Module non-component: $object");
            }
        }
    }

    @override
    String toString() => "${super.toString()}:$components";
}