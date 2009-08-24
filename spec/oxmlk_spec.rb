require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe OxMlk do
  
  before(:all) do
    require example(:example)
    @klass = Person
  end
  
  describe 'being included into another class' do
    it 'should set ox_attrs to an array' do
      @klass.ox_attrs.should be_a(Array)
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
    
    it 'should add a tag_name method' do
      @klass.should respond_to(:ox_tag)
    end
  end
  
  describe '#ox_attr' do
    it 'should add an OxMlk::Description to the class' do
      @klass.ox_attrs.first.should be_a(OxMlk::Description)
    end
  
    it 'should add a reader method' do
      @klass.new.should respond_to(:name)
    end
  
    it 'should add a writter method by default' do
      @klass.new.should respond_to(:name=)
    end

    it 'should add a writter method when :freeze => false' do
      @klass.new.should respond_to(:numbers=)
    end
  
    it 'should not add a writter method when :freeze => true' do
      @klass.new.should_not respond_to(:contacts=)
    end
  end
    
  describe '#from_xml' do
    
    it 'should return an instance of class' do
      @klass.from_xml('<person/>').should be_a(@klass)
    end
    
    it 'should error on mismatched tag' do
      proc { @klass.from_xml('<Person/>') }.should raise_error
    end
    
    describe 'example' do
      before(:all) do
        @xml = xml_for(:example)
        @example = Person.from_xml(@xml)
      end
      
      it 'should fetch name' do
        @example.name.should == 'Joe'
      end
      
      it 'should fetch category' do
        @example.category.should == 'meat_popsicle'
      end
      
      it 'should fetch numbers' do
        @example.numbers.map(&:value).should == ['3035551212','3035551234']
      end
      
      it 'should fetch contacts' do
        @example.contacts.map(&:value).should == ['3035551212','3035551234','test@example.com']
      end
    end
  end
  
  describe '#ox_attributes' do
    it 'should return a list of attributes' do
      @klass.ox_attributes.size.should == 2
    end
  end
  
  describe '#ox_elems' do
    it 'should return a list of elements' do
      @klass.ox_elems.size.should == 3
    end
  end
end

