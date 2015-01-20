library plus.codegen.dart.component_libs.basic_input;

import "dart:io";
import "package:id/id.dart";
import "package:path/path.dart";
import "package:ebisu/ebisu.dart";
import "package:ebisu/ebisu_dart_meta.dart";
import "package:ebisu_web_ui/ebisu_web_ui.dart";
import "../root_path.dart";

String _here = join(dirname(rootPath), 'component_libs');

ComponentLibrary get basic_input =>
    componentLibrary('basic_input')
    ..system.includeReadme = true
    ..system.license = 'boost'
    ..system.introduction = 'Common input types'
    ..pubSpec.addDependency(pubdep('collection')..version =  ">=1.1.0 <1.2.0")
    ..prefix = 'plus'
    ..rootPath = _here
    ..examples = [
      example(idFromString('basic_input'))
      ..initPolymer = false,
    ]
    ..libraries = [
      library('formatting')
      ..imports = [ 'package:intl/intl.dart' ],
      library('input_utils')
      ..imports = [
        'package:observe/observe.dart',
        'package:polymer/polymer.dart',
        'package:paper_elements/paper_input.dart'
      ]
      ..classes = [
        class_('checked_input_field')
        ..doc = 'Wraps a PaperInput with consistent API supporting required'
        ..isAbstract = true
        ..extend = 'PolymerElement'
        ..members = [
          member('placeholder')
          ..doc = 'Label/placeholder text'
          ..classInit = 'Enter amount'
          ..access = RW
          ..isObservable = true,
          member('required')
          ..type = 'bool'
          ..doc = 'If true this is a requried field'
          ..classInit = true
          ..access = RW
          ..isObservable = true,
          member('input')
          ..access = IA..type = 'PaperInput',
          member('error')
          ..isObservable = true,
        ]
      ],
      library('test_formatting')
      ..imports = [ 'package:basic_input/formatting.dart' ]
      ..isTest = true,
    ]
    ..components = [
      component('money_input')
      ..imports = [
        'package:basic_input/formatting.dart',
        'package:basic_input/input_utils.dart',
      ]
      ..implClass = (class_('money_input')
          ..defaultMemberAccess = IA
          ..extend = 'CheckedInputField'
          ..members = [
            member('amount')..access = RO..classInit = 0..type = 'num',
          ]),
      component('simple_string_input')
      ..imports = [
        'package:basic_input/formatting.dart',
        'package:basic_input/input_utils.dart',
        'package:paper_elements/paper_input.dart',
      ]
      ..implClass = (class_('simple_string_input')
          ..extend = 'CheckedInputField'
          ..defaultMemberAccess = IA
          ..members = [
            member('value_constraint')
            ..access = RW
            ..type = 'StringValueConstraint'
          ]),
      component('rate_input')
      ..imports = [
        'package:basic_input/formatting.dart',
        'package:basic_input/input_utils.dart',
      ]
      ..implClass = (class_('rate_input')
          ..extend = 'CheckedInputField'
          ..defaultMemberAccess = IA
          ..members = [
            member('rate')..access = RO..classInit = 0..type = 'num',
          ]),
      component('num_with_units_input')
      ..imports = [
        'package:intl/intl.dart',
        'package:basic_input/formatting.dart',
        'package:basic_input/input_utils.dart',
      ]
      ..implClass = (class_('num_with_units_input')
          ..extend = 'CheckedInputField'
          ..defaultMemberAccess = IA
          ..members = [
            member('value_element')..type = 'InputElement',
            member('units')..access = RW,
            member('formatter')..type = 'NumberFormat',
            member('number')..access = RO..type = 'num',
          ]),
      component('date_input')
      ..imports = [
        'package:basic_input/formatting.dart',
        'package:basic_input/input_utils.dart',
      ]
      ..implClass = (class_('date_input')
          ..defaultMemberAccess = IA
          ..extend = 'CheckedInputField'
          ..members = [
            member('date')..access = RO..type = 'DateTime',
          ]),
      component('year_input')
      ..imports = [
        'package:basic_input/formatting.dart',
      ]
      ..implClass = (class_('year_input')
          ..members = [
            member('year_element')..access = IA..type = 'InputElement',
            member('year')..access = RO..type = 'int',
          ]),
      component('menu_selector')
      ..imports = [
        'package:paper_elements/paper_menu_button.dart',
      ]
      ..implClass = (class_('menu_selector')
          ..members = [
            member('selection')..isObservable = true,
            member('options')..type = 'List<Object>'..classInit = 'toObservable([])',
          ]),
    ]
    ..finalize();

main() {
  useDartFormatter = true;    
  basic_input.generate();
}
