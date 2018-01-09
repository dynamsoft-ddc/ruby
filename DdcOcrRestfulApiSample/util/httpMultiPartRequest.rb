require "net/http"
require "uri"
require "securerandom"
require_relative "formData"

class HttpMultiPartRequest
  @@strBoundary = "DdcOrcRestfulApiSample" + SecureRandom.uuid.gsub("-", "")

  # post multi-part form data
  def self.post(strUri, dicHeader, formData)
    if strUri.class != String or strUri.length == 0
      raise "Url is invalid."
    end

    strBodyData = constructRequestBodyData formData

    if strBodyData == nil
      raise "Reqeust body invalid."
    end

    uri = URI.parse strUri
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new uri.request_uri
    request.body = strBodyData
    request["Content-Type"] = "multipart/form-data, boundary=#{@@strBoundary}"
    if dicHeader.class == Hash
      dicHeader.each do |key, value|
        request[key] = value
      end
    end

    response = http.request request
    if response.code != '200'
      raise response.msg
    end

    return response
  end

  # construct request body data
  def self.constructRequestBodyData(formData)
    if formData.class != FormData or !formData.isValid
      return nil
    end

    listBodyData = []

    bHasItemAdded = false
    strNewLine = "\r\n"
    strBoundarySeparator = "--"

    formData.getAll.each do |strKey, value, strFileName|
      if bHasItemAdded
        listBodyData << strNewLine
      end

      # write key value pair
      if strFileName == nil
        listBodyData << strBoundarySeparator + @@strBoundary + strNewLine +
            'Content-Disposition: form-data; name="' + strKey + '"' +
            strNewLine + strNewLine +
            value
      # write file data
      else
        bLocalFile = File.file? value

        listBodyData << strBoundarySeparator + @@strBoundary + strNewLine +
            'Content-Disposition: form-data; name="' + strKey + '"; ' +
            'filename="' + strFileName + '"' + strNewLine +
            'Content-Type: ' + (bLocalFile ? 'application/octet-stream' : 'text/plain' ) +
            strNewLine + strNewLine

        if bLocalFile
          f = File.open(value, "rb")
          value = f.read
          f.close
        end

        listBodyData << value
      end

      bHasItemAdded = true
    end

    if bHasItemAdded
      listBodyData << strNewLine + strBoundarySeparator + @@strBoundary + strBoundarySeparator + strNewLine
    end

    return listBodyData.join
  end
end