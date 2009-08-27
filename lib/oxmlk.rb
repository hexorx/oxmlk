dir = File.dirname(__FILE__)
require File.join(dir, 'oxmlk/xml')
require File.join(dir, 'oxmlk/description')
require 'activesupport'

module OxMlk
  
  def self.included(base)
    base.class_eval do
      include InstanceMethods
      extend ClassMethods
    end
  end
  
  module InstanceMethods
    def to_xml
      self.class.to_xml(self)
    end
  end
  
  module ClassMethods
    def ox_attrs
      @ox_attrs ||= []
    end
    
    def ox_attr(name,o={})
      new_attr =  Description.new(name, o)
      ox_attrs << new_attr
      attr new_attr.accessor, new_attr.writable?
    end
    
    def ox_attributes
      ox_attrs.select {|x| x.attribute?}
    end
    
    def ox_elems
      ox_attrs.select {|x| x.elem?}
    end
    
    def ox_tag(tag=false)
      @ox_tag ||= (tag || self).to_s.split('::').last
    end
    
    def xml_array(data)
      [ ox_tag, 
        ox_elems.map {|x| x.to_xml(data)}.flatten,
        ox_attributes.map {|x| x.to_xml(data)} ]
    end
    
    def from_xml(data)
      xml = XML::Node.from(data)
      raise 'invalid XML' unless xml.name == ox_tag
      
      ox = new
      ox_attrs.each do |a|
        value = a.from_xml(xml,ox)
        if ox.respond_to?(a.setter)
          ox.send(a.setter,value)
        else
          ox.instance_variable_set(a.instance_variable,value)
        end
      end
      ox
    end
    
    def to_xml(data)
      XML::Node.build(*xml_array(data))
    end
    
  end
  
end