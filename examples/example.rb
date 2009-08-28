class Number
  include OxMlk
  
  ox_tag :number
  
  ox_attr :group
  ox_elem(:value, :from => :content)
end

class Email
  include OxMlk
  
  ox_tag :email
  
  ox_attr :group
  ox_elem(:value, :from => :content)
end

class Person
  include OxMlk
  
  ox_tag :person
  
  ox_attr :category
  ox_attr :alternate, :from => 'alt'
  
  ox_elem :name
  ox_elem :contacts, :as => [Number,Email]
  ox_elem :friends, :as => [Person], :in => :friends
  
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