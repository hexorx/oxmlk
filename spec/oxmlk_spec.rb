require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe OxMlk do
  
  describe "being included into another class" do
    before do
      @klass = Class.new do
        include OxMlk
        
        def self.to_s
          'fubar'
        end
      end
    end
    
    it "should set ox_attrs to an array" do
      @klass.ox_attrs.should == []
    end
    
    it "should allow adding an ox_attr" do
      @klass.ox_attr(:name)
      @klass.ox_attrs.size.should == 1
    end
    
    it "should default tag name to lowercase class" do
      @klass.tag_name.should == 'fubar'
    end
    
    it "should default tag name of class in modules to the last constant lowercase" do
      module Fu
        class Bar
          include OxMlk
        end
      end
      
      Fu::Bar.tag_name.should == 'bar'
    end
    
  end
  
end

describe OxMlk::Description do
  describe 'being initiated' do
    it 'should do something'
  end
end
