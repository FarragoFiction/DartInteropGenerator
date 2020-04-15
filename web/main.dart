import "dart:io";

import "package:args/args.dart";
import "package:path/path.dart" as Path;
import "package:petitparser/petitparser.dart";

import "components/components.dart";
import "grammar.dart";
import "parser.dart";

const String inputArg = "input";

Future<void> main(List<String> arguments) async {
    final ArgParser parser = new ArgParser()..addOption(inputArg, defaultsTo: "input.txt");

    final ArgResults argResults = parser.parse(arguments);

    final RegExp commentStripper = new RegExp(r"\/\/.*");
    final RegExp commentStripper2 = new RegExp(r"\/\*[^\*]*\*\/");

    final File inputFile = new File(Path.join(Path.dirname(Platform.script.toFilePath()), argResults[inputArg]));
    final String data = (await inputFile.readAsString()).replaceAll(commentStripper, "").replaceAll(commentStripper2, "");

    final GrammarParser processor = new TSDParser();

    final DateTime startTime = new DateTime.now();
    print("Starting parse");

    final Result<dynamic> result = processor.parse(data);
    print("Parsed in ${new DateTime.now().difference(startTime)}: ${result.isSuccess ? "success" : result}");
    print(result);
    print("Done in ${new DateTime.now().difference(startTime)}");

    if (result.isFailure) { return; }

    final TSDFile tsd = result.value;
    print("modules: ${tsd.modules.length}, other components: ${tsd.topLevelComponents.length}");
    print(tsd.modules.values.map((Module m) => m.name).toList());
    print(tsd.modules);
    print(tsd.topLevelComponents);
}

