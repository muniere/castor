#
# Extension of standard String class
#
class String

  #
  # Returns the index of search in the string, or nil if the string is not present.
  #
  def index(search : Regex, offset = 0) 
    return self[offset..-1] =~ search
  end

  #
  # Unindent multiple lines
  #
  def unindent
    indent = self.split("\n")
      .reject { |l| l.match(/^\s+$/) }
      .map    { |l| l.index(/[^\s]/) }
      .compact.min || 0

    return self.gsub(/^[[:blank:]]{#{indent}}/m, "")
  end
end

