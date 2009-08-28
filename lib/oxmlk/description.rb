module OxMlk

  class Description
    PROCESSORS = {
      :value => proc {|x| x.value rescue nil},
      Integer => proc {|x| x.value.to_i rescue nil},
      Float => proc {|x| x.value.to_f rescue nil}
    }
    
    attr_reader :xpath

    def initialize(name,o={},&block)
      @froze = o.delete(:freeze)
      @from = o.delete(:from)
      @as = o.delete(:as)
      @in = o.delete(:in)
      @tag = o.delete(:tag)
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
    
    def content?
      @from == :content || @from == '.'
    end
    
    def ox_object?
      return false if [*@as].empty?
      [*@as].all? {|x| x.respond_to?(:from_xml)}
    end
    
    def process(node)
      @processors.inject(node) do |memo,processor|
        case processor
        when Proc
          processor.call(memo)
        else
          processor.from_xml(memo)
        end
      end
    end
    
    def from_xml(data)
      xml = XML::Node.from(data)
      nodes = xml.find(@xpath)
      return nil if nodes.first.nil?
      return process(nodes.first) unless collection?
      (nodes).map {|n| process(n)}
    end
    
    def to_xml(data)
      value = data.send(accessor)
      
      return [] if value.nil?
      return [accessor.to_s,value.to_s] if attribute?
      
      nodes = [*value].map do |node|
        if node.respond_to?(:to_xml)
          node.to_xml
        elsif content?
          XML::Node.new_text(node.to_s)
        else
          XML::Node.new(accessor, node.to_s)
        end
      end
      @in ? XML::Node.build(@in, nodes) : nodes
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
      PROCESSORS[processor] || processor
    end
    
    def wrap(xpath=nil)
      (xpath.split('|').map {|x| [@in,x].compact.join('/') }).join('|') 
    end
  end
end