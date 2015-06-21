#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require File.dirname(__FILE__) + '/parser'
require File.dirname(__FILE__) + '/util'
require File.dirname(__FILE__) + '/cache'
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
  # Validate URI.
  @uri = validate_uri(params['uri'])
  if @uri.nil?
    @message = "\"#{params['uri']}\" isn't a valid HTTP[S] URL."
    return erb :index
  end

  # Fetch HTML.
  begin
    raw = get_content(@uri)
  rescue => e
    @message = "Couldn't retrieve #{@uri}."
    @explanation = e.message
    return erb :index
  end
  doc = Nokogiri::HTML(raw)
  raw = fix_encoding(raw, doc)

  # Find the page's title.
  titles = doc.xpath('//head/title')
  @title = titles.empty? ? @uri : titles[0].text

  # Generate summaries and markup.
  @summary, @html = summarize_and_tag(raw)
  _, @pretty_html = summarize_and_tag(doc.to_xhtml(indent: 2))

  erb :source
end
