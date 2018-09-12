require "yaml"

module Boshfind

  alias ArrayIndex       = Int32
  alias ItemWithKeyValue = Tuple(String, String)
  alias HashKey          = String
  alias YamlPathFragment = ArrayIndex | ItemWithKeyValue | HashKey
  alias YamlPath         = Array(YamlPathFragment)

  def self.parse_subpath(subpath : String) : YamlPathFragment
    case subpath
    when /^-?\d+$/
      subpath.to_i32
    when /[^=]+=[^=]+/
      key, value = subpath.split("=", 2)
      {key, value}
    else
      subpath
    end
  end

  def self.parse_path(path_str : String) : YamlPath
    path_str
      .split("/")
      .reject { |s| s.empty? }
      .map { |subpath| parse_subpath(subpath) }
  end

  def self.traverse_array(tree, subpath)
    return nil if tree.size.zero?

    if subpath < 0
      return nil if subpath.abs > tree.size
    else
      return nil if tree.size <= subpath
      return nil if tree[subpath].nil?
    end

    return tree[subpath]
  end

  def self.find(contents, path_str)
    parsed_contents = YAML.parse(contents)
    path            = parse_path(path_str)
    tree            = parsed_contents

    path.each do |subpath|
      return nil if (tree.raw.is_a? String || tree.raw.is_a? Int32)

      case subpath
      when ArrayIndex
        next_val = traverse_array(tree, subpath)
        return nil if next_val.nil?
        tree = next_val
      when HashKey
        return nil unless tree[subpath]?
        tree = tree[subpath]
      when ItemWithKeyValue
        key, value = subpath
        return nil unless tree.raw.is_a? Array
        matches = tree.as_a.select { |i| i[key] && i[key].to_s == value }
        return nil if matches.empty?
        tree = matches.first
      end
    end

    tree
  end
end
