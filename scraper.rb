#!/usr/bin/env ruby
# File: s.rb
# Scrape career pages for job information
# Ideally I should get:
#  - Job Name
#  - Job URL (unique identifier)
#  - Job Location
#
# Built with the help of SelectorGadget and Nokogiri
#
# Author: Daniel Hartnell
# June 2016

require 'nokogiri'
require 'open-uri'
require 'json'
require 'sinatra'

# Scrape newrelic.com

all_jobs = []
url = "https://newrelic.com/about/careers"
doc = Nokogiri::HTML(open(url))
doc.css("#jobs-listing .list-unstyled").each do |job|
  job.css("li").each do |element|
    name = element.at_css("a").text.strip
    url  = element.at_css("a")[:href]
    loc  = element.at_css(".location").text.strip
    res  = {"title": "#{name}", "url": "#{url}", "location": "#{loc}"}

    all_jobs << res.to_json
  end
end

location_count = []

count = all_jobs.each do |j|
  location_count << JSON.parse(j)["location"]
end

frequency = location_count.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
most_popular = location_count.max_by { |v| frequency[v] }
least_popular = location_count.min_by { |v| frequency[v] }

get '/job-stats' do
  "<h1>Job Stats</h1><br>Most Popular: #{most_popular}<br>Lease Popular: #{least_popular}"
end

puts "Results:"
puts all_jobs
