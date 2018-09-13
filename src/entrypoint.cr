require "option_parser"
require "./boshfind"

fname = "-"
args  = [] of String

def usage!(exit_code=0)
  puts <<-USAGEMSG
  boshfind

  Traverses YAML using Bosh Ops file syntax

  USAGE
  ~~~~~
  boshfind ARGS PATH

  ARGS
  ~~~~

  -f ; --file
     ; File to use ; defaults to STDIN ; use - to explicitly use STDIN

  -h ; --help
     ; Usage
  USAGEMSG
  exit exit_code
end

OptionParser.parse! do |p|
  p.on("-f FILE", "--file FILE", "") { |f| fname = f }
  p.on("-h", "--help", "")           { usage! }
  p.unknown_args                     { |unknown_args| args = unknown_args }
end

usage!(1)                          if     args.empty?
abort "File #{fname} not found"    unless fname == "-" || File.exists?(fname)
abort "File #{fname} not readable" unless fname == "-" || File.readable?(fname)

path = args.first.strip

contents = fname == "-" ? STDIN.gets_to_end : File.read(fname, "utf8")
match    = Boshfind.find(contents, path)

abort "Nothing found for #{path}" if match.nil?
puts YAML.dump(match).gsub(/^---\s+/, "")
