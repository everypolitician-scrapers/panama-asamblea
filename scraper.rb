#!/bin/env ruby
# encoding: utf-8

require 'nokogiri'
require 'pry'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def members(url)
  noko = noko_for(url)
  noko.xpath('//table[@id="table_1"]//tr[td]').map do |tr|
    tds = tr.css('td')
    data = {
      name: tds[1].text.tidy,
      suplente: tds[2].text.tidy,
      area: tds[3].text.tidy,
      party: tds[4].text.tidy,
      image: tds[5].css('img/@src').text,
      term: 2014,
      source: url,
    }
    data[:image] = URI.join(url, URI.encode(data[:image])).to_s unless data[:image].to_s.empty?
    data
  end
end

data = members('http://www.asamblea.gob.pa/diputados/')
data.each { |mem| puts mem.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h } if ENV['MORPH_DEBUG']

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
ScraperWiki.save_sqlite([:name, :term], data)
