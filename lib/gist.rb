require "optparse"
require "json"
require "httparty"

module Gisterday
	AUTH_URL = "https://api.github.com/authorizations"
	GIST_URL = "https://api.github.com/gists"
  TOKEN_LOCATION = ENV['HOME'] + "/.gisterday"

	class GitHubAuth
		attr_accessor :username, :password, :two_factor, :base_request_options

    def initialize
      get_credentials
      @base_request_options = {
        :headers => {
          'User-Agent' => 'gisterday'
        },
        :basic_auth => {
          :username => @username, 
          :password => @password
        },
        :body => {
          :note => 'Gisterday CLI for creating gists',
          :scopes => ["gist"]
        }.to_json
      }
    end

		def get_credentials
			puts "What is your username?"
			@username = STDIN.gets.chomp
			`stty -echo`
			puts "What is your password?"
			@password = STDIN.gets.chomp
			`stty echo`
		end

    def auth_request(options)
      HTTParty.post(AUTH_URL,options)
    end

		def begin_authentication
      request = auth_request(@base_request_options)

			if request.code == 401 && request.headers["X-GitHub-OTP"].match(/required/)
				puts "Enter Two-Factor Auth Code:"
				@two_factor = STDIN.gets.chomp
				finish_authentication
      elsif request.code == 201 && request['token']
        write_token_file(TOKEN_LOCATION,request['token'])
      else
        puts "Request returned with the code: #{request.code}"
			end
		end

		def finish_authentication
      @base_request_options[:headers]['X-GitHub-OTP'] = @two_factor
      request = auth_request(@base_request_options)

			if request.code == 201
				write_token_file(TOKEN_LOCATION,request['token'])
      else
        puts "Request returned with the code: #{request.code}"
			end
		end

		def write_token_file(location,token)
			# For persistence, write the token to a file '.gisterday' in the user's home directory
			File.open(location, "w") { |f| f.write(token) }
			puts "Logged in as #{@username}"
		end
	end

	def self.read_file(file)
		File.read(file)
	end

  def self.get_token
    begin
      read_file(TOKEN_LOCATION)
    rescue
      false
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
    puts "Here are the options..."
    puts options
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