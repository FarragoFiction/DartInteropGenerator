import "components.dart";

class InheritableDef extends Component {
    final Set<TypeRef<InheritableDef>> inherits = <TypeRef<InheritableDef>>{};
    Iterable<ClassRef> extend;
    Iterable<InterfaceRef> implement;

    final Set<GenericRef> generics = <GenericRef>{};

    InheritableDef() {
        extend = inherits.whereType();
        implement = inherits.whereType();
    }
}

class ClassDef extends InheritableDef {
    @override
    void processList(List<dynamic> input) {

        // 0 docs
        this.docs = input[0];
        // 1 export?
        // 2 abstract?
        // 3 class keyword
        // 4 name and generics
        this.name = input[4].name;

        // 5 extends
        // 6 implements
        // 7 open brace
        // 8 entries before constructor
        // 9 constructor
        // 10 entries after constructor
        // 11 close brace
    }
}

class InterfaceDef extends InheritableDef {
    @override
    void processList(List<dynamic> input) {

        // 0 docs
        this.docs = input[0];
        // 1 export?
        // 2 interface keyword
        // 3 name and generics
        // 4 extends
        // 5 open brace
        // 6 entries before constructor
        // 7 close brace
    }
}