require 'socket'
require 'pry'

class TCPServer

  tcp_server = TCPServer.new(9292)

  count = 0

  loop {
    client = tcp_server.accept

    puts "Ready for a request"
    request_lines = []
    while line = client.gets and !line.chomp.empty?
      request_lines << line.chomp
    end

    puts "Got this request:"
    puts request_lines.inspect
    puts "Sending response."
    request_route_info = request_lines[0].split(" ")
    host_info = request_lines[1].split(" ")[1].split(":")
    path = request_route_info[1]
    response = ""
    time = Time.now.strftime("%I:%M%p on %A, %B, %Y")#need to create spaces between D/M/Y.

    if path == "/"
      response = "<pre>
        Verb: #{request_route_info[0]}
        Path: #{path}
        Protocol: #{request_route_info[2]}
        Host: #{host_info[0]}
        Port: #{host_info[1]}
        Origin: #{host_info[0]}
        Accept: #{request_lines[6].split(" ")[1]}
        </pre>"
    elsif path == "/hello"
      response = "<pre>Hello, World! (#{count += 1})</pre>"
    elsif path == "/datetime"
      response = time
    elsif path == "/shutdown"
      "Total Requests: #{}" #need to get the total number of the loop.
    end


    output = "<html><head></head><body>#{response}</body></html>"
    headers = ["http/1.1 200 ok",
              "date: #{time}",
              "server: ruby",
              "content-type: text/html; charset=iso-8859-1",
              "content-length: #{output.length}\r\n\r\n"].join("\r\n")


    client.puts headers
    client.puts output

    puts ["Wrote this response:", headers, output].join("\n")
    client.close
    puts "\nResponse complete, exiting."
  }
end
