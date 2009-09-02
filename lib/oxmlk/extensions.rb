class String
  def between(separator, &block)
    split(separator).map(&block).join(separator)
  end
end