import 'package:equatable/equatable.dart';
import 'package:morpheme_cucumber/morpheme_cucumber.dart';

class Gherkin extends Equatable {
  Gherkin({
    required this.source,
    required this.gherkinDocument,
    required this.pickles,
  });

  final Source? source;
  final GherkinDocument? gherkinDocument;
  final List<Pickle> pickles;

  @override
  List<Object?> get props => [source, gherkinDocument, pickles];
}
