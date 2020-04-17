import "dart:convert";
import "dart:io";

import "package:args/args.dart";
import "package:path/path.dart" as Path;

import "processor.dart";

const String inputArg = "input";
const String jsArg = "js";

Future<void> main(List<String> arguments) async {
    final ArgParser parser = new ArgParser()
        ..addOption(inputArg, defaultsTo: "input.txt")
        ..addOption(jsArg)
    ;

    final ArgResults argResults = parser.parse(arguments);

    final RegExp commentStripper = new RegExp(r"\/\/.*");
    final RegExp commentStripper2 = new RegExp(r"\/\*[^\*]*\*\/");

    final File inputFile = new File(Path.join(Path.dirname(Platform.script.toFilePath()), argResults[inputArg]));
    final String data = (await inputFile.readAsString()).replaceAll(commentStripper, "").replaceAll(commentStripper2, "");

    final Processor processor = new Processor();

    if (argResults[jsArg] != null) {
        final File jsFile = new File(Path.join(Path.dirname(Platform.script.toFilePath()), argResults[jsArg]));
        final List<dynamic> list = (jsonDecode(await jsFile.readAsString()))["js"];
        final List<String> jsClasses = list.cast();
        print("JS class list: $jsClasses");
        processor.jsClasses.addAll(jsClasses);
    }

    processor.process(data);
}

