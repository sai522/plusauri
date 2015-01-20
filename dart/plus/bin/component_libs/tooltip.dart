library plus.codegen.dart.component_libs.tooltip;

import "package:id/id.dart";
import "package:path/path.dart";
import "package:ebisu/ebisu.dart";
import "package:ebisu/ebisu_dart_meta.dart";
import "package:ebisu_web_ui/ebisu_web_ui.dart";
import "../root_path.dart";

String _here = join(dirname(rootPath), 'component_libs');

ComponentLibrary get tooltip =>
    componentLibrary('tooltip')
    ..system.includeReadme = true
    ..system.license = 'boost'
    ..system.introduction = 'Polymer tooltip component'
    ..pubSpec.addDependency(pubdep('collection')..version =  ">=1.1.0 <1.2.0")
    ..prefix = 'plus'
    ..rootPath = _here
    ..examples = [
      example(idFromString('tooltip'))..initPolymer = false,
    ]
    ..libraries = [
    ]
    ..components = [
      component('nested')
      ..implClass = (class_('nested')
          ..defaultMemberAccess = IA
          ..members = [
            member('year')..isObservable = true..access = RW
          ]),
      component('tooltip')
      ..imports = [
        'async',
      ]
      ..implClass = (class_('tooltip')
          ..defaultMemberAccess = IA
          ..members = [
            member('container')..type = 'HtmlElement'..access = RO,
            member('closer')..type = 'HtmlElement'..access = RO,
            member('mouse_to_top_offset')..type = 'Point',
            member('mouse_leave_body_subscription')..type = 'StreamSubscription<MouseEvent>'..access = RO,
            member('mouse_move_subscription')..type = 'StreamSubscription<MouseEvent>'..access = RO,
            member('mouse_up_subscription')..type = 'StreamSubscription<MouseEvent>'..access = RO,
          ]),
    ]
    ..finalize();

main() {
  useDartFormatter = true;  
  tooltip.generate();
}
