require "option_parser"
require "logger"
require "./command"
require "../../lib"

#
# Index 
#
class Application::IndexCommand < Application::Command

  #
  # Run command
  #
  # @param args CLI arguments
  #
  def run(args : Array(String))
    # parse
    begin
      context = self.parse(args)
    rescue e
      abort e.message
    end

    # execute
    spider = Spider.new
    spider.logger = context.logger

    context.uris.each do |uri|
      if context.uris.size >= 2
        STDOUT.puts "==> #{uri.to_s} <=="
      end

      uris = spider.index(uri, focus: context.focus, grep: context.grep)

      uris.each do |u|
        STDOUT.puts(u.to_s)
      end

      if context.uris.size >= 2 && uri != context.uris.last
        STDOUT.puts
      end
    end
  end

  #
  # Parse CLI arguments
  #
  # @param args CLI arguments
  # @return Parsed context
  #
  def parse(args : Array(String)) : Context

    context = Context.new

    # parse
    parser = OptionParser.new
    parser.banner = "Usage: #{File.basename($0)} index [options] <url> [<url> ...]"

    parser.on("--href-text", "Focus on hrefs of texts") do 
      context.focus = Spider::Focus::HrefText
    end

    parser.on("--href-image", "Focus on hrefs of images") do
      context.focus = Spider::Focus::HrefImage
    end

    parser.on("--image", "Focus on images") do
      context.focus = Spider::Focus::Image
    end

    parser.on("--script", "Focus on scripts") do
      context.focus = Spider::Focus::Script
    end

    parser.on("--grep=regex", "Grep contents by URI with regex") do |v|
      context.grep = Regex.new(v)
    end

    parser.on("-v", "--verbose", "Show verbose messages") do
      context.verbose += 1
    end

    parser.on("-h", "--help", "Show this help") do
      STDERR.puts(parser)
      exit 0
    end

    argv = parser.parse(args) as Array(String)

    # logger
    if context.verbose > 0
      context.logger.level = Logger::DEBUG
    else
      context.logger.level = Logger::WARN
    end

    # validate
    if argv.empty?
      raise ArgumentError.new(parser.to_s)
    end

    context.uris = argv.map { |arg| arg.strip }.compact_map { |arg|
      begin
        next URI.parse(arg)
      rescue e
        context.logger.warn("Invalid URI: #{arg}")
        next nil
      end
    }

    return context
  end

  #
  # Context
  #
  struct Context 

    # args
    property uris : Array(URI)

    # opts
    property focus   : Spider::Focus
    property grep    : Regex?
    property logger  : Logger(IO::FileDescriptor)
    property verbose : Int32

    #
    # Initialize context
    #
    def initialize(
      @uris    = Array(URI).new,
      @focus   = Spider::Focus::Href,
      @grep    = nil,
      @logger  = Logger.create(STDERR),
      @verbose = 0,
    )
    end
  end
end

