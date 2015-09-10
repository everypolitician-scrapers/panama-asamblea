#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('//table[@id="table_1"]//tr[td]').each do |tr|
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
    data[:image] = URI.join(url, data[:image]).to_s unless data[:image].to_s.empty?
    ScraperWiki.save_sqlite([:name, :term], data)
  end
end

scrape_list('http://www.asamblea.gob.pa/diputados/')
