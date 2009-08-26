require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe OxMlk::Description do
  
  before(:all) do
    require example(:example)
    
    @xml = OxMlk::XML::Node.from(xml_for(:example))
    @klass = Person
  end
  
  describe '#xpath' do
    it 'should be name by default' do
      @desc = OxMlk::Description.new(:name)
      @desc.xpath.should == 'name'
    end
    
    it 'should be the string if :from is a string' do
      @desc = OxMlk::Description.new(:name, :from => 'String')
      @desc.xpath.should == 'String'
    end
    
    it 'should be @+accessor if :from is :attr' do
      @desc = OxMlk::Description.new(:name, :from => :attr)
      @desc.xpath.should == '@name'
    end
    
    it 'should be . if :from is :content' do
      @desc = OxMlk::Description.new(:name, :from => :content)
      @desc.xpath.should == '.'
    end
    
    it 'should be singular if plural name and is a collection' do
      @desc = OxMlk::Description.new(:numbers, :as => [])
      @desc.xpath.should == 'number'
    end
    
    it 'should be ox_tag if :as is a ox_object' do
      @desc = OxMlk::Description.new(:digits, :as => Number)
      @desc.xpath.should == 'number'
    end
    
    it 'should be list of ox_tag if :as is an array of ox_objects' do
      @desc = OxMlk::Description.new(:digits, :as => [Number,Person])
      @desc.xpath.should == 'number|person'
    end
    
    it 'should add in + / to xpath if :in is passed' do
      @desc = OxMlk::Description.new(:person, :in => :friends)
      @desc.xpath.should == 'friends/person'
    end
  end
  
  describe '#accessor' do
    it 'should be attr name as Symbol' do
      @desc = OxMlk::Description.new(:name)
      @desc.accessor.should == :name
    end
  end
  
  describe '#setter' do
    it 'should be accessor with = on the end' do
      @desc = OxMlk::Description.new(:name)
      @desc.setter.should == :'name='
    end
  end
  
  describe '#instance_variable' do
    it 'should be accessor with @ on the front' do
      @desc = OxMlk::Description.new(:name)
      @desc.instance_variable.should == :'@name'
    end
  end
  
  describe '#writable?' do
    it 'should be true by default' do
      @desc = OxMlk::Description.new(:name)
      @desc.writable?.should be_true
    end
    
    it 'should be true if :freeze is false' do
      @desc = OxMlk::Description.new(:name, :freeze => false)
      @desc.writable?.should be_true
    end
    
    it 'should be false if :freeze is true' do
      @desc = OxMlk::Description.new(:name, :freeze => true)
      @desc.writable?.should be_false
    end
  end
  
  describe '#attribute?' do
    it 'should be true if :from starts with @' do
      @desc = OxMlk::Description.new(:name, :from => '@name')
      @desc.attribute?.should be_true
    end
    
    it 'should be true if :from is :attribute' do
      @desc = OxMlk::Description.new(:name, :from => :attr)
      @desc.attribute?.should be_true
    end
  end
  
  describe '#elem?' do
    it 'should be true if attribute? is false' do
      @desc = OxMlk::Description.new(:name)
      @desc.elem?.should be_true
    end
    
    it 'should be false if attribute? is true' do
      @desc = OxMlk::Description.new(:name, :from => :attr)
      @desc.elem?.should be_false
    end
  end
  
  describe '#ox_type' do
    it 'should be :elem if elem? is true' do
      @desc = OxMlk::Description.new(:name)
      @desc.ox_type.should == :elem
    end
    
    it 'should be :attribute if attribute? is true' do
      @desc = OxMlk::Description.new(:name, :from => :attr)
      @desc.ox_type.should == :attribute
    end
  end
  
  describe '#collection?' do
    it 'should be true if :as is an Array' do
      @desc = OxMlk::Description.new(:name, :as => [])
      @desc.collection?.should be_true
    end
    
    it 'should be false if :as is not Array' do
      @desc = OxMlk::Description.new(:name)
      @desc.collection?.should be_false
    end
  end
  
  describe '#ox_object?' do
    it 'should be true if :as responds to from_xml' do
      @desc = OxMlk::Description.new(:number, :as => Person)
      @desc.ox_object?.should be_true
    end
    
    it 'should be true if :as is an array of objects that respond to from_xml' do
      @desc = OxMlk::Description.new(:number, :as => [Person,Number])
      @desc.ox_object?.should be_true
    end
    
    it 'should be false if :as does not responds to from_xml' do
      @desc = OxMlk::Description.new(:number, :as => 1)
      @desc.ox_object?.should be_false
    end
    
    it 'should be false if any of the items in :as array do not respond to from_xml' do
      @desc = OxMlk::Description.new(:number, :as => [Person,Number,1])
      @desc.ox_object?.should be_false
    end
  end
  
  describe '#content?' do
    it 'should return true if :from is :content' do
      @desc = OxMlk::Description.new(:number, :from => :content)
      @desc.content?.should be_true
    end
    
    it 'should return true if :from is "."' do
      @desc = OxMlk::Description.new(:number, :from => '.')
      @desc.content?.should be_true
    end
    
    it 'should return false if :from is nil' do
      @desc = OxMlk::Description.new(:number)
      @desc.content?.should be_false
    end
    
    it 'should return false if :from is string other than "."' do
      @desc = OxMlk::Description.new(:number, :from => 'hi')
      @desc.content?.should be_false
    end
  end
  
  describe '#from_xml' do
    
    it 'should accept xml argument' do
      @desc = OxMlk::Description.new(:name)
      @desc.from_xml(@xml, @klass.new).should be_a(String)
    end
    
    it 'should return an array if :as is an array' do
      @desc = OxMlk::Description.new(:name, :as => [])
      @desc.from_xml(@xml, @klass.new).should be_an(Array)
    end
    
    it 'should return a String if :as is :value' do
      @desc = OxMlk::Description.new(:name, :as => :value)
      @desc.from_xml(@xml, @klass.new).should be_an(String)
    end
    
    it 'should return a String if :as is nil' do
      @desc = OxMlk::Description.new(:name)
      @desc.from_xml(@xml, @klass.new).should be_an(String)
    end
    
    it 'should return an Integer if :as is Integer' do
      @desc = OxMlk::Description.new(:name, :as => Integer)
      @desc.from_xml(@xml, @klass.new).should be_an(Integer)
    end
    
    it 'should return an Float if :as is Float' do
      @desc = OxMlk::Description.new(:name, :as => Float)
      @desc.from_xml(@xml, @klass.new).should be_an(Float)
    end
    
    it 'should return an Array of Integers if :as is [Integer]' do
      @desc = OxMlk::Description.new(:name, :as => [Integer])
      @desc.from_xml(@xml, @klass.new).each do |x|
        x.should be_an(Integer)
      end
    end
    
    it 'should run procs passed to :as' do
      @desc = OxMlk::Description.new(:name, :as => proc {|x| 'hi'})
      @desc.from_xml(@xml, @klass.new).should == 'hi'
    end
    
    it 'should run method when symbol is passed to :as' do
      @desc = OxMlk::Description.new(:name, :as => :say_hello)
      @desc.from_xml(@xml, @klass.new).should == 'hello'
    end
    
    it 'should return an OxMlk object if one is passed to :as' do
      @desc = OxMlk::Description.new(:number, :as => Number)
      @desc.from_xml(@xml, @klass.new).should be_a(Number)
    end
    
    it 'should match class to ox_tag if array of ox_objects is passed to :as' do
      @desc = OxMlk::Description.new(:contact, :as => [Number,Email])
      @desc.from_xml(@xml, @klass.new).first.should be_a(Number)
    end
  end
  
  describe '#to_xml' do
    before(:all) do
      @ox = Person.from_xml(@xml)
      @attr = Person.ox_attributes.first
      @elem = Person.ox_elems.first
    end
    
    it 'should return an Array of Strings if it is an attribute' do
      @attr.to_xml(@ox).should be_a(Array)
      @attr.to_xml(@ox).first.should be_a(String)
    end
    
    it 'should return an Array of nodes if it is an elem' do
      @elem.to_xml(@ox).should be_a(Array)
      @elem.to_xml(@ox).first.should be_a(OxMlk::XML::Node)
    end
  end
end
