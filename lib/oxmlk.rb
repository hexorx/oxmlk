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
    
    def ox_attr(name)
      ox_attrs << name
    end
    
    def tag_name
      @tag_name ||= to_s.split('::')[-1].downcase
    end
  end
  
end