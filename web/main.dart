import "dart:convert";
import "dart:io";

import "package:args/args.dart";
import "package:path/path.dart" as Path;

import "processor.dart";

const String inputArg = "input";
const String outputArg = "output";
const String fixesArg = "fixes";
const String jsArg = "js";

Future<void> main(List<String> arguments) async {
    final ArgParser parser = new ArgParser()
        ..addOption(inputArg, defaultsTo: "input.txt")
        ..addOption(outputArg, defaultsTo: "outputs")
        ..addOption(fixesArg)
        ..addOption(jsArg)
    ;

    final ArgResults argResults = parser.parse(arguments);

    final RegExp commentStripper = new RegExp(r"(:)?//.*");
    final RegExp commentStripper2 = new RegExp(r"/\*[^*]*\*/");

    final String programPath = Path.dirname(Platform.script.toFilePath());

    final File inputFile = new File(Path.join(programPath, argResults[inputArg]));
    final String data = (await inputFile.readAsString()).replaceAllMapped(commentStripper, (Match m) {
        if (m.group(1) != null && !m.group(1)!.isEmpty) {
            return m.group(0)!;
        }
        return "";
    }).replaceAll(commentStripper2,"");

    final Processor processor = new Processor();
    final Set<String> extraImports = <String>{};

    if (argResults[jsArg] != null) {
        final File jsFile = new File(Path.join(programPath, argResults[jsArg]));
        final List<dynamic> list = (jsonDecode(await jsFile.readAsString()))["js"];
        final List<String> jsClasses = list.cast();
        print("JS class list: $jsClasses");
        processor.jsClasses.addAll(jsClasses);
    }

    if (argResults[fixesArg] != null) {
        final File fixesFile = new File(Path.join(programPath, argResults[fixesArg]));
        final Map<String,dynamic> json = jsonDecode(await fixesFile.readAsString());
        final Map<String, dynamic> fixMap = json["fixes"];
        final Map<String, String> fixes = fixMap.cast();
        final Map<String, dynamic> replaceMap = json["classReplacements"];
        final Map<String, String> replacements = replaceMap.cast();
        print("Fixes list loaded");
        processor.manualFixes.addAll(fixes);
        processor.replacementClasses.addAll(replacements);
        final List<dynamic> imports = json["extraImports"];
        extraImports.addAll(imports.cast());
    }

    final Map<String,String> files = processor.process(data, extraImports);

    final String outputPath = Path.join(programPath, argResults[outputArg]);

    for (final String name in files.keys) {
        //print("$name:\n");
        //print(files[name]);
        //print("\nend $name");

        final File outputFile = new File(Path.join(outputPath, "$name.dart"));
        outputFile.writeAsString(files[name]!);
    }
}

