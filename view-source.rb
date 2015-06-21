#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require File.dirname(__FILE__) + '/parser'
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
  client = HTTPClient.new
  raw = client.get_content(params['uri'])
  doc = Nokogiri::HTML(raw)
  prettified = doc.to_xhtml(indent: 2)

  @summary, @html = summarize_and_tag(raw)
  _, @pretty_html = summarize_and_tag(prettified)

  @uri = params['uri']
  title_tag = doc.xpath('//head/title')
  @title = title_tag.empty? ? @uri : title_tag[0].text

  erb :source
end
