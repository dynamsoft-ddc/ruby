#!/usr/bin/ruby -w

$LOAD_PATH << File.join(File.dirname(__FILE__), "util")
require "comm"
require "configuration"
require "formData"
require "httpMultiPartRequest"

# sample entry
def main
  # setup ocr url and api key
  strOcrBaseUri = Configuration.getOcrBaseUri
  dicHeader = {"x-api-key" => Configuration.getApiKey}

  # region 1. upload file
  puts "-----------------------------------------------------------------------"
  puts "1. Upload file..."
  formData = FormData.new
  formData.append("method", Comm.enumOcrFileMethod["upload"])
  formData.append("file", File.join(File.join(File.dirname(__FILE__), "data"), "example.jpg"), "example.jpg")

  begin
    httpWebResponse = HttpMultiPartRequest.post(strOcrBaseUri, dicHeader, formData)
    restfulApiResponse = Comm.parseHttpWebResponseToRestfulApiResult(httpWebResponse, Comm.enumOcrFileMethod["upload"])
    strFileName = Comm.handleRestfulApiResponse(restfulApiResponse, Comm.enumOcrFileMethod["upload"])
  rescue Exception => ex
    puts ex
    return
  end

  if strFileName == nil
    return
  end

  # 2. recognize the uploaded file
  puts "\r\n-----------------------------------------------------------------------"
  puts "2. Recognize the uploaded file..."
  formData.clear
  formData.append("method", "recognize")
  formData.append("file_name", strFileName)
  formData.append("language", "eng")
  formData.append("output_format", "UFormattedTxt")
  formData.append("page_range", "1-10")

  begin
    httpWebResponse = HttpMultiPartRequest.post(strOcrBaseUri, dicHeader, formData)
    restfulApiResponse = Comm.parseHttpWebResponseToRestfulApiResult(httpWebResponse, Comm.enumOcrFileMethod["recognize"])
    strFileName = Comm.handleRestfulApiResponse(restfulApiResponse, Comm.enumOcrFileMethod["recognize"])
  rescue Exception => ex
    puts ex
    return
  end

  if strFileName == nil
    return
  end

  # region 3. download the recognized file
  puts "\r\n-----------------------------------------------------------------------"
  puts "3. Download the recognized file..."

  formData.clear
  formData.append("method", Comm.enumOcrFileMethod["download"])
  formData.append("file_name", strFileName)

  begin
    httpWebResponse = HttpMultiPartRequest.post(strOcrBaseUri, dicHeader, formData)
    restfulApiResponse = Comm.parseHttpWebResponseToRestfulApiResult(httpWebResponse, Comm.enumOcrFileMethod["download"])
    Comm.handleRestfulApiResponse(restfulApiResponse, Comm.enumOcrFileMethod["download"])
  rescue Exception => ex
    puts ex
  end
end

main
