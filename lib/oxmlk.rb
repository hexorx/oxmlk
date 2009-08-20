dir = File.dirname(__FILE__)
require File.join(dir, 'oxmlk/description')

module OxMlk
  
  def self.included(base)
    base.class_eval do
      include InstanceMethods
      extend ClassMethods
    end
  end
  
  module InstanceMethods
  end
  
  module ClassMethods
    
    def ox_attrs
      @ox_attrs ||= []
    end
    
    def ox_attr(name,o={})
      new_attr =  Description.new(name, o)
      ox_attrs << new_attr
      attr new_attr.method_name, new_attr.writable?
    end
    
    def from_xml(xml)
      new
    end
    
    def ox_attributes
      ox_attrs.select {|x| x.attribute?}
    end
    
    def ox_elems
      ox_attrs.select {|x| x.elem?}
    end
    
  end
  
end