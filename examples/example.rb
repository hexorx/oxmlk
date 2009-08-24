class Number
  include OxMlk
  
  ox_tag :number
  
  ox_attr(:value, :from => :content)
end

class Email
  include OxMlk
  
  ox_tag :email
  
  ox_attr(:value, :from => :content)
end

class Person
  include OxMlk
  
  ox_tag :person
  
  ox_attr(:category, :from => :attr)
  ox_attr(:two_attr, :from => '@attr2')
  
  ox_attr(:name)
  ox_attr(:numbers, :as => [Number], :freeze => false)
  ox_attr(:contacts, :as => [Number,Email], :freeze => true)
  
  def say_hello(xml)
    'hello'
  end
end