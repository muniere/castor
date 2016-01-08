require "spec"
require "./spec_helper"

describe "String" do

  describe "#unindent" do

    it "unindent string of multi lines (case 1)" do
      text = "
      Lorem Ipsum is simply dummy text of the printing and typesetting industry.
      Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,
      when an unknown printer took a galley of type and scrambled it to make a type specimen book."

      expected = [
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
        "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,",
        "when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
      ].join("\n")

      text.unindent.strip.should eq(expected)
    end

    it "unindent string of multi lines (case 2)" do
      text = "
      Usage: awesome-cmd [options] <arg1> <arg2>

      Options:
        -l, --length=number   Length of output text
        -i, --in-file=file    Path to input file
        -o, --out-file=file   Path to output file
        -v, --verbose         Show verbose messages
        -h, --help            Show this help"

      expected = [
        "Usage: awesome-cmd [options] <arg1> <arg2>",
        "",
        "Options:",
        "  -l, --length=number   Length of output text",
        "  -i, --in-file=file    Path to input file",
        "  -o, --out-file=file   Path to output file",
        "  -v, --verbose         Show verbose messages",
        "  -h, --help            Show this help",
      ].join("\n")

      text.unindent.strip.should eq(expected)
    end
  end

  describe "#index(Regex)" do

    it "returns index of search in string" do
      "foo bar".index(/bar$/).should eq(4)
      "fizz buzz".index(/zz/).should eq(2)
      "fizz buzz".index(/\s+/).should eq(4)
      "fizz buzz".index(/fizz/).should eq(0)
    end

    it "returns null when search not in string" do
      "foo bar".index(/fizzbuzz/).should be_nil
    end
  end
end
