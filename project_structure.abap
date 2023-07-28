include project_name_top
  |- include project_name_types (or short project_name_typs)
  |- include project_name_constants (or short project_name_consts)
  |- include project_name_datadef (or short project_name_ddef)

include project_name_classes (or short include project_name_cls)
  |- include project_name_parent
  |- include project_name_child_a
  |- include project_name_child_b
  |- include project_name_app (contains 'main' method in app class as entry point)

app.main();
