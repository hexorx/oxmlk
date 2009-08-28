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
      alias_method :value, :content
      
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
    end
  end
end