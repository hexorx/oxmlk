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
  end
  
end