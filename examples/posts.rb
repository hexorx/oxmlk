class Response
  include OxMlk
  
  ox_attr :user, :from => '@user'
end

class Post
  include OxMlk
end