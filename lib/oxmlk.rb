dir = File.dirname(__FILE__)

require 'rubygems'
require 'activesupport'

require File.join(dir, 'oxmlk/extensions')
require File.join(dir, 'oxmlk/xml')
require File.join(dir, 'oxmlk/attr')
require File.join(dir, 'oxmlk/elem')

# Mixin to add annotation methods to you ruby classes.
# See {ClassMethods#ox_tag ox_tag}, {ClassMethods#ox_attr ox_attr} and {ClassMethods#ox_elem ox_elem} for available annotations.
module OxMlk

private
  
  def self.included(base)
    base.class_eval do
      include InstanceMethods
      extend ClassMethods
      
      @ox_attrs = []
      @ox_elems = []
    end
  end
  
  module InstanceMethods
    
    # Returns a LibXML::XML::Node representing this object
    def to_xml
      self.class.to_xml(self)
    end
  end
  
  # This class defines the annotation methods that are mixed into your Ruby classes for XML mapping information and behavior.
  # See {ClassMethods#ox_tag ox_tag}, {ClassMethods#ox_attr ox_attr} and {ClassMethods#ox_elem ox_elem} for available annotations.
  module ClassMethods
    attr_accessor :ox_attrs, :ox_elems, :tag_proc
    
    # Declares a reference to a certain xml attribute.
    def ox_attr(name,o={},&block)
      new_attr =  Attr.new(name, o.reverse_merge(:tag_proc => @tag_proc),&block)
      @ox_attrs << new_attr
      attr_accessor new_attr.accessor
    end
    
    # Declares a reference to a certain xml element or a typed collection of elements.
    #
    # == Sym Option
    # [sym] Symbol representing the name of the accessor.
    #
    # === Default naming
    # This name will be the default node searched for, if no other is declared. For example:
    #
    #  ox_elem :bob
    #  ox_elem :pony
    #
    # are equivalent to:
    #
    #  ox_elem :bob, :from => 'bob'
    #  ox_elem :pony, :from => 'pony'
    #
    # === Boolean attributes
    # If the name ends in a ?, ROXML will attempt to coerce the value to true or false,
    # with true, yes, t and 1 mapping to true and false, no, f and 0 mapping
    # to false, as shown below:
    #
    #  ox_elem :desirable?
    #  ox_attr :bizzare?, :from => 'BIZZARE'
    #
    #  x = #from_xml(%{
    #    <object BIZZARE="1">
    #      <desirable>False</desirable>
    #    </object>
    #  })
    #
    #  x.desirable?
    #  => false
    #  x.bizzare?
    #  => true
    #
    # When a block is provided the value will be passed to the block 
    # where unexpected values can be handled. If no block is provided
    # the unexpected value will be returned.
    #
    #  #from_xml(%{
    #    <object>
    #      <desirable>Dunno</desirable>
    #    </object>
    #  }).desirable?
    #  => "Dunno"
    #
    #  ox_elem :strange? do |val|
    #    val.upcase
    #  end
    #
    #  #from_xml(%{
    #    <object>
    #      <strange>Dunno</strange>
    #    </object>
    #  }).strange?
    #  => "DUNNO"
    #
    # == Blocks
    # You may also pass a block which manipulates the associated parsed value.
    #
    #  class Muffins
    #    include OxMlk
    #
    #    ox_elem(:count, :from => 'bakers_dozens') {|val| val.first.to_i * 13 }
    #  end
    #
    # Blocks are always passed an Array and ar the last thing to manipulate the XML.
    # The array will include all elements already manipulated by anything passed to
    # the :as option. If the :as option is an Array and no block is passed then the
    # block defaults to proc {|x| x} returning the Array. If the :as option is nil or
    # is not an Array then the block is set to proc {|x| x.first} returning the first
    # element only.
    #
    # == Options
    # === :as
    # ==== Basic Types
    # Allows you to specify one of several basic types to return the value as. For example
    #
    #  ox_elem :count, :as => Integer
    #
    # is equivalent to:
    #
    #  ox_elem(:count) {|val| Integer(val.first) unless val.first.empty?}
    #
    # Such block shorthands for Integer, Float, String, Symbol and Time
    # are currently available.
    #
    # To reference many elements, put the desired type in a literal array. e.g.:
    #
    #   ox_elem :counts, :as => [Integer]
    #
    # Even an array of text nodes can be specified with :as => []
    #
    #   ox_elem :quotes, :as => []
    #
    # === Other OxMlk Classes
    # Declares an accessor that represents another OxMlk class as child XML element
    # (one-to-one or composition) or array of child elements (one-to-many or
    # aggregation) of this type. Default is one-to-one. For one-to-many, simply pass the class
    # as the only element in an array. You can also put several OxMlk classes in an Array that
    # will act like a polymorphic one-to-many association.
    #
    # Composition example:
    #  <book>
    #   <publisher>
    #     <name>Pragmatic Bookshelf</name>
    #   </publisher>
    #  </book>
    #
    # Can be mapped using the following code:
    #   class Book
    #     include OxMlk
    #     ox_elem :publisher, :as => Publisher
    #   end
    #
    # Aggregation example:
    #  <library>
    #   <books>
    #    <book/>
    #    <book/>
    #   </books>
    #  </library>
    #
    # Can be mapped using the following code:
    #   class Library
    #     include OxMlk
    #     ox_elem :books, :as => [Book], :in => 'books'
    #   end
    #
    # If you don't have the <books> tag to wrap around the list of <book> tags:
    #   <library>
    #     <name>Ruby books</name>
    #     <book/>
    #     <book/>
    #   </library>
    #
    # You can skip the wrapper argument:
    #    ox_elem :books, :as => [Book]
    #
    # ==== Hash
    # Unlike ROXML, OxMlk doesn't do anything special for hashes. However OxMlk
    # applies :as to each element and the block once to the Array of elements.
    # This means OxMlk can support setting hashes but it is more of a manual process.
    # I am looking for a easier method but for now here are a few examples:
    #
    # ===== Hash of element contents
    # For xml such as this:
    #
    #    <dictionary>
    #      <definition>
    #        <word/>
    #        <meaning/>
    #      </definition>
    #      <definition>
    #        <word/>
    #        <meaning/>
    #      </definition>
    #    </dictionary>
    #
    # This is actually one of the more complex ones. It uses the :raw keyword to pass the block an array of LibXML::XML::Nodes
    #   ox_elem(:definitions, :from => 'definition', :as => [:raw]) do |vals|
    #     Hash[*vals.map {}|val| [val.search('word').content,val.search('meaning').content]}.flatten]
    #   end
    #
    # ===== Hash of :content
    # For xml such as this:
    #
    #   <dictionary>
    #     <definition word="quaquaversally">adjective: (of a geological formation) sloping downward from the center in all directions.</definition>
    #     <definition word="tergiversate">To use evasions or ambiguities; equivocate.</definition>
    #   </dictionary>
    #
    # This one can also be accomplished with the :raw keyword and a fancy block.
    #   ox_elem(:definitions, :from => 'definition', :as => [:raw]) {|x| Hash[*x.map {|val| [val['word'],val.content] }.flatten]}
    #
    # ===== Hash of :name
    # For xml such as this:
    #
    #    <dictionary>
    #      <quaquaversally>adjective: (of a geological formation) sloping downward from the center in all directions.</quaquaversally>
    #      <tergiversate>To use evasions or ambiguities; equivocate.</tergiversate>
    #    </dictionary>
    #
    # This one requires some fancy xpath in :from to grab all the elements
    #    ox_elem(:definitions, :from => './*', :as => [:raw]) {|x| Hash[*x.map {|val| [val.name,val.content] }.flatten]}
    #
    # === :from
    # The name by which the xml value will be found in XML. Default is sym.
    #
    # This value may also include XPath notation.
    #
    # ==== :from => :content
    # When :from is set to :content, this refers to the content of the current node,
    # rather than a sub-node. It is equivalent to :from => '.'
    #
    # Example:
    #  class Contributor
    #    ox_elem :name, :from => :content
    #    ox_attr :role
    #  end
    #
    # To map:
    #  <contributor role="editor">James Wick</contributor>
    #
    # === :in
    # An optional name of a wrapping tag for this XML accessor.
    # This can include other xpath values, which will be joined with :from with a '/'
    def ox_elem(name,o={},&block)
      new_elem =  Elem.new(name, o.reverse_merge(:tag_proc => @tag_proc),&block)
      @ox_elems << new_elem
      attr_accessor new_elem.accessor
    end
    
    # Sets the name of the XML element that represents this class. Use this
    # to override the default camelcase class name.
    #
    # Example:
    #  class BookWithPublisher
    #   ox_tag 'book'
    #  end
    #
    # Without the ox_tag annotation, the XML mapped tag would have been 'BookWithPublisher'.
    #
    # Most xml documents have a consistent naming convention, for example, the node and
    # and attribute names might appear in CamelCase. ox_tag enables you to adapt
    # the oxmlk default names for this object to suit this convention.  For example,
    # if I had a document like so:
    #
    #  <XmlDoc>
    #    <MyPreciousData />
    #    <MoreToSee />
    #  </XmlDoc>
    #
    # Then I could access it's contents by defining the following class:
    #
    #  class XmlDoc
    #    include OxMlk
    #
    #    ox_tag :camelcase
    #    ox_elem :my_precious_data
    #    ox_elem :more_to_see
    #  end
    #
    # You may supply a block or any #to_proc-able object as the argument,
    # and it will be called against the default node and attribute names before searching
    # the document. Here are some example declaration:
    #
    #  ox_tag :upcase
    #  ox_tag &:camelcase
    #  ox_tag {|val| val.gsub('_', '').downcase }
    #
    # See ActiveSupport::CoreExtensions::String::Inflections for more prepackaged formats
    def ox_tag(tag=nil,&block)
      raise 'you can only set tag or a block, not both.' if tag && block

      @base_tag ||= self.to_s.split('::').last
      @ox_tag ||= case tag
      when String
        tag
      when Proc, Symbol, nil
        @tag_proc = (block || tag || :to_s).to_proc
        @tag_proc.call(@base_tag) rescue tag.to_s
      else
        raise 'you passed something weird'
      end
    end
    
    # Used to tell if this is an OxMlk Object.
    def ox?
      true
    end
    
    # Returns a new instance from XML
    # @param [XML::Document,XML::Node,File,Pathname,URI,String] data
    #   The xml data used to create a new instance.
    # @return New instance generated from xml data passed in.
    #   Attr and Elem definitions are used to translate the xml to new object.
    def from_xml(data)
      xml = XML::Node.from(data)
      raise 'invalid XML' unless xml.name == ox_tag
      
      ox = new
      (ox_attrs + ox_elems).each {|e| ox.send(e.setter,e.from_xml(xml))}
      ox
    end
    
    # Returns XML generated from an instance based on Attr & Elem definitions.
    # @param [Object] data An instance used to populate XML
    # @return [XML::Node] Generated XML::Node  
    def to_xml(data)
      ox = XML::Node.new(ox_tag)
      ox_elems.each do |elem|
        elem.to_xml(data).each{|e| ox << e}
      end
      ox_attrs.each do |a| 
        val = data.send(a.accessor).to_s
        ox[a.tag]= val if val.present?
      end
      ox
    end
  end
  
end