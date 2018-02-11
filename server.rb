require 'socket'
require 'pry'

class Server

  attr_reader :tcp_server,
              :count,
              :shutdown

  def initialize(port = nil)
    # @tcp_server = TCPServer.new(port)
    @count      = 0
    @shutdown   = false
  end

  def generate_root_respone(parsed_headers)
    verb, path, protocol, host, port, accept = parsed_headers

    "<pre>
    Verb: #{verb}
    Path: #{path}
    Protocol: #{protocol}
    Host: #{host}
    Port: #{port}
    Origin: #{host}
    Accept: #{accept}
    </pre>"
  end

  def generate_response(parsed_headers)
    path = parsed_headers[1]
    if path == "/"
      generate_root_response(parsed_headers)
    elsif path == "/hello"
      "<pre>Hello, World! (#{@count += 1})</pre>"
    elsif path == "/datetime"
      "<pre>#{time}</pre>"
    elsif path == "/shutdown"
      @shutdown = true
      "Total Requests: #{@count}"
    end
  end

  def time
    Time.now.strftime("%I:%M%p on %A, %B %d, %Y")
  end

  def generate_request_lines
  request_lines = []
    while line = @client.gets and !line.chomp.empty?
        request_lines << line.chomp
    end
    return request_lines
  end

  def parse_headers(request_lines)
    request_lines[0].split(" ") +
    request_lines[1].split(" ")[1].split(":") +
    [ request_lines[6].split(" ")[1] ]

  end

  def start_server
    loop {
      @client = tcp_server.accept

      puts "Ready for a request"
      request_lines = generate_request_lines
      puts "Got this request:"
      puts request_lines.inspect
      puts "Sending response."

      parsed_headers = parse_headers(request_lines)
      response = generate_response(parsed_headers)

      output = "<html><head></head><body>#{response}</body></html>"
      # binding.pry
      headers = ["http/1.1 200 ok",
                "date: #{time}",
                "server: ruby",
                "content-type: text/html; charset=iso-8859-1",
                "content-length: #{output.length}\r\n\r\n"].join("\r\n")

      @client.puts headers
      @client.puts output

      puts ["Wrote this response:", headers, output].join("\n")
      @client.close
      puts "\nResponse complete, exiting."
      break if shutdown
    }
  end
end
