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

describe OxMlk::XML::Node, '#build' do
  before(:all) do
    @node = OxMlk::XML::Node
    @nodes = [@node.new('one'),@node.new('two'),@node.new('three')]
    @attributes = [[1,2],[3,4]]
    @args = ['name',@nodes,@attributes]
  end
  
  it 'should return a new node' do
    @node.build(*@args).should be_a(@node)
  end
  
  it 'should set its name to the first argument' do
    @node.build(*@args).name.should == 'name'
  end
  
  it 'should set its children to second argument' do
    @node.build(*@args).children.should == @nodes
  end
  
  it 'should set its attributes to the third argument' do
    @node.build(*@args).should be_attributes
  end
end

describe OxMlk::XML::Node, '#value' do
  before(:all) do
    @node = OxMlk::XML::Node.new('test')
  end
  
  it 'should be the same as content' do
    @node.value.should == @node.content
  end
end