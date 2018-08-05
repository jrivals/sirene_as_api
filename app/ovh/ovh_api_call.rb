require 'digest'
require 'net/http'
require 'openssl'

class OvhAPICall < SireneAsAPIInteractor
  AK = Rails.application.secrets.OVH_APPLICATION_KEY
  AS = Rails.application.secrets.OVH_APPLICATION_SECRET
  CK = Rails.application.secrets.OVH_CONSUMER_KEY
  # Timestamp as a constant since we need the same on request and signature
  TSTAMP = Time.now.to_i.to_s

  def initialize(method, query, body)
    @method = method
    @query = query
    @body = body
  end

  # Currently only works for Get and Post, will update for more methods when needed
  def call
    uri = URI.parse(ovh_domain)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    # http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = build_request
    add_headers(request)

    http.request(request)
  end

  def build_request
    return request_get if @method == 'GET'
    return request_post if @method == 'POST'
    raise 'Error : method parameter should be GET or POST'
  end

  def request_get
    Net::HTTP::Get.new(@query)
  end

  def request_post
    request = Net::HTTP::Post.new(@query)
    request.add_field('Content-Type', 'application/json')
    request.body = @body
    request
  end

  def add_headers(request)
    request['X-Ovh-Application'] = AK
    request['X-Ovh-Timestamp'] = TSTAMP
    request['X-Ovh-Signature'] = signature
    request['X-Ovh-Consumer'] = CK
  end

  def signature
    '$1$' + Digest::SHA1.hexdigest(AS + '+' + CK + '+' + @method + '+' + @query + '+' + @body + '+' + TSTAMP)
  end

  def ovh_domain
    'https://eu.api.ovh.com/1.0'
  end
end
