#!/usr/bin/env ruby
require 'optparse'
require "net/http"
require "json"

def read_file(file)
	File.read(file)
end

def make_request(filename,gist_content,options)
	payload = {
	  'description' => options[:description] || "My gist",
	  'public' => true,
	  'files' => {
	    filename => {
	      'content' => gist_content
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
	STDOUT.puts ""
	STDOUT.puts res.body.inspect if options[:verbose]
	STDOUT.puts ""
	STDOUT.puts ""
	STDOUT.puts "New Gist created at:"
	STDOUT.puts JSON.parse(res.body)['html_url']
	STDOUT.puts ""
end

options = {}

opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: gist [FILE] [OPTIONS]"
  opt.separator  ""
  opt.separator  "Commands"
  opt.separator  "     <blank>: create a new gist in text editor"
  opt.separator  "     <file>:  create a new gist using the specified file"
  opt.separator  "     login:   log in to github account"
  opt.separator  ""
  opt.separator  "Options"
  # opt.separator  "     -lns: choose which lines in the file should be included in gist"
  opt.separator  "     -d:   set the description of the gist"
  opt.separator  "     -v:   view full http response"

  opt.on("-d","--description DESCRIPTION","set the gist description") do |description|
    options[:description] = description
  end

  opt.on("-v","--verbose","view full response of the http request") do
    options[:verbose] = true
  end

  opt.on("-h","--help","help") do
    puts opt_parser
  end
end

opt_parser.parse!

if Dir.entries(".").include? ARGV[0]
	contents = read_file(ARGV[0])
	make_request(ARGV[0],contents,options)
else
	case ARGV[0]
		when "new"
			puts "TODO: creating a new gist..."
		else
		  puts opt_parser
	end
end

