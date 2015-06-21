require 'hiredis'
require 'redis'
require 'httpclient'
require File.dirname(__FILE__) + '/util'

CACHE = LazyMemoizedValue.new { Redis.new }

# A wrapper around HTTPClient#get that follows redirects and caches
# responses. Returns the content of the final response.
#
# If the cache backing store has failed, this function silently behaves
# as though the cache were empty.
def get_content(uri, client = HTTPClient.new)
  cached_response = CACHE.value.get(uri) rescue nil
  if cached_response
    response = Marshal.load(cached_response)
  else
    response = client.get(uri)
    if cacheable?(response)
      ttl = ttl(response)
      response.peer_cert = nil # OpenSSL certificates can't be marshaled
      CACHE.value.set(uri, Marshal.dump(response), ex: ttl) rescue nil
    end
  end

  if [301, 302, 303, 307].include?(response.status) && !response.header['Location'].empty?
    get_content(response.header['Location'].first, client)
  elsif response.status != 200
    raise HTTPClient::BadResponseError.new("Unexpected response: #{response.status}", response)
  else
    response.content
  end
end

# Returns a Boolean indicating whether it is permissible to cache this response.
def cacheable?(response)
  pragma = response.header['Pragma'].first || ''
  control = response.header['Cache-Control'].first || ''
  expires = response.header['Expires'].first || ''

  if pragma.include?('no-cache')          ||
     control.include?('no-cache')         ||
     control.include?('no-store')         ||
     control.include?('private')          ||
     expires == '-1'                      ||
     [206, 303].include?(response.status) ||
     response.status < 200                ||
     (response.status > 399 && response.status != 410)
    return false
  elsif [302, 307].include?(response.status)
    !(response.header['Expires'].empty? && response.header['Cache-Control'].empty?)
  else
    true
  end
end

S_MAXAGE_RE = /s-maxage=(\d+)/
MAX_AGE_RE = /max-age=(\d+)/

# Returns an appropriate TTL in seconds for caching this response.
def ttl(response, default = 60*60)
  expires = response.header['Expires'].first
  control = response.header['Cache-Control'].first

  if control && match = control.match(S_MAXAGE_RE)
    match[1].to_i
  elsif control && match = control.match(MAX_AGE_RE)
    match[1].to_i
  elsif expires
    [(Time.rfc822(expires) - Time.now).floor, 0].max
  else
    default
  end
end
