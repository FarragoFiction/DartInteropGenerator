
import "components.dart";

class TSDFile extends Component {
    Map<String, Module> modules = <String,Module>{};
    Set<Component> topLevelComponents = <Component>{};

    @override
    void processList(List<dynamic> input) {
        for (final dynamic item in input) {
            if (item is Module) {
                if (!modules.containsKey(item.name)) {
                    modules[item.name] = item;
                } else {
                    final Module module = modules[item.name];
                    module.components.addAll(item.components);
                }
            } else if (item is Component) {
                this.topLevelComponents.add(item);
            } else {
                print("TSDFile top level object: $item");
            }
        }
    }

    @override
    String toString() => "TSDFile";
}