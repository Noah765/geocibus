def main [path: path]: nothing -> nothing {
  open $path
  | from xml
  | get content.content
  | each { $in.0.attributes.d }
  | str join "\n"
  | save -f assets/map.paths
}
