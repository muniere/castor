require "http/client"
require "logger"
require "uri"
require "xml"

#
# Spider
#
class Spider

  #
  # Focus
  #
  enum Focus
    Href
    HrefText
    HrefImage
    Image
    Script
  end

  #
  # Properties
  #
  property regexes :: Hash(Symbol, Regex)
  property logger  :: Logger?

  #
  # Initialize
  #
  def initialize(
    @regexes = {
      :text   => %r(\.(txt)$),
      :image  => %r(\.(jpg|png|gif)$),
      :script => %r(\.(js)$),
    },
    @logger = nil
  )
  end
end

#
# Index
#
class Spider

  #
  # Index URIs included in uri
  #
  # @param uri
  # @return URIs
  #
  def index(uri : URI, focus = Href : Focus, grep = nil : Regex?) : Array(URI)
    case focus
    when Focus::Href
      self.index(uri, xpath: "//a/@href"    , grep: grep)
    when Spider::Focus::HrefText
      self.index(uri, xpath: "//a/@href"    , regex: @regexes[:text]  , grep: grep)
    when Spider::Focus::HrefImage
      self.index(uri, xpath: "//a/@href"    , regex: @regexes[:image] , grep: grep)
    when Spider::Focus::Image
      self.index(uri, xpath: "//img/@src"   , regex: @regexes[:image] , grep: grep)
    when Spider::Focus::Script
      self.index(uri, xpath: "//script/@src", regex: @regexes[:script], grep: grep)
    else 
      Array(URI).new
    end
  end

  #
  # Index HTML elements from URI
  #
  # @param uri
  # @param xpath
  # @param regex
  # @return URIs
  #
  protected def index(uri : URI, xpath = "//*" : String, regex = %r(.*) : Regex, grep = nil : Regex?) : Array(URI)

    #
    # Fetch
    #
    @logger.try(&.debug("Get contents of URI: #{uri.to_s}"))

    res = HTTP::Client.get(uri) 
    doc = XML.parse_html(res.body)

    #
    # Search
    #
    @logger.try(&.debug("Search URIs from URI: #{uri.to_s}"))

    elems = doc.xpath(xpath)

    unless elems.is_a?(XML::NodeSet)
      return Array(URI).new
    end

    #
    # Format
    #
    return elems.compact_map(&.text)
      .select      { |s| s =~ regex }
      .select      { |s| grep.nil? || s =~ grep }
      .compact_map { |s| s.sub(" ", "+") }
      .compact_map { |s| URI.parse(s) rescue nil }
      .compact_map { |u| u.host = u.host || uri.host; u }
  end
end

#
# Download
#
class Spider

  #
  # Options for download
  #
  class DownloadOptions
    
    property prefix      :: String?
    property overwrite   :: Bool
    property dry_run     :: Bool
    property concurrency :: Int
    property blocking    :: Bool

    def initialize(
      @prefix      = nil,
      @overwrite   = false,
      @dry_run     = false,
      @concurrency = 20,
      @blocking    = true,
    )
    end
  end

  #
  # Download contents
  #
  # @param uris URIs of images to download
  # @param options Options for download
  #
  def download(uris : Array(URI), options = DownloadOptions.new)

    queue = Array(URI).new + uris
    channel = Channel(Bool).new

    options.concurrency.times do |i|
      delay(i * 0.05) do
        Worker.new(
          id:      i,
          queue:   queue,
          channel: channel,
          options: options,
          logger:  @logger,
        ).run
      end
    end

    if options.blocking
      @logger.try(&.debug("Channel is waiting for #{uris.size} messages"))

      uris.size.times do |i|
        channel.receive
        @logger.try(&.debug("Channel received message ##{i}"))
      end
    end
  end
end

class Spider::Worker

  #
  # Properties
  #
  getter id       :: Int
  getter queue    :: Array(URI)
  getter channel  :: Channel
  getter options  :: DownloadOptions
  getter logger   :: Logger?

  #
  # Initialize worker
  #
  def initialize(
    @id      = 0,
    @queue   = nil, 
    @channel = nil,
    @options = nil,
    @logger  = nil,
  ) 
    @locations = Array(String).new
  end

  #
  # Run worker
  #
  def run
    @logger.try(&.debug("Worker ##{@id} launched"))

    until @queue.empty?

      uri = @queue.pop

      filename = File.basename(uri.to_s)

      if @options.prefix.nil?
        filepath = filename
      else
        filepath = File.join(@options.prefix as String, filename)
      end

      if !@options.overwrite && File.exists?(filepath) 
        @logger.try(&.info("File already exists: #{filepath}"))
        @channel.send(true)
        next
      end

      @logger.try(&.info("[START ] #{uri.to_s} => #{filepath}"))

      if @options.dry_run
        @channel.send(true)
        next
      end

      begin
        res = self.get(uri) 
        file = File.open(filepath, mode: "wb") 
        file.print(res.body)
        file.close
        @logger.try(&.info("[FINISH] #{uri.to_s} => #{filepath}"))
        @channel.send(true)
      rescue e
        @logger.try(&.error(e))
        @channel.send(false)
      end
    end

    @logger.try(&.debug("Worker ##{@id} terminate"))
  end

  #
  # Get content of URI
  #
  def get(uri : String | URI) : HTTP::Response

    if @locations.includes?(uri.to_s)
      exception = Exception.new("Worker found redirect loop")
      @locations.clear
      raise exception
    end

    @locations.push(uri.to_s)

    res = HTTP::Client.get(uri) 

    case res.status_code
    when 301, 302
      location = res.headers["location"]
      @logger.try(&.debug("Worker follows redirect to #{location}"))
      return self.get(location)
    else
      @locations.clear
      return res
    end
  end
end
