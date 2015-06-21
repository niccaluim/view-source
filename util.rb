require 'uri'

# Validates a URI string. If valid and the scheme is http or https, the
# URI is returned as a string. Otherwise, returns nil.
#
# If the URI has no scheme, "http://" is prepended to it before
# validation. The return value includes this prepended "http://".
#
# Thus the three conditions are:
# * validate_uri("http://example.com") => "http://example.com"
# * validate_uri("example.com")        => "http://example.com"
# * validate_uri("http://")            => nil
def validate_uri(uri_s)
  uri = URI.parse(uri_s)
  if uri.scheme.nil?
    URI.parse('http://' + uri_s)
    'http://' + uri_s
  elsif !['http', 'https'].include?(uri.scheme)
    nil
  else
    uri_s
  end
rescue URI::InvalidURIError
  nil
end
