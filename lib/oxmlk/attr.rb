module OxMlk
  class Attr
    PROCS = (Hash.new {|h,k| k.to_proc rescue nil}).merge(
      Integer => :to_i.to_proc,
      Float => :to_f.to_proc,
      String => :to_s.to_proc,
      Symbol => :to_sym.to_proc,
      :bool => proc {|a| fetch_bool(a)}
    )
    
    attr_reader :accessor, :setter,:from, :as, :procs, :tag
    
    def initialize(name,o={},&block)
      name = name.to_s
      @accessor = name.chomp('?').intern
      @setter = "#{@accessor}=".intern
      @from = o.delete(:from)
      @tag = (from || accessor).to_s
      @as = o.delete(:as) || (:bool if name.ends_with?('?'))
      @procs = [PROCS[@as],block].compact
    end
    
    def from_xml(data)
      procs.inject(XML::Node.from(data)[tag]) {|d,p| p.call(d) rescue d}
    end
    
    def to_xml
      [tag]
    end
    
    def self.fetch_bool(value)
      value = value.to_s.downcase
      return true if %w{true yes 1 t}.include? value
      return false if %w{false no 0 f}.include? value
      value
    end

  end
end