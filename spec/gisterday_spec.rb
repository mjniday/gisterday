require 'gist'
require 'spec_helper'

describe Gisterday::GitHubAuth do
  let(:username) { "username"}
  let(:password) { "password"}
  let(:instance) { described_class.new(username,password) }
  
  describe 'default object' do
    let(:credentials) { 'fake_credentials' }
    
    subject { instance }

    before do
      allow_any_instance_of(described_class).to(
        receive(:get_credentials).and_return(credentials)
      )
    end
    
    it { expect(subject.base_request_options[:username]).to be_falsey }
    it { expect(subject.base_request_options[:password]).to be_falsey }
  end

  describe '#get_credentials' do
    let(:given_username) { 'username' }
    let(:given_password) { 'password' }

    subject { instance }

    before do
      allow(STDIN).to(
        receive(:gets).and_return(given_username, given_password)
      )
    end
    
    it { expect(subject.username).to eq(given_username) }
    it { expect(subject.password).to eq(given_password) }
  end

  describe "#begin_authentication" do  
    context "when two factor is necessary" do
      before do
        stub_request(:any, /api.github.com/).
          to_return(:body => "stubbed response", :status => 401, :headers => {"X-GitHub-OTP" => "required"})

        allow(STDIN).to(
          receive(:gets).and_return("two factor")
        )
      end

      it "will call the finish authentication method" do
        connection = instance
        expect(STDOUT).to receive(:puts).with("Enter Two-Factor Auth Code:")
        expect(connection).to receive(:finish_authentication)
        connection.begin_authentication
      end
    end

    context "when the user gets back their personal access token" do
      before do
        response_body = {"token" => "my token"}.to_json
        stub_request(:any, /api.github.com/).
          to_return(:body => response_body, :status => 201, :headers => {})
      end

      it "will write the token to file" do 
        connection = instance
        expect(connection).to receive(:write_token_file)
        connection.begin_authentication
      end
    end

    context "when a different response code is returned" do
      before do
        stub_request(:any, /api.github.com/).to_return(:body => "stubbed response", :status => 200, :headers => {})
      end
      it 'returns a list of todos' do
        connection = instance
        expect(STDOUT).to receive(:puts).with('Request returned with the code: 200')
        connection.begin_authentication
      end
    end
  end

  describe "#write_token_file" do
    before(:context) do
      @file = "token_test.txt"
      @token = "this is my token"
      @connection = Gisterday::GitHubAuth.new('username','password')
    end

    after(:context) do 
      File.delete(@file)
    end

    it "should create a file that didn't already exist" do
      expect(Dir.entries(".").include? @file).to be false
    end

    it "should create a file and write a token to it" do
      @connection.write_token_file(@file,@token)
      expect(Dir.entries(".").include? @file).to be true
      expect(File.read(@file)).to eq "this is my token"
    end
  end
end
  
 describe Gisterday::Gist do 
  let(:options)   { {"a key" => "a value" } }
  let(:instance)  { described_class.new(options) }

  describe 'default object' do
    context "when the description option is set" do
      before do
        @gist = Gisterday::Gist.new({:description => "my description"})
      end

      it { expect(@gist.body['description']).to eq("my description") }
    end
  end

  describe "#add_file" do
    subject { instance }

    it "adds a file to the request body" do
      file = ("testing.txt")
      allow(subject).to receive(:read_file).with(file).and_return("file content")
      subject.add_file(file)
      expect(subject.body['files'][file]['content']).to eq("file content")
    end
  end

  describe "#push_gist" do
    context "when the user is not authenticated" do
      before do
        response_body = {:html_url => "www.example.com"}.to_json
        stub_request(:any, /api.github.com/).to_return(:body => response_body, :status => 200, :headers => {})
        @gist = instance
      end

      it "returns the gist's html url" do
        expect(STDOUT).to receive(:puts).with(/www.example.com/)
        @gist.push_gist
      end

      it "passes the response to format_response" do
        expect(@gist).to receive(:format_response)
        @gist.push_gist
      end

      it "does not set the Authorization header" do
        expect(@gist.headers['Authorization']).to be_nil
      end
    end

    context "when the user is authenticated" do
      before do
        response_body = {:html_url => "www.example.com"}.to_json
        stub_request(:any, /api.github.com/).to_return(:body => response_body, :status => 200, :headers => {})
        @gist = instance
        allow(@gist).to receive(:get_token).and_return("abcdefg")
        @gist.push_gist
      end

      it "sets the Authorization header" do
        expect(@gist.headers['Authorization']).to eq("token abcdefg")
      end
    end
  end

  describe "#format_response" do
    context "when the verbose option is set" do
      before do
        response_body = {:key_1 => "value 1", :key_2 => "value 2", :html_url => "www.example.com"}.to_json
        stub_request(:any, /api.github.com/).to_return(:body => response_body, :status => 200, :headers => {})
        @gist = Gisterday::Gist.new({:verbose => true})
      end

      it "returns a longer response" do
        expect(STDOUT).to receive(:puts).with(/value 2/)
        @gist.push_gist
      end
    end
  end
end