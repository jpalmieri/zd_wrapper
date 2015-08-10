require_relative 'zd_http_components'

class ZDHttpAPI

  def initialize(env)
    @env = env
    @connect = Connector.new(env)  
    @message = CLIMessages.new
  end

  def get(endpoint, opt = {})
    opt[:verbose] = false if !opt.has_key?(:verbose)
    opt[:long_uri] = false if !opt.has_key?(:long_uri)

    @message.working("get", endpoint) if opt[:verbose]

    body = @connect.get(endpoint, opt[:long_uri])

    if body.length == 1
      body = body.values[0]
      return body
    else
      final_body = Array.new
      body.values[0].each {|i| final_body.push(i)}
      
      page_number = 2
      while body[:next_page]
        add_body = @connect.get(body[:next_page], true)
        add_body.values[0].each {|p| final_body << p}
        body[:next_page] = add_body[:next_page]
        @message.page(page_number) if opt[:verbose]
        page_number += 1
      end

      return final_body
    end
  end

  def post(endpoint, payload, opt = {})
    opt[:verbose] = false if !opt.has_key?(:verbose)

    @message.working("post", endpoint) if opt[:verbose]

    resp = @connect.post(endpoint, payload)

    @message.response(resp.code, resp.message, resp.body) if opt[:verbose]

    use_response = JSON.parse(resp.body, :symbolize_names => true)
    return use_response.values[0]
  end

  def put(endpoint, payload, opt = {})
    opt[:verbose] = false if !opt.has_key?(:verbose)

    @message.working("put", endpoint) if opt[:verbose]
    
    resp = @connect.put(endpoint, payload)

    @message.response(resp.code, resp.message, resp.body) if opt[:verbose]

    use_response = JSON.parse(resp.body, :symbolize_names => true)
    return use_response.values[0]
  end

  def delete(endpoint, opt = {})
    opt[:verbose] = false if !opt.has_key?(:verbose)
    opt[:override_warning] = false if !opt.has_key?(:override_warning)

    if !opt[:override_warning]
      @message.warning(endpoint)
      confirm = gets.chomp
    end

    if opt[:override_warning] || @message.warning_check(confirm)

      @message.working("delete", endpoint) if opt[:verbose]

      resp = @connect.delete(endpoint)

      @message.response(resp.code, resp.message) if opt[:verbose]

    else
      @message.warning_failed
      exit!
    end
  end
end