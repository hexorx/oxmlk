require File.dirname(__FILE__) + '/../spec_helper'

describe OxMlk::Elem do
  describe '#accessor' do
    it 'should be attr name as Symbol' do
      ox_elem.accessor.should == :name
    end
  end
  
  describe '#setter' do
    it 'should be name + = as Symbol' do
      ox_elem.setter.should == :'name='
    end
  end
  
  describe '#ox?' do
    it 'should be true if :as class is ox?' do
      ox_elem(:name, :as => OxKlass).ox?.should be_true
    end
    
    it 'should be true if :as is an array of ox objects' do
      ox_elem(:name, :as => [OxKlass]).ox?.should be_true
    end
    
    it 'should be false if :as does not responds to ox?' do
      ox_elem(:name, :as => 1).ox?.should be_false
    end
    
    it 'should be false if any of the items in :as array do not respond to from_xml' do
      ox_elem(:name, :as => [OxKlass,1]).ox?.should be_false
    end
  end
  
  describe '#from_xml' do
    before(:all) do
      @xml = OxMlk::XML::Node.from(xml_for(:example))
    end
    
    it 'should default to :value' do
      ox_elem.from_xml(@xml).should == 'Joe'
    end
    
    it 'should return a :value if :as is :value' do
      ox_elem(:name, :as => :value).from_xml(@xml).should == 'Joe'
    end
    
    it 'should return an Integer if :as is Integer' do
      ox_elem(:name, :as => Integer).from_xml(@xml).should be_an(Integer)
    end
    
    it 'should return an Float if :as is Float' do
      ox_elem(:name, :as => Float).from_xml(@xml).should be_an(Float)
    end
    
    it 'should return an Array of Integers if :as is [Integer]' do
      ox_elem(:name, :as => [Integer]).from_xml(@xml).each do |x|
        x.should be_an(Integer)
      end
    end
    
    it 'should run procs passed to :as' do
      ox_elem(:name, :as => proc {|x| 'hi'}).from_xml(@xml).should == 'hi'
    end
    
    it 'should return an OxMlk object if one is passed to :as' do
      ox_elem(:name, :as => OxKlass).from_xml(@xml).should be_a(OxKlass)
    end
    
    it 'should match class to ox_tag if array of ox_objects is passed to :as' do
      ox_elem(:contact, :as => [Email,Number]).from_xml(@xml).first.should be_a(Number)
    end
    
    it 'should turn symbol to proc if possible' do
      ox_elem(:name, :as => :to_i).from_xml(@xml).should be_a(Integer)
    end
    
    it 'should return true || false if :bool is passed to :as' do
      ox_elem(:lame, :as => :bool).from_xml(@xml).should be_false
    end
    
    it 'should be bool if name ends with ?' do
      ox_elem(:lame?).from_xml(@xml).should be_false
    end
  end
  
  describe '#to_xml' do
    before(:all) do
      require example(:example)
      @ox = Person.from_xml(xml_for(:example))
      @elem = Person.ox_elems.first
    end
    
    it 'should return an Array of nodes if it is an elem' do
      @elem.to_xml(@ox).should be_a(Array)
      @elem.to_xml(@ox).first.should be_a(OxMlk::XML::Node)
    end
  end
  
  describe '#xpath' do
    it 'should be name by default' do
      ox_elem.xpath.should == 'name'
    end
    
    it 'should be the string if :from is a string' do
      ox_elem(:name, :from => 'String').xpath.should == 'String'
    end
    
    it 'should be . if :from is :content' do
      ox_elem(:name, :from => :content).xpath.should == '.'
    end
    
    it 'should be ox_tag if :as is a ox_object' do
      ox_elem(:name, :as => OxKlass).xpath.should == 'name'
    end
    
    it 'should be list of ox_tag if :as is an array of ox_objects' do
      ox_elem(:name, :as => [OxKlass,OxKlass]).xpath.should == 'name|name'
    end
    
    it 'should add :in + / to xpath if :in is passed' do
      ox_elem(:name, :in => :friends).xpath.should == 'friends/name'
    end
    
    it 'should add :in + / to all items in array of ox objects' do
      ox_elem(:name, :as => [OxKlass,OxKlass], :in => :friends).xpath.should == 'friends/name|friends/name'
    end
    
    it 'should be :tag_proc.call(name) if :tag_proc is set' do
      ox_elem(:name, :tag_proc => :upcase).xpath.should == 'NAME'
    end
  end
end

def ox_elem(name=:name,o={})
  OxMlk::Elem.new(name,o)
end

class OxKlass
  include OxMlk
  
  ox_tag :name
end

class Number
  include OxMlk
  
  ox_tag :number
end

class Email
  include OxMlk
  
  ox_tag :email
end