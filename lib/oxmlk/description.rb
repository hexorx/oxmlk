module OxMlk

  class Description
    PROCESSORS = {
      :content => proc {|x| x.to_s},
      Integer => proc {|x| x.to_i},
      Float => proc {|x| x.to_f}
    }
    
    attr_reader :xpath

    def initialize(name,o={},&block)
      @froze = o.delete(:freeze)
      @from = o.delete(:from)
      @as = o.delete(:as) || :content
      @name = name.to_s
      
      @processors = [coputed_processor, block].compact
      @is_attribute = computed_is_attribute
      @xpath = computed_xpath
    end
    
    def method_name
      @method_name ||= @name.intern
    end
    
    def froze?
      @froze ||= false
    end
    
    def writable?
      !froze?
    end
    
    def attribute?
      @is_attribute ||= false
    end
    
    def elem?
      !attribute?
    end
    
    def collection?
      @as.is_a?(Array)
    end
    
    def process(node)
      @processors.inject(node) do |memo,processor|
        case processor
        when Proc
          processor.call(memo)
        when Symbol
        else
          processor.from_xml(memo) rescue nil
        end
      end
    end
    
    def from_xml
      nodes = ['1','2','3'] # get the value
        
      nodes.map! {|n| process(n)}
      collection? ? nodes : nodes.first
    end
    
  protected
  
    def computed_xpath
      case @from
      when nil
        @name
      when String
        @from
      end
    end
    
    def computed_is_attribute
      @from.to_s[0,1] == '@' || @from == :attribute
    end
    
    def coputed_processor
      processor = [*@as].first
      PROCESSORS[processor] || processor
    end
  end
end