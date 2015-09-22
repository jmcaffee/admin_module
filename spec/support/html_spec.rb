
module HtmlSpec
  class << self
    attr_accessor :always_use_server

    def html
      @html ||= File.expand_path("../../data/html", __FILE__)
    end

    def url_for(str, opts = {})
      if opts[:needs_server] || always_use_server
        File.join(host, str)
      else
        File.join(files, str)
      end
    end

    def files
      @files ||= "file://#{html}"
    end

    def host
      @host ||= "http://"
    end
  end
end
