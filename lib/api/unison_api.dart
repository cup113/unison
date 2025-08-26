import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

/// OpenAPI configuration for generating the Unison API client
///
/// This configuration generates a type-safe Dart client from the OpenAPI specification.
/// The generated code is placed in 'lib/api/generated' and can be imported as 'package:unison/unison.dart'.
///
/// To regenerate the client after updating the OpenAPI spec:
/// 1. Run: flutter pub run build_runner build
/// 2. Or for clean rebuild: flutter pub run build_runner build --delete-conflicting-outputs
@Openapi(
  additionalProperties: AdditionalProperties(
    pubName: 'unison',
    pubAuthor: 'cup11',
    pubAuthorEmail: 'cup11jason@qq.com',
    pubHomepage: 'https://unison-server.cup11.top',
    pubDescription:
        'Unison API Client - Type-safe Dart client generated from OpenAPI specification',
  ),
  inputSpec: InputSpec(path: '../server/openapi.json'),
  generatorName: Generator.dart,
  outputDirectory: 'lib/api/generated',
  typeMappings: {
    'DateTime': 'DateTime',
  },
  importMappings: {},
)
class UnisonApi {}
