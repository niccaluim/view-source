#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require File.dirname(__FILE__) + '/parser'
require File.dirname(__FILE__) + '/util'
require 'sinatra'
require 'httpclient'
require 'nokogiri'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  erb :index
end

get '/source' do
  @uri = validate_uri(params['uri'])
  if @uri.nil?
    @message = "\"#{params['uri']}\" isn't a valid HTTP[S] URL."
    return erb :index
  end

  begin
    client = HTTPClient.new
    raw = client.get_content(@uri)
  rescue => e
    @message = "Couldn't retrieve #{@uri}."
    @explanation = e.message
    return erb :index
  end
  doc = Nokogiri::HTML(raw)
  prettified = doc.to_xhtml(indent: 2)

  @summary, @html = summarize_and_tag(raw)
  _, @pretty_html = summarize_and_tag(prettified)

  title_tag = doc.xpath('//head/title')
  @title = title_tag.empty? ? @uri : title_tag[0].text

  erb :source
end
