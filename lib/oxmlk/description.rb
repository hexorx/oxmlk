module OxMlk

  class Description
    PROCESSORS = {
      :elem => {
        :value => proc {|x| x.content rescue nil},
        Integer => proc {|x| x.content.to_i rescue nil},
        Float => proc {|x| x.content.to_f rescue nil}
      },
      :attribute => {
        :value => proc {|x| x.value rescue nil} 
      }
    }
    
    attr_reader :xpath

    def initialize(name,o={},&block)
      @froze = o.delete(:freeze)
      @from = o.delete(:from)
      @as = o.delete(:as)
      @wrapper = o.delete(:wrapper)
      @name = name.to_s
      
      @is_attribute = computed_is_attribute
      @processors = [coputed_processor, block].compact
      @xpath = computed_xpath
    end
    
    def accessor
      @accessor ||= @name.intern
    end
    
    def setter
      :"#{accessor}="
    end
    
    def instance_variable
      :"@#{accessor}"
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
    
    def ox_type
      elem? ? :elem : :attribute
    end
    
    def collection?
      @as.is_a?(Array)
    end
    
    def ox_object?
      return false if [*@as].empty?
      [*@as].all? {|x| x.respond_to?(:from_xml)}
    end
    
    def process(node,instance)
      @processors.inject(node) do |memo,processor|
        case processor
        when Proc
          processor.call(memo)
        when Symbol
          instance.send(processor,memo)
        else
          processor.from_xml(memo)
        end
      end
    end
    
    def from_xml(data,instance)
      xml = XML::Node.from(data)
      nodes = xml.find(@xpath)
      return nil if nodes.first.nil?
      return process(nodes.first,instance) unless collection?
      (nodes).map {|n| process(n,instance)}
    end
    
  protected
  
    def computed_xpath
      wrap case @from
      when nil
        if ox_object?
          [*@as].map(&:ox_tag).join('|')
        elsif collection?
          @name.to_s.singularize
        else
          @name.to_s
        end
      when String
        @from
      when :attr
        "@#{accessor}"
      when :content
        '.'
      end
    end
    
    def computed_is_attribute
      @from.to_s[0,1] == '@' || @from == :attr
    end
    
    def coputed_processor
      return proc {|x| Hash[*@as.map{|o| [o.ox_tag,o]}.flatten][x.name].from_xml(x) } if collection? && ox_object?
      processor = [*@as].first || :value
      PROCESSORS[ox_type][processor] || processor
    end
    
    def wrap(xpath=nil)
      [@wrapper,xpath].compact.join('/')
    end
  end
end