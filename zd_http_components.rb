# encoding: UTF-8
# Require standard libraries
require 'net/http'
require 'JSON'
require 'uri'

# Require the configuration file for the production and sandbox help centers.
require_relative '../config/zd_api_vars'
require_relative 'zd_http_strings'

class CLIMessages
  def initialize
    @strings = CLIStrings.new
  end
  def working(request, endpoint)
    puts @strings.performing(request, endpoint)
  end
  def warning(endpoint)
      puts @strings.warning(endpoint)
      print ">>"
  end
  def warning_check(input)
    input.upcase == @strings.warning_confirmation
  end
  def warning_failed
    puts @strings.warning_failed
  end
  def response(code, message, body = nil)
    puts @strings.http_response(code, message, body)
  end
  def page(current_page)
    if current_page == 2
      print "\r"
      puts @strings.page_msg(1)
    end
    puts @strings.page_msg(current_page)
  end
end

class Connector
  def initialize(environment)
    if environment == :sandbox
      @email = SANDBOX_EMAIL
      @token = SANDBOX_API_TOKEN
      @url   = SANDBOX_API_URL
    elsif environment == :production
      @email = ZENDESK_EMAIL
      @token = ZENDESK_API_TOKEN
      @url   = ZENDESK_API_URL
    end
  end

  def connect(endpoint, long_uri = false)

    if long_uri == false
      endpoint = @url + endpoint
    end

    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    return http, uri
  end

  def get(endpoint, long_uri)
    connection = self.connect(endpoint, long_uri)
    req = Net::HTTP::Get.new(connection[1].request_uri)
    req.basic_auth "#{@email}/token", @token
    resp = connection[0].request(req)

    body = JSON.parse(resp.body, :symbolize_names => true)
    return body
  end
  
  def post(endpoint, payload)
    connection = self.connect(endpoint)
    req = Net::HTTP::Post.new(connection[1].request_uri, initheader = {
      "Content-Type" => "application/json"
      })
    req.basic_auth "#{@email}/token", @token
    req.body = payload
    resp = connection[0].request(req)
    return resp
  end

  def put(endpoint, payload)
    connection = self.connect(endpoint)
    req = Net::HTTP::Put.new(connection[1].request_uri, initheader = {
      "Content-Type" => "application/json"
      })
    req.basic_auth "#{@email}/token", @token
    req.body = payload
    resp = connection[0].request(req)
    return resp
  end

  def delete(endpoint)
    connection = self.connect(endpoint)
    req = Net::HTTP::Delete.new(connection[1].request_uri)
    req.basic_auth "#{@email}/token", @token
    resp = connection[0].request(req)
    return resp
  end
end