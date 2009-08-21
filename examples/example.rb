class Example
  include OxMlk
  ox_attr(:one_attr, :from => :attribute)
  ox_attr(:two_attr, :from => '@attr2')
  
  ox_attr(:name)
  ox_attr(:warm, :freeze => false)
  ox_attr(:cold, :freeze => true)
  
  def say_hello
    'hello'
  end
end

class SubExample
  include OxMlk
  
  ox_attr(:blah)
end