#!/usr/bin/env ruby
require 'rubygems'
require 'nokogiri'
require 'crack'
require 'pstore'
require 'edm_api'
require 'yaml'

class Notification
  attr_accessor :transaction

  def initialize(xml)
    conf = YAML::load( File.open( 'conf/setup.yml' ) )
    @edm = EDM.new( conf[:edm_server] )
    @tlog = PStore.new('db/transaction_log')
    
    doc = Nokogiri::XML(xml)
    file_fmt = doc.xpath("//Object/PhysicalObj/@Fmt").first.text
    
    doc_hash         = Crack::XML.parse(doc.to_xml)
    file_format      = conf[:file_formats][file_fmt]
    time             = Time.new
    encounter_number = doc.xpath("//Owner/EncNo").text
    doc_id           = doc.xpath("//Document/@DocId").text
    doc_key          = doc.xpath("//Document/@Key").text
    version          = doc.xpath("//Document/VersionList/Version/VersionNum").text
    signed           = doc.xpath("//Document/VersionList/Version/Signed").text
    doc_type_name    = doc.xpath("//Document/DocType/@DocTypeName").text
    file_name        = "#{doc_key}-#{version}-#{time.strftime("%Y%m%d%I%M%S%L")}.#{file_format}"
    
    @transaction  = { :time             => time,
                      :encounter_number => encounter_number,
                      :doc_id           => doc_id,
                      :doc_key          => doc_key,
                      :doc_type_name    => doc_type_name,
                      :version          => version,
                      :signed           => signed,
                      :local_file_name  => file_name,
                      :metadata         => doc_hash}
  end
  
  def download_document
    FileUtils.mkdir('public') unless File.exist?('public')
    
    response = @edm.get_object(@transaction[:doc_key])
    f = File.new "public/#{@transaction[:local_file_name]}", 'wb'
    f << response.body
    f.close
  end
  
  def record_transaction
    @tlog.transaction do
      @tlog['transactions'] = [] if @tlog['transactions'].nil?
      @tlog['transactions'] << @transaction
    end
  end
end
