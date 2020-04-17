import "dart:convert";
import "dart:html";
import "dart:js" as JS;

import "package:LoaderLib/Loader.dart";

TextAreaElement textbox;

void main() {
    textbox = querySelector("#input");

    document.body.append(FileFormat.saveButton(Formats.json, process, caption: "Go", filename: () => "jsclasses.json"));
}

Map<String,dynamic> process() {
    final List<String> classNames = textbox.value.split(",").map((String s) => s.trim()).toList()..retainWhere(JS.context.hasProperty);
    return <String,dynamic> { "js": classNames };
}