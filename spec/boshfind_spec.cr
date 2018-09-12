require "yaml"
require "./spec_helper"

describe Boshfind do
  it "parses strings correctly" do
    Boshfind
      .parse_path("/a/yaml/path")
      .should eq(["a", "yaml", "path"])
  end

  it "parses indices correctly" do
    Boshfind
      .parse_path("/a/0/path")
      .should eq(["a", 0, "path"])
  end

  it "parses hashes correctly" do
    Boshfind
      .parse_path("/a/key=value/path")
      .should eq(["a", {"key", "value"}, "path"])

    Boshfind
      .parse_path("/a/key=0/path")
      .should eq(["a", {"key", "0"}, "path"])
  end

  it "traverses arrays with non-negative indices" do
    yaml = <<-YAML
           ---
           - a
           - b
           - c
           YAML

    Boshfind.find(yaml, "/0").should eq("a")
    Boshfind.find(yaml, "/1").should eq("b")
    Boshfind.find(yaml, "/2").should eq("c")
    Boshfind.find(yaml, "/3").should eq(nil)
  end

  it "traverses arrays with negative indices" do
    yaml = <<-YAML
           ---
           - a
           - b
           - c
           YAML
    Boshfind.find(yaml, "/-1").should eq("c")
    Boshfind.find(yaml, "/-2").should eq("b")
    Boshfind.find(yaml, "/-3").should eq("a")
    Boshfind.find(yaml, "/-4").should eq(nil)
  end

  it "traverses hashes" do
    yaml = <<-YAML
           ---
           a: 1
           b: 2
           c: 3
           YAML

    Boshfind.find(yaml, "/a").should eq(1)
    Boshfind.find(yaml, "/b").should eq(2)
    Boshfind.find(yaml, "/c").should eq(3)
    Boshfind.find(yaml, "/d").should eq(nil)
  end

  it "traverses lists of hashes" do
    yaml = <<-YAML
           ---
           - name: a
           - name: b
           - name: c
           YAML
    Boshfind.find(yaml, "/name=a").should eq({ "name" => "a"})
    Boshfind.find(yaml, "/name=b").should eq({ "name" => "b"})
    Boshfind.find(yaml, "/name=c").should eq({ "name" => "c"})
    Boshfind.find(yaml, "/name=d").should eq(nil)
  end

  it "hash of list of hash" do
    yaml = <<-YAML
           ---
           instance_groups:
             - name:  hello
               value: world
             - name:  foo
               value: bar
           variables:
             hello: world
             foo:   bar
             zero:  0
             one:   1
           YAML

    Boshfind
      .find(yaml, "/instance_groups/0/name").should eq("hello")
    Boshfind
      .find(yaml, "/instance_groups/name=hello/name").should eq("hello")
    Boshfind
      .find(yaml, "/instance_groups/name=hello/value").should eq("world")

    Boshfind
      .find(yaml, "/instance_groups/1/name").should eq("foo")
    Boshfind
      .find(yaml, "/instance_groups/name=foo/name").should eq("foo")
    Boshfind
      .find(yaml, "/instance_groups/name=foo/value").should eq("bar")

    Boshfind.find(yaml, "/variables/hello").should eq("world")
    Boshfind.find(yaml, "/variables/foo").should eq("bar")

    Boshfind.find(yaml, "/variables/zero").should eq(0)
    Boshfind.find(yaml, "/variables/one").should eq(1)
  end

  it "list of list" do
    yaml = <<-YAML
           ---
           - [ 1, 2, 3 ]
           - [ 4, 5, 6 ]
           YAML

    Boshfind.find(yaml, "/0/0").should eq(1)
    Boshfind.find(yaml, "/0/1").should eq(2)
    Boshfind.find(yaml, "/0/2").should eq(3)

    Boshfind.find(yaml, "/1/0").should eq(4)
    Boshfind.find(yaml, "/1/1").should eq(5)
    Boshfind.find(yaml, "/1/2").should eq(6)
  end
end
