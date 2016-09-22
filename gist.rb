#!/usr/bin/env ruby
require "net/http"
require "json"

def parse_options
  options = {}
  case ARGV[1]
  when "-f"
    options[:f] = ARGV[2]
  end
  options
end

def load_file(file)
	begin
		gist = File.read(file)
		make_request(file,gist)
	rescue
		STDOUT.puts "Cannot locate the file: #{file}"
	end
end

def make_request(file,gist)
	payload = {
	  'description' => "My gist",
	  'public' => true,
	  'files' => {
	    file => {
	      'content' => gist
	    }
	  }
	}

	uri = URI("https://api.github.com/gists")
	req = Net::HTTP::Post.new(uri.path)
	req.body = payload.to_json

	# GitHub API is strictly via HTTPS, so SSL is mandatory
	res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
	  http.request(req)
	end

	STDOUT.puts res.inspect
	STDOUT.puts res.body.inspect
end

case ARGV[0]
	when "create"
		the_file_name = parse_options[:f] || "sample.rb"
		the_file_contents = load_file(the_file_name)
	else 
	  STDOUT.puts <<-EOF
	Please provide command name
	Usage: 
	  gist create [-f] filename
	EOF
end