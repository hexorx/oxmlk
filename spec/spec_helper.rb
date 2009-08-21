$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'oxmlk'
require 'spec'
require 'spec/autorun'
require 'pathname'

Spec::Runner.configure do |config|
  
end

DIR = Pathname.new(__FILE__ + '../..').expand_path.dirname

def example(name)
  DIR.join("examples/#{name}.rb")
end

def xml_for(name)
  DIR.join("examples/xml/#{name}.xml")
end