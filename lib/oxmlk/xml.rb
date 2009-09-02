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
      
      def search(xpath)
        begin
          if namespaces.default && !xpath.include?(':')
            find(namespaced(xpath),
                 default_namespace(namespaces.default.href))
          else
            find(xpath)
          end
        rescue Exception => ex
          raise ex, xpath
        end
      end
      
      def namespaced(xpath)
        xpath.between('|') do |section|
          section.between('/') do |component|
            unspaced?(component) ? default_namespace(component) : component
          end
        end
      end
      
      def default_namespace(name)
        "oxdefault:#{name}"
      end
      
      def unspaced?(component)
        component =~ /\w+/ && !component.include?(':') && !component.starts_with?('@')
      end
    end
  end
end