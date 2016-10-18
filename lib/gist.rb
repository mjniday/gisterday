require "optparse"
require "json"
require "httparty"

module Gisterday
	AUTH_URL = "https://api.github.com/authorizations"
	GIST_URL = "https://api.github.com/gists"
  TOKEN_LOCATION = ENV['HOME'] + "/.gisterday"

	class GitHubAuth
		attr_accessor :username, :password, :two_factor, :base_request_options

    def initialize(username,password)
      @username = username
      @password = password
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

    def auth_request(options)
      HTTParty.post(AUTH_URL,options)
    end

		def begin_authentication
      response = auth_request(@base_request_options)

			if response.code == 401 && response.headers["X-GitHub-OTP"].match(/required/)
				puts "Enter Two-Factor Auth Code:"
				@two_factor = STDIN.gets.chomp
				finish_authentication
      elsif response.code == 201 && response['token']
        write_token_file(TOKEN_LOCATION,response['token'])
      else
        puts "Request returned with the code: #{response.code}"
			end
		end

		def finish_authentication
      @base_request_options[:headers]['X-GitHub-OTP'] = @two_factor
      response = auth_request(@base_request_options)

			if response.code == 201
				write_token_file(TOKEN_LOCATION,response['token'])
      else
        puts "Request returned with the code: #{response.code}"
        puts response
			end
		end

		def write_token_file(location,token)
			# For persistence, write the token to a file '.gisterday' in the user's home directory
			File.open(location, "w") { |f| f.write(token) }
			puts "Logged in as #{@username}"
		end
	end

  class Gist
    attr_accessor :options, :headers, :body
    
    def initialize(options)
      @options = options
      @headers = {'User-Agent' => 'gisterday'}
      @body = {
        'description' => @options[:description] || "Gist created using Gisterday",
        'public' => true,
        'files' => {}
        }
    end

  	def read_file(file)
  		File.read(file)
  	end

    def get_token
      begin
        read_file(TOKEN_LOCATION)
      rescue
        false
      end
    end

    def add_file(file)
      @body['files'][file] = {"content" => read_file(file)}
    end

    def push_gist
      if get_token && @options[:anonymous] == nil
        @headers['Authorization'] = "token #{get_token}"
      end

      response = HTTParty.post(GIST_URL,:body => @body.to_json, :headers => @headers) 
      format_response(response)
    end

  	def format_response(response)
      STDOUT.puts %Q{

        #{JSON.parse(response.body) if @options[:verbose]}


        New Gist created at:
        #{JSON.parse(response.body)['html_url']}
      }
  	end
  end
end