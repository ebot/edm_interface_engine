#!/usr/bin/env ruby
require 'net/http'
require 'rubygems'
require 'RestClient'

puts "Reading xml docs in notifications"
Dir.glob('notifications/*.XML').each do |notification|
  xml_file = File.open(notification, 'r')
  
  resp = RestClient.post 'http://admin:admin@ml303qbc/transactions/new', 
                         xml_file.read, :content_type => 'application/xml'
  puts "  #{resp}"
  xml_file.close
end