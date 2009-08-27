class Number
  include OxMlk
  
  ox_tag :number
  
  ox_attr :group, :from => :attr
  ox_attr(:value, :from => :content)
end

class Email
  include OxMlk
  
  ox_tag :email
  
  ox_attr :group, :from => :attr
  ox_attr(:value, :from => :content)
end

class Person
  include OxMlk
  
  ox_tag :person
  
  ox_attr(:category, :from => :attr)
  ox_attr(:alt, :from => '@alt')
  
  ox_attr(:name)
  ox_attr(:contacts, :as => [Number,Email], :freeze => true)
  ox_attr(:friends, :as => [Person], :in => :friends, :freeze => false)
  
  def say_hello(xml)
    'hello'
  end
end

class Example
  include OxMlk
end

module Test
  class Example
    include OxMlk
  end
end