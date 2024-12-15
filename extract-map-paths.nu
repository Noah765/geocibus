def main [path: path]: nothing -> nothing {
  open $path
  | lines
  | skip until { $in starts-with '<svg' }
  | str join "\n"
  | from xml
  | get content.0.content.attributes.d
  | save assets/map.paths
}
