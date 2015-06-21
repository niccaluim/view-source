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

# Sometimes HTTPClient gets the string encoding wrong. (Try loading
# facebook.com, for example.) This looks for a meta tag with a charset
# and forcibly switches the encoding of the raw HTML. `raw` is the raw
# HTML and `doc` is the Nokogiri document. Returns `raw` with the
# correct encoding.
def fix_encoding(raw, doc)
  charsets = doc.xpath('//head/meta/@charset')
  if charsets.empty?
    raw
  else
    raw.force_encoding(charsets[0].value)
  end
end
