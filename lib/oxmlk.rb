dir = File.dirname(__FILE__)

require 'activesupport'

require File.join(dir, 'oxmlk/xml')
require File.join(dir, 'oxmlk/attr')
require File.join(dir, 'oxmlk/description')

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
      new_elem =  Description.new(name, o)
      (@ox_elems ||= []) << new_elem
      attr_accessor new_elem.accessor
    end
    
    def ox_tag(tag=false)
      @ox_tag ||= (tag || self).to_s.split('::').last
    end
    
    def xml_array(data)
      [ ox_tag, 
        ox_elems.map {|x| x.to_xml(data)}.flatten,
        ox_attrs.map {|x| x.to_xml(data)} ]
    end
    
    def from_xml(data)
      xml = XML::Node.from(data)
      raise 'invalid XML' unless xml.name == ox_tag
      
      ox = new
      
      (ox_attrs + ox_elems).each do |e|
        value = e.from_xml(xml)
        if ox.respond_to?(e.setter)
          ox.send(e.setter,value)
        else
          ox.instance_variable_set(e.instance_variable,value)
        end
      end
      ox
    end
    
    def to_xml(data)
      XML::Node.build(*xml_array(data))
    end
    
  end
  
end