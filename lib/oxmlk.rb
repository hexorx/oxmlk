dir = File.dirname(__FILE__)
require File.join(dir, 'oxmlk/xml')
require File.join(dir, 'oxmlk/description')
require 'activesupport'

module OxMlk
  
  def self.included(base)
    base.extend ClassMethods
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
    
    def from_xml(data)
      xml = XML::Node.from(data)
      p [xml.name, ox_tag]
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
    
    def ox_attributes
      ox_attrs.select {|x| x.attribute?}
    end
    
    def ox_elems
      ox_attrs.select {|x| x.elem?}
    end
    
    def ox_tag(tag=false)
      @ox_tag ||= (tag || self).to_s
    end
    
  end
  
end