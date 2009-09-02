#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + '/../spec/spec_helper')

class User
  include OxMlk
  
  ox_tag :user
  
  ox_elem :id, :as => Integer
  ox_elem :name
  ox_elem :screen_name
  ox_elem :location
  ox_elem :description
  ox_elem :profile_image_url
  ox_elem :url
  ox_elem :protected?
  ox_elem :followers_count, :as => Integer
end
 
class Status
  include OxMlk
  
  ox_tag :status
     
  ox_elem :id, :as => Integer
  ox_elem :text
  ox_elem :created_at, :as => Time
  ox_elem :source
  ox_elem :truncated?
  ox_elem :in_reply_to_status_id, :as => Integer
  ox_elem :in_reply_to_user_id, :as => Integer
  ox_elem :favorited?
  ox_elem :user, :as => User
end
 
class Response
  include OxMlk
  
  ox_tag 'statuses'
  
  ox_elem :statuses, :as => [Status]
end

response = Response.from_xml(xml_for(:twitter))

response.statuses.each do |status|
  puts "#{status.user.screen_name} - #{status.created_at}", status.text, ''
end