dir = File.dirname(__FILE__)

require 'rubygems'
require 'activesupport'

require File.join(dir, 'oxmlk/extensions')
require File.join(dir, 'oxmlk/xml')
require File.join(dir, 'oxmlk/attr')
require File.join(dir, 'oxmlk/elem')

module OxMlk
  
  # Adds Class and Instance methods to class the OxMlk module is included in.
  # @see ClassMethods
  # @see InstanceMethods
  def self.included(base)
    base.class_eval do
      include InstanceMethods
      extend ClassMethods
      
      @ox_attrs = []
      @ox_elems = []
    end
  end
  
  module InstanceMethods
    # Uses Attr & Elem definitions on the class to convert back into XML.
    # @return [XML::Node] XML generated from instance.
    def to_xml
      self.class.to_xml(self)
    end
  end
  
  module ClassMethods
    attr_accessor :ox_attrs, :ox_elems, :tag_proc
    
    # Adds a new {Attr} to the ox_attrs variable.
    # @param [Symbol,String] Name sets the accessor methods for this attr.
    # @param [Hash] o The options passed to {Attr#initialize}.
    # @yield [XML::Node] Block that is passed to {Attr#initialize}.
    # @see Attr
    def ox_attr(name,o={},&block)
      new_attr =  Attr.new(name, o.reverse_merge(:tag_proc => @tag_proc),&block)
      @ox_attrs << new_attr
      attr_accessor new_attr.accessor
    end
    
    # Adds a new {Elem} to the ox_attrs variable.
    # @param [Symbol,String] Name sets the accessor methods for this elem.
    # @param [Hash] o The options passed to {Elem#initialize}.
    # @yield [XML::Node] Block that is passed to {Elem#initialize}.
    # @see Elem
    def ox_elem(name,o={},&block)
      new_elem =  Elem.new(name, o.reverse_merge(:tag_proc => @tag_proc),&block)
      @ox_elems << new_elem
      attr_accessor new_elem.accessor
    end
    
    # Sets xml tag to use for class when parsing. 
    # If passed a Proc or a Symbol that responds to #to_proc
    # it will set @tag_proc for use on attrs and elems.
    # @param [Symbol,String,Proc,nil] tag (nil)
    #   If a String is passed it sets @ox_tag to the String.
    #   When a Symbol/Proc/Nil is passed it sets @ox_tag to 
    #   (block || tag || :to_s).to_proc.call(Class.to_s)
    #   now if that doesn't work it sets @ox_tag to tag.to_s.
    # @yield [String] Block that @tag_proc is set to if tag is nil.
    # @raise [Exception] It will raise 'you passed something weird'
    #   when you pass something you shouldn't.
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
    # @return [true] Always returns true.
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