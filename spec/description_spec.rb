require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

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
    
    before do
      @xml = OxMlk::XML::Node.new('')
      @klass = Class.new do
        include OxMlk

        def self.to_s
          'Klass'
        end

        def say_hello(value)
          'hello'
        end
      end
    end
    
    it 'should accept xml argument' do
      @desc = OxMlk::Description.new(:name)
      @desc.from_xml(@xml, @klass.new).should be_a(String)
    end
    
    it 'should return an array if :as is an array' do
      @desc = OxMlk::Description.new(:name, :as => [])
      @desc.from_xml(@xml, @klass.new).should be_an(Array)
    end
    
    it 'should return a String if :as is :content' do
      @desc = OxMlk::Description.new(:name, :as => :content)
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
    
  end
end
