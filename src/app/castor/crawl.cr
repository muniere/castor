require "option_parser"
require "logger"
require "./command"
require "../../lib"

#
# Crawl
#
class Application::CrawlCommand < Application::Command

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
      uris = spider.index(uri, focus: context.focus, grep: context.grep)
      spider.download(uris, options: context.options)
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
    parser.banner = "Usage: #{File.basename($0)} crawl [options] <url> [<url> ...]"

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

    parser.on("-P directory", "--prefix=directory", "Directory to download contents") do |v|
      context.options.prefix = v
    end

    parser.on("-c number", "--concurrency=number", "Concurrency of download") do |v|
      context.options.concurrency = v.to_i
    end

    parser.on("--overwrite", "Overwrite exising contents") do
      context.options.overwrite = true
    end

    parser.on("-n", "--dry-run", "Do not execute acutally") do
      context.options.dry_run = true
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
    if context.verbose >= 2
      context.logger.level = Logger::DEBUG
    elsif context.verbose >= 1
      context.logger.level = Logger::INFO
    else
      context.logger.level = Logger::WARN
    end

    if context.options.dry_run 
      context.logger.level = Math.min(context.logger.level, Logger::INFO)
    end

    # validate
    if argv.empty?
      raise ArgumentError.new(parser.to_s)
    end

    context.uris = argv.map { |arg| arg.strip }.compact_map { |arg|
      begin
        next URI.parse(arg)
      rescue e
        context.logger.warn("Invalid URL: #{arg}")
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
    property options : Spider::DownloadOptions
    property focus   : Spider::Focus
    property grep    : Regex?
    property logger  : Logger(IO::FileDescriptor)
    property verbose : Int32
  
    #
    # Initialize context
    #
    def initialize(
      @uris    = Array(URI).new,
      @options = Spider::DownloadOptions.new,
      @focus   = Spider::Focus::Href,
      @grep    = nil,
      @logger  = Logger.create(STDERR),
      @verbose = 0,
    )
    end
  end
end

