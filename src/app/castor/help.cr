require "./command"
require "../../lib"

#
# Help
#
class Application::HelpCommand < Application::Command

  #
  # Run command
  #
  # @param args CLI arguments
  #
  def run(args : Array(String))
    STDERR.puts(self.usage)
  end

  #
  # Usage string
  #
  def usage : String
    return "
      Usage: #{File.basename($0)} <command> [[options] <args>]

      Available commands:
        index   Index URIs in page
        crawl   Index and download URIs in page
        help    Show this message
    ".unindent.strip
  end
end

