require "optparse"
require "json"
require "httparty"

module Gisterday
	AUTH_URL = "https://api.github.com/authorizations"
	GIST_URL = "https://api.github.com/gists"
  TOKEN_LOCATION = ENV['HOME'] + "/.gisterday"

	class GitHubAuth
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
      
			if request.code == 201
        # For persistence, write the token to a file '.gisterday' in the home directory
        File.open(TOKEN_LOCATION, "w") { |f| f.write(request['token']) }
				puts "Logged in as #{@username}"
      else
        puts "Request returned with the code: #{request.code}"
			end
		end
	end

	def self.read_file(file)
		File.read(file)
	end

  def self.get_token
    begin
      token = read_file(TOKEN_LOCATION)
    rescue
      token = false
    end
  end

	def self.create_gist(filename,gist_content,options)
		request_options = {
			:headers => {	'User-Agent' => 'gisterday'	},
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

    if get_token && options[:anonymous] == nil
			request_options[:headers]['Authorization'] = "token #{get_token}"
		end

		req = HTTParty.post(GIST_URL,request_options)	
		format_response(req,options)
	end

	def self.format_response(response,options)
		STDOUT.puts ""
		STDOUT.puts JSON.parse(response.body) if options[:verbose]
		STDOUT.puts ""
		STDOUT.puts ""
		STDOUT.puts "New Gist created at:"
		STDOUT.puts JSON.parse(response.body)['html_url']
		STDOUT.puts ""
	end
end