module OxMlk
  class Elem
    PROCS = (Hash.new {|h,k| default_proc(k)}).merge(
      Integer => :to_i.to_proc,
      Float => :to_f.to_proc,
      String => :to_s.to_proc,
      Symbol => :to_sym.to_proc,
      :raw => proc {|e| e},
      :name => proc {|e| e.name},
      :value => proc {|e| e.value},
      :bool => proc {|e| fetch_bool(e.value)})
    
    attr_reader :accessor, :setter, :collection, :from, :as, :in, :procs, :block, :tag
    
    def initialize(name,o={},&blk)
      @tag = name.to_s
      @accessor = @tag.chomp('?').intern
      @setter = "#{@accessor}=".intern
      @collection = o[:as].is_a?(Array)
      
      @from = o[:from]
      @as = [*o.delete(:as)].compact
      @in = o.delete(:in)
      
      @procs = as.map {|k| PROCS[k]}
      @procs = [PROCS[:value]] + procs unless [:raw,:name,:value].include?(as.first) || ox?
      @block = blk || (collection ? proc {|x| x} : proc {|x| x.first})
    end
    
    def ox?
      return false if as.empty?
      as.all? {|x| x.ox? rescue false}
    end
    
    def content?
      @from == :content || @from == '.'
    end

    def from_xml(data)
      xml = XML::Node.from(data)
      block.call(xml.find(xpath).map do |node|
        procs.inject(node) do |n,p|
          p.call(n)
        end
      end)
    end
    
    def to_xml(data)
      value = data.send(accessor)
      
      return [] if value.nil?
      
      nodes = [*value].map do |node|
        if node.respond_to?(:to_xml)
          node.to_xml
        elsif content?
          XML::Node.new_text(node.to_s)
        else
          XML::Node.new(tag, node.to_s)
        end
      end
      return [] if nodes.empty?
      @in ? [nodes.inject(XML::Node.new(@in)) {|o,n| o << n}] : nodes
    end
    
    def xpath
      wrap case @from
      when nil
        ox? ? as.map(&:ox_tag).join('|') : tag
      when String
        from
      when :content
        '.'
      end
    end
    
    def self.fetch_bool(value)
      value = value.to_s.downcase
      return true if %w{true yes 1 t}.include? value
      return false if %w{false no 0 f}.include? value
      value
    end
    
    def self.default_proc(value)
      return value if value.is_a?(Proc)
      return proc {|x| value.from_xml(x) rescue x} if (value.ox? rescue false)
      return value.to_proc rescue proc {|x| x} if value.respond_to?(:to_proc)
      proc {|x| x.value}
    end
    
  private
  
    def wrap(xpath)
      (xpath.split('|').map {|x| [@in,x].compact.join('/') }).join('|')
    end
  end
end