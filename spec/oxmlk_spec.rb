require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe OxMlk do
  
  describe "being included into another class" do
    before do
      @klass = Class.new do
        include OxMlk
      end
    end
    
    it "should set ox_attrs to an array" do
      @klass.ox_attrs.should == []
    end
    
    it "should allow adding an ox_attr" do
      @klass.ox_attr(:name)
      @klass.ox_attrs.should == [:name]
    end
    
  end
  
end
