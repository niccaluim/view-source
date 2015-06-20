#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require File.dirname(__FILE__) + '/parser'
require 'sinatra'
require 'httpclient'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  <<EOS
<html>
<head><title>View Source</title></head>
<body>
  <form method="get" action="/source">
    <input type="text" name="uri"/>
    <input type="submit" value="View Source"/>
  </form>
</body>
</html>
EOS
end

get '/source' do
  client = HTTPClient.new
  raw = client.get_content(params['uri'])
  @summary, @tagged_html = summarize_and_tag(raw)
  @uri = params['uri']
  erb :source
end
