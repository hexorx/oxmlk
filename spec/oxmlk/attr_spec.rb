require File.dirname(__FILE__) + '/../spec_helper'

describe OxMlk::Attr do
  describe '#accessor' do
    it 'should be attr name as Symbol' do
      ox_attr.accessor.should == :name
    end
  end
  
  describe '#setter' do
    it 'should be name + = as Symbol' do
      ox_attr.setter.should == :'name='
    end
  end
  
  describe '#from_xml' do
    it 'should return attr with name by default' do
      ox_attr.from_xml('<test name="joe"/>').should == 'joe'
    end
    
    it 'should return attr by :from if specified' do
      ox_attr(:name, :from => 'firstName').from_xml('<test firstName="joe"/>').should == 'joe'
    end
    
    it 'should return type specified in :as' do
      ox_attr(:age, :as => Integer).from_xml('<test age="30"/>').should == 30
      ox_attr(:age, :as => Float).from_xml('<test age="30"/>').should == 30.0
      ox_attr(:age, :as => String).from_xml('<test age="30"/>').should == '30'
      ox_attr(:age, :as => Symbol).from_xml('<test age="30"/>').should == :'30'
    end
    
    it 'should return true or false if :as is :bool' do
      ox_attr(:odd, :as => :bool).from_xml('<test odd="true"/>').should == true
      ox_attr(:odd, :as => :bool).from_xml('<test odd="false"/>').should == false
    end
    
    it 'should act like a bool if name ends in ? and :as is not set' do
      ox_attr(:odd?).from_xml('<test odd="true"/>').should == true
      ox_attr(:odd?).from_xml('<test odd="false"/>').should == false
    end
  end
  
  describe '#tag' do
    it 'should be :from if set' do
      ox_attr(:name, :from => 'FullName').tag.should == 'FullName'
    end
    
    it 'should default to name cleaned up' do
      ox_attr(:name).tag.should == 'name'
    end
    
    it 'should apply :tag_proc if set' do
      ox_attr(:name, :tag_proc => :upcase.to_proc).tag.should == 'NAME'
    end
  end
end

def ox_attr(name=:name,o={})
  OxMlk::Attr.new(name,o)
end