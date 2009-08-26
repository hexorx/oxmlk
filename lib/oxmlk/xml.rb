require 'libxml'
require 'pathname'
require 'cgi'

module OxMlk
  module XML
    Document = LibXML::XML::Document
    Node = LibXML::XML::Node
    Parser = LibXML::XML::Parser
    Error = LibXML::XML::Error
    
    class Node
      def self.from(data)
        case data
        when XML::Document
          data.root
        when XML::Node
          data
        when File
          XML::Parser.io(data).parse.root
        when Pathname, URI
          XML::Parser.file(data.to_s).parse.root
        when String
          XML::Parser.string(data).parse.root
        else
          raise 'Invalid XML data'
        end
      end
      
      def self.build(name,nodes=[],attributes={})
        node = new(name)
        nodes.each {|n| node << n}
        attributes.each {|x| node[x.first.to_s] = x.last.to_s unless x.last.to_s.blank?}
        node
      end
    end
  end
end