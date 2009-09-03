#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + '/../spec/spec_helper')

class Item
  include OxMlk
  
  ox_elem :asin, :from => 'ASIN'
  ox_elem :detail_page_url, :from => 'DetailPageURL'
  ox_elem :manufacturer, :from => 'Manufacturer', :in => 'ItemAttributes'
  ox_elem :point, :from => 'georss:point'
end

class ItemSearchResponse
  include OxMlk
  
  ox_tag :camelcase
  
  ox_elem :total_results, :as => Integer, :in => 'Items'
  ox_elem :total_pages, :as => Integer, :in => 'Items'
  ox_elem :items, :as => [Item], :in => 'Items'
end

response = ItemSearchResponse.from_xml(xml_for(:amazon))

puts response.total_results, response.total_pages

response.items.each do |item|
  puts item.asin, item.detail_page_url, item.manufacturer, item.point,''
end