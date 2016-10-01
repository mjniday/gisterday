#!/usr/bin/env ruby
require "optparse"
require "json"
require "httparty"

AUTH_URL = "https://api.github.com/authorizations"
GIST_URL = "https://api.github.com/gists"

class GitHubConnection
	attr_accessor :username, :password, :two_factor
	
	def initialize
		@two_factor = false
		get_credentials
	end

	def get_credentials
		puts "What's your username?"
		@username = STDIN.gets.chomp
		`stty -echo`
		puts "What is your password?"
		@password = STDIN.gets.chomp
		`stty echo`
	end

	def begin_authentication
		auth_credentials = {:username => @username, :password => @password}
		request_options = {
			:headers => {
				'User-Agent' => @username
			},
			:basic_auth => auth_credentials
		}
		request = HTTParty.post(AUTH_URL,request_options)
		
		if request.headers.inspect["x-github-otp"]
			puts "Enter Two-Factor Auth Code:"
			@two_factor = STDIN.gets.chomp
			finish_authentication
		end
	end

	def finish_authentication
		auth_credentials = {:username => @username, :password => @password}
		request_options = {
			:headers => {
				'X-GitHub-OTP' => @two_factor,
				'User-Agent' => 'gisterday'
			},
			:basic_auth => auth_credentials,
			:body => {
				:note => 'Gisterday CLI for creating gists',
				:scopes => ["gist"],
				:client_id => "96b65551444fdde8a6d8",
				:client_secret => "2213cd8ada533e9d9ec8ac4a993dbeaa85b3076d"
			}.to_json
		}
		request = HTTParty.post(AUTH_URL,request_options)

		ENV['GISTERDAY_TOKEN'] = request['token']

		if request.code == 201
			puts "Logged in as #{@username}"
		end
	end
end

def read_file(file)
	File.read(file)
end

def create_gist(filename,gist_content,options)
	request_options = {
		:headers => {	'User-Agent' => 'gisterday',	'Authorization' => "token #{ENV['GISTERDAY_TOKEN']}"	},
		:body => {
		  'description' => options[:description] || "Gist created using Gisterday",
		  'public' => true,
		  'files' => {
		    filename => {
		      'content' => gist_content
		    }
		  }
		}.to_json
	}

	if options[:anonymous]
		request_options[:headers].delete('Authorization')
	end

	req = HTTParty.post(GIST_URL,request_options)	
	format_response(req,options)
end

def format_response(response,options)
	STDOUT.puts ""
	STDOUT.puts JSON.parse(response.body) if options[:verbose]
	STDOUT.puts ""
	STDOUT.puts ""
	STDOUT.puts "New Gist created at:"
	STDOUT.puts JSON.parse(response.body)['html_url']
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

  opt.on("-a","create the gist anonymously") do |description|
    options[:anonymous] = true
  end

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
	create_gist(ARGV[0],contents,options)
else
	case ARGV[0]
		when "login"
			puts "Logging in..."
			connection = GitHubConnection.new
			connection.begin_authentication
		when "help"
		  puts opt_parser
		else
			file = ARGV[0]
			system %Q(vim +"put ='# When you save this file, a gist will be created.'" #{file})

			# check if user saved and create gist if so
			if Dir.entries(".").include? file
				contents = read_file(file)
				create_gist(file,contents,options)
			end
	end
end

