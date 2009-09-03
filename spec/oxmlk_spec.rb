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
      @oxml.children.map(&:name).should == ['name','lame','number','number','email','friends']
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
  
  describe '#ox?' do
    it 'should return true' do
      Person.ox?.should be_true
    end
  end
end

describe OxMlk::ClassMethods do
  
  before(:all) do
    require example(:example)
    @klass = Person
  end
  
  describe '#ox_elem' do
    it 'should add an OxMlk::Description to the ox_elems list' do
      @klass.ox_elems.first.should be_a(OxMlk::Elem)
    end
  
    it 'should add a reader method' do
      @klass.new.should respond_to(:name)
    end
  
    it 'should add a writter method' do
      @klass.new.should respond_to(:name=)
    end
  end
  
  describe '#ox_attr' do
    it 'should add an OxMlk::Attr to the ox_attrs list' do
      @klass.ox_attrs.first.should be_a(OxMlk::Attr)
    end
    
    it 'should add a reader method' do
      @klass.new.should respond_to(:alternate)
    end
  
    it 'should add a writter method' do
      @klass.new.should respond_to(:alternate=)
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
  
  describe '#ox_attrs' do
    it 'should return a list of attributes' do
      @klass.ox_attrs.size.should == 2
    end
  end
  
  describe '#ox_elems' do
    it 'should return a list of elements' do
      @klass.ox_elems.size.should == 4
    end
  end
  
  describe '#ox_tag' do
    it 'should default to class name' do
      Example.ox_tag.should == 'Example'
    end
    
    it 'should default to class name with module removed' do
      Test::Example.ox_tag.should == 'Example'
    end
    
    describe 'procs and blocs' do
      before(:each) do
        @klass = Class.new do
          include OxMlk

          def self.to_s
            'ExampleTest'
          end
        end
      end
      
      it 'should apply proc if set' do
        @klass.ox_tag(proc {|x| x.upcase}).should == 'EXAMPLETEST'
      end
      
      it 'should apply :sym.to_proc if set' do
        @klass.ox_tag(:downcase).should == 'exampletest'
      end
      
      it 'should apply block if passed' do
        @klass.ox_tag do |x|
          x.underscore
        end
        @klass.ox_tag.should == 'example_test'
      end
    end
  end
end

