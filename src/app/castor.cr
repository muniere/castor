#
# Application
#
class Application

  #
  # Initialize application
  #
  def initialize
    @commands = {
      "index" => IndexCommand.new,
      "crawl" => CrawlCommand.new,
      "help"  => HelpCommand.new,
    }
  end

  #
  # Run pplication
  #
  # @param args CLI arguments
  #
  def run(args : Array(String))
    # blocking IO
    STDOUT.blocking = true
    STDERR.blocking = true

    # validate
    if args.empty?
      @commands["help"].run(args)
      exit 1
    end

    # subcommand
    command = args.shift
    
    unless @commands.has_key?(command)
      @commands["help"].run(args)
      exit 1
    end

    # run
    begin
      @commands[command].run(args)
      exit 0
    rescue e
      abort e.message
      exit 1
    end
  end
end

require "./castor/*"

#
# Run application
#
if PROGRAM_NAME == $0
  Application.new.run(ARGV)
end

