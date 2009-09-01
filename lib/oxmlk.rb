dir = File.dirname(__FILE__)

require 'rubygems'
require 'activesupport'

require File.join(dir, 'oxmlk/xml')
require File.join(dir, 'oxmlk/attr')
require File.join(dir, 'oxmlk/elem')

module OxMlk
  
  def self.included(base)
    base.class_eval do
      include InstanceMethods
      extend ClassMethods
      
      @ox_attrs, @ox_elems = [], []
    end
  end
  
  module InstanceMethods
    def to_xml
      self.class.to_xml(self)
    end
  end
  
  module ClassMethods
    attr_accessor :ox_attrs, :ox_elems
    
    def ox_attr(name,o={})
      new_attr =  Attr.new(name, o)
      (@ox_attrs ||= []) << new_attr
      attr_accessor new_attr.accessor
    end
    
    def ox_elem(name,o={})
      new_elem =  Elem.new(name, o)
      (@ox_elems ||= []) << new_elem
      attr_accessor new_elem.accessor
    end
    
    def ox_tag(tag=false)
      @ox_tag ||= (tag || self).to_s.split('::').last
    end
    
    def ox?
      true
    end
    
    def from_xml(data)
      xml = XML::Node.from(data)
      raise 'invalid XML' unless xml.name == ox_tag
      
      ox = new
      (ox_attrs + ox_elems).each {|e| ox.send(e.setter,e.from_xml(xml))}
      ox
    end
    
    def to_xml(data)
      ox = XML::Node.new(ox_tag)
      ox_elems.each do |elem|
        elem.to_xml(data).each{|e| ox << e}
      end
      ox_attrs.each do |a| 
        val = data.send(a.accessor).to_s
        ox[a.tag]= val if val.present?
      end
      ox
    end
    
  end
  
end