require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe OxMlk::InstanceMethods do
  
  before(:all) do
    require example(:example)
    @xml = xml_for(:example)
    @ox = Person.from_xml(@xml)
  end
  
  describe '#to_xml' do
    before(:all) do
      @oxml = @ox.to_xml
      @doc = OxMlk::XML::Document.new
      @doc.root = @oxml
    end
    
    it 'should return a XML::Node' do
      @oxml.should be_a(OxMlk::XML::Node)
    end
    
    it 'should set name to Class.ox_tag' do
      @oxml.name.should == 'person'
    end
    
    it 'should set elements' do
      @oxml.children.map(&:name).should == ['name','number','number','email','friends']
    end
    
    it 'should set content to text node' do
      @oxml.find_first('number').child.should be_text
    end
    
    it 'should set attributes' do
      @oxml['category'].should == 'meat_popsicle'
      @oxml['alt'].should == 'human'
    end
    
    it 'should produce same xml as created it' do
      @oxml.to_s.should == OxMlk::XML::Node.from(@xml).to_s
    end
  end
end

describe OxMlk::ClassMethods do
  
  before(:all) do
    require example(:example)
    @klass = Person
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

    it 'should add not a writter method when :freeze => true' do
      @klass.new.should_not respond_to(:contacts=)
    end
  
    it 'should add a writter method when :freeze => false' do
      @klass.new.should respond_to(:friends=)
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
      
      it 'should fetch contacts' do
        @example.contacts.map(&:value).should == ['3035551212','3035551234','test@example.com']
      end
      
      it 'should fetch friends' do
        @example.friends.map(&:name).should == ['Bob','John']
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

