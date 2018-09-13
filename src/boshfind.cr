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

  def self.traverse(tree, subpath : ArrayIndex)
    return nil if tree.size.zero?

    if subpath < 0
      return nil if subpath.abs > tree.size
    else
      return nil if tree.size <= subpath
      return nil if tree[subpath].nil?
    end

    tree[subpath]
  end

  def self.traverse(tree, subpath : HashKey)
    tree[subpath]? ? tree[subpath] : nil
  end

  def self.traverse(tree, subpath : ItemWithKeyValue)
    return nil unless tree.raw.is_a? Array
    key, value = subpath
    matches = tree.as_a.select { |i| i[key] && i[key].to_s == value }
    matches.empty? ? nil : matches.first
  end

  def self.find(contents, path_str)
    parsed_contents = YAML.parse(contents)
    path            = parse_path(path_str)
    tree            = parsed_contents

    path.each do |subpath|
      return nil if (tree.raw.is_a? String || tree.raw.is_a? Int32)

      next_val = traverse(tree, subpath)
      return nil if next_val.nil?
      tree = next_val
    end

    tree
  end
end
