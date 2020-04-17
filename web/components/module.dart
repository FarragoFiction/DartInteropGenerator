
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
    void processTypeRefs(Set<TypeRef> references, [Set<String> exclusions]) { getTypeRefs(references, exclusions); }

    @override
    void getTypeRefs(Set<TypeRef> references, [Set<String> exclusions]) {
        for (final Component c in components) {
            if (!exclusions.contains(c.getName())) {
                c.processTypeRefs(references);
            } else {
                print("Excluding ${c.runtimeType} ${c.getName()} as it is a js class");
            }
        }
    }

    @override
    String toString() => "${super.toString()}:$components";
}