require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe OxMlk do
  
  before do
    @klass = Class.new do
      include OxMlk
      
      def self.to_s
        'Klass'
      end
    end
  end
  
  describe 'being included into another class' do
    it 'should set ox_attrs to an array' do
      @klass.ox_attrs.should == []
    end
    
    it 'should add an ox_attr method' do
      @klass.should respond_to(:ox_attr)
    end
    
    it 'should add a from_xml method' do
      @klass.should respond_to(:from_xml)
    end

    it 'should add an ox_attributes method' do
      @klass.should respond_to(:ox_attributes)
    end
    
    it 'should add an ox_elems method' do
      @klass.should respond_to(:ox_elems)
    end
  end
  
  describe '#ox_attr' do
    it 'should add an OxMlk::Description to the class' do
      @klass.ox_attr(:name)
      @klass.ox_attrs.first.should be_a(OxMlk::Description)
    end
  
    it 'should add a reader method' do
      @klass.ox_attr(:name, :freeze => true)
      @klass.new.should respond_to(:name)
    end
  
    it 'should add a writter method by default' do
      @klass.ox_attr(:name)
      @klass.new.should respond_to(:name=)
    end

    it 'should add a writter method when :freeze => false' do
      @klass.ox_attr(:name, :freeze => false)
      @klass.new.should respond_to(:name=)
    end
  
    it 'should not add a writter method when :freeze => true' do
      @klass.ox_attr(:name, :freeze => true)
      @klass.new.should_not respond_to(:name=)
    end
  end
    
  describe '#from_xml' do
    it 'should return an instance of class' do
      @klass.from_xml('').should be_a(@klass)
    end
  end
  
  describe '#ox_attributes' do
    it 'should return a list of attributes' do
      @klass.ox_attr(:name_one, :from => :attribute)
      @klass.ox_attr(:name_two, :from => :attribute)
      @klass.ox_attr(:name_three)
      @klass.ox_attributes.size.should == 2
    end
  end
  
  describe '#ox_elems' do
    it 'should return a list of elements' do
      @klass.ox_attr(:name, :from => :attribute)
      @klass.ox_attr(:name, :from => :attribute)
      @klass.ox_attr(:name)
      @klass.ox_elems.size.should == 1
    end
  end
end

describe OxMlk::Description do

  describe 'xpath' do
    it 'should be name by default' do
      @desc = OxMlk::Description.new(:name)
      @desc.xpath.should == 'name'
    end
    
    it 'should be the string if :from is a string' do
      @desc = OxMlk::Description.new(:name, :from => 'String')
      @desc.xpath.should == 'String'
    end
  end
  
  describe 'method_name' do
    it 'should be name symbolized' do
      @desc = OxMlk::Description.new('name')
      @desc.method_name.should == :name
    end
  end
  
  describe 'writable?' do
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
  
  describe 'attribute?' do
    it 'should be true if :from starts with @' do
      @desc = OxMlk::Description.new(:name, :from => '@name')
      @desc.attribute?.should be_true
    end
    
    it 'should be true if :from is :attribute' do
      @desc = OxMlk::Description.new(:name, :from => :attribute)
      @desc.attribute?.should be_true
    end
  end
  
  describe 'elem?' do
    it 'should be true if attribute? is false' do
      @desc = OxMlk::Description.new(:name)
      @desc.elem?.should be_true
    end
    
    it 'should be false if attribute? is true' do
      @desc = OxMlk::Description.new(:name, :from => :attribute)
      @desc.elem?.should be_false
    end
  end
  
  describe 'collection?' do
    it 'should be true if :as is an Array' do
      @desc = OxMlk::Description.new(:name, :as => [])
      @desc.collection?.should be_true
    end
    
    it 'should be false if :as is not Array' do
      @desc = OxMlk::Description.new(:name)
      @desc.collection?.should be_false
    end
  end
  
  describe 'from_xml' do
    it 'should return an array if :as is an array' do
      @desc = OxMlk::Description.new(:name, :as => [])
      @desc.from_xml.should be_an(Array)
    end
    
    it 'should return a String if :as is :content' do
      @desc = OxMlk::Description.new(:name, :as => :content)
      @desc.from_xml.should be_an(String)
    end
    
    it 'should return a String if :as is nil' do
      @desc = OxMlk::Description.new(:name)
      @desc.from_xml.should be_an(String)
    end
    
    it 'should return an Integer if :as is Integer' do
      @desc = OxMlk::Description.new(:name, :as => Integer)
      @desc.from_xml.should be_an(Integer)
    end
    
    it 'should return an Float if :as is Float' do
      @desc = OxMlk::Description.new(:name, :as => Float)
      @desc.from_xml.should be_an(Float)
    end
    
    it 'should return an Array of Integers if :as is [Integer]' do
      @desc = OxMlk::Description.new(:name, :as => [Integer])
      @desc.from_xml.each do |x|
        x.should be_an(Integer)
      end
    end
    
    it 'should run procs passed to :as' do
      @desc = OxMlk::Description.new(:name, :as => proc {|x| 'hi'})
      @desc.from_xml.should == 'hi'
    end
  end
end
