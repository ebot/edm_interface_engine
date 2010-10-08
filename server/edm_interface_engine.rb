#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'RedCloth'
require 'haml'
require 'sass'
require 'pstore'
require 'lib/notification.rb'

$tlog = PStore.new('db/transaction_log')

use Rack::Auth::Basic do |username, password|
  [username, password] == ['admin', 'admin']
end

get '/' do
  haml :index
end

post '/transactions/new' do
  begin
    n = Notification.new(request.body.read)
    n.download_document
    n.record_transaction
    status 201
    "<Results><ResultCode Code=\"0\" /><ResultData><Message>Stored to public/#{n.transaction[:local_file_name]}</Message></ResultData></Results>"
  rescue Exception => e
    status 1002
    "<Results><ResultCode Code=\"1002\" /><ResultData><ErrorMessage>Stored to public/#{e.message}</ErrorMessage></ResultData></Results>"
  end
end

get '/transactions/log' do
  @transactions = $tlog.transaction { $tlog['transactions'] }
  
  haml :log
end

# SASS stylesheets
get '/stylesheets/application.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :application
end