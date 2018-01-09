class FormData
  def initialize
    @_listFormData = [];
  end
  
  def append(strKey, value, strFileName=nil)
   @_listFormData << [strKey, value, strFileName];
  end
  
  def clear
    @_listFormData.clear
  end
  
  def isValid
    return @_listFormData != nil
  end
  
  def getAll
    return @_listFormData
  end
end