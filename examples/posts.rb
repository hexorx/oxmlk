#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + '/../spec/spec_helper')

class Post
  include OxMlk
  
  ox_tag :post
  
  ox_attr :href
  ox_attr :hash
  ox_attr :description
  ox_attr :tag
  ox_attr :created_at, :from => 'time', :as => Time
  ox_attr :other, :as => Integer
  ox_attr :extended
end

class Response
  include OxMlk
  
  ox_tag :posts
  
  ox_attr :user
  ox_attr :tag
  
  ox_elem :posts, :as => [Post]
end

response = Response.from_xml(xml_for(:posts))

puts response.user

response.posts.each do |post|
  puts post.description, post.href, post.extended, ''
end