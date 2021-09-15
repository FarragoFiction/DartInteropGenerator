import "dart:convert";
import "dart:html";
import "dart:js" as JS;

import "package:LoaderLib/Loader.dart";

late TextAreaElement textbox;

void main() {
    textbox = querySelector("#input")! as TextAreaElement;

    document.body!.append(FileFormat.saveButton(Formats.json, process, caption: "Go", filename: () => "jsclasses.json"));
}

Future<Map<String,dynamic>> process() async {
    final List<String> classNames = textbox.value!.split(",").map((String s) => s.trim()).toList()..retainWhere(JS.context.hasProperty);
    return <String,dynamic> { "js": classNames };
}