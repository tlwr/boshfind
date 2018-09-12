require "./boshfind"

abort "No path argument" if ARGV.empty?

contents = STDIN.gets_to_end
path_str = ARGV[0]
match    = Boshfind.find(contents, path_str)

exit 1 if match.nil?
puts YAML.dump(match).gsub(/^---\s+/, "")
