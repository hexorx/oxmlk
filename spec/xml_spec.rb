require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe OxMlk::XML::Node, '#from' do
  before(:all) do
    @xml = xml_for(:posts)
  end
  
  it 'should parse an XML::Document' do
    data = OxMlk::XML::Document.new
    node = OxMlk::XML::Node.new(:name)
    data.root = node
    OxMlk::XML::Node.from(data).should be_a(OxMlk::XML::Node)
  end
  
  it 'should parse an XML::Node' do
    data = OxMlk::XML::Node.new(:name)
    OxMlk::XML::Node.from(data).should be_a(OxMlk::XML::Node)
  end
  
  it 'should parse a File' do
    data = File.new(@xml)
    OxMlk::XML::Node.from(data).should be_a(OxMlk::XML::Node)
  end
  
  it 'should parse a Path' do
    data = Pathname.new(@xml)
    OxMlk::XML::Node.from(data).should be_a(OxMlk::XML::Node)
  end
  
  it 'should parse a URI' do
    data = URI.parse("file:////#{File.expand_path(File.expand_path(@xml))}")
    OxMlk::XML::Node.from(data).should be_a(OxMlk::XML::Node)
  end
  
  it 'should parse a String' do
    data = File.open(@xml).read
    OxMlk::XML::Node.from(data).should be_a(OxMlk::XML::Node)
  end
  
end