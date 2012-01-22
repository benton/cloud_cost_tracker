# Makes the Module heirarchy needs to be inspectable
class Module
  def submodules
    constants.collect {|const_name| const_get(const_name)}.select do |const|
      const.class == Module
    end
  end
  def classes
    constants.collect {|const_name| const_get(const_name)}.select do |const|
      const.class == Class
    end
  end
end
