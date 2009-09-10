module OxMlk
  class Attr
    
    attr_reader :accessor, :setter, :from, :as, :procs, :tag_proc, :tag
    
    # Named Procs for use in :as option.
    PROCS = (Hash.new {|h,k| k.to_proc rescue nil}).merge(
      Integer => :to_i.to_proc,
      Float => :to_f.to_proc,
      String => :to_s.to_proc,
      Symbol => :to_sym.to_proc,
      :bool => proc {|a| fetch_bool(a)})
    
    # Creates a new instance of Attr to be used as a template for converting
    # XML to objects and from objects to XML
    # @param [Symbol,String] name Sets the accessor methods for this attr.
    #   It is also used to guess defaults for :from and :as.
    #   For example if it ends with '?' and :as isn't set
    #   it will treat it as a boolean.
    # @param [Hash] o the options for the new attr definition
    # @option o [Symbol,String] :from (tag_proc.call(name))
    #   Tells OxMlk what the name of the XML attribute is.
    #   It defaults to name processed by the tag_proc. 
    # @option o [Symbol,String,Proc,Array<Symbol,String,Proc>] :as
    #   Tells OxMlk how to translate the XML.
    #   The argument is coerced into a Proc and applied to the string found in the XML attribute.
    #   If an Array is passed each Proc is applied in order with the results
    #   of the first being passed to the second and so on. If it isn't set
    #   and name ends in '?' it processes it as if :bool was passed otherwise
    #   it treats it as a string with no processing.
    #   Includes the following named Procs: Integer, Float, String, Symbol and :bool.
    # @option o [Proc] :tag_proc (proc {|x| x}) Proc used to guess :from.
    #   The Proc is applied to name and the results used to find the XML attribute
    #   if :from isn't set.
    # @yield [String] Adds anothe Proc that is applied to the value.
    def initialize(name,o={},&block)
      name = name.to_s
      @accessor = name.chomp('?').intern
      @setter = "#{@accessor}=".intern
      @from = o[:from]
      @tag_proc = o[:tag_proc].to_proc rescue proc {|x| x}
      @tag = (from || (@tag_proc.call(accessor.to_s) rescue accessor)).to_s
      @as = o[:as] || (:bool if name.ends_with?('?'))
      @procs = ([*as].map {|k| PROCS[k]} + [block]).compact
    end
    
    # Finds @tag in data and applies procs.
    def from_xml(data)
      procs.inject(XML::Node.from(data)[tag]) {|d,p| p.call(d) rescue d}
    end
    
  private
    
    # Converts a value to a Boolean.
    # @param [Symbol,String,Integer] value Value to convert
    # @return [Boolean] Returns true if value is 'true', 'yes', 't' or 1.
    #   Returns false if value is 'false', 'no', 'f' or 0.
    #   If can't be convertet to a Boolean then the value is returned.
    def self.fetch_bool(value)
      value = value.to_s.downcase
      return true if %w{true yes 1 t}.include? value
      return false if %w{false no 0 f}.include? value
      value
    end

  end
end