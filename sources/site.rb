require 'open-uri'
require 'xmlsimple'

class Site < SourceAdapter

  # this is a handy function to extract key-value pairs from a complex nested hash (hash of arrays and hashes such as is returned by
  # many web services)
  def extract_keyvalues(v)
  
    result={}
    if v.is_a?(Hash)

      v.each do |key,value|
        if value.is_a?(String)
          result[key]=value
        elsif value.is_a?(Array) and value.size==1 and value[0].is_a?(String)
          result[key]=value[0]
        else
          temp=extract_keyvalues(value)
          temp.keys.each do |x|
            result[x]=temp[x]
          end
        end
      end
    elsif v.is_a?(Array)
        v.each do |item|
          if item.is_a?(Hash) or item.is_a?(Array)
            temp=extract_keyvalues(item)
            temp.keys.each do |x|
              result[x]=temp[x]
            end
          end
        end
    end
    p "Returning result: #{result.inspect.to_s}"

    result
  end
 
  def query(conditions=nil)
    # use web service at http://qwwebservices.usgs.gov/technical-documentation.html#DOMAIN
    # for example: http://qwwebservices.usgs.gov/Station/search?bBox=-122.1,36.9,-121.9,37.1
    @radius=conditions[:radius] if conditions
    @radius||=0.1
    @lat=conditions[:lat] if conditions
    @lat||=37.33
    @long=conditions[:long] if conditions
    @long||=-122.04

    base_url="http://qwwebservices.usgs.gov/Station/search"
    p "Base URL #{base_url}"
    url=base_url+"?bBox=#{@long-@radius},#{@lat-@radius},#{@long+@radius},#{@lat+@radius}"
    puts "Opening #{url}"
    begin 
      response=open(url)
    rescue Exception=>e
      puts "Error opening: e.inspect.to_s"
    end
    begin 
      xmlresult=XmlSimple.xml_in(response.read)
    rescue Exception=>e
      puts "Error parsing: #{e.inspect.to_s}"
    end      

    @result={}  
    org=xmlresult["Organization"]
    p "Org: #{org[0].inspect.to_s}"
    org[0]["MonitoringLocation"].each do |loc|
      begin 
        puts "Site: #{loc.inspect.to_s}"
        puts "Site name: #{loc['MonitoringLocationIdentity'][0]['MonitoringLocationIdentifier']}"
        @result[loc['MonitoringLocationIdentity'][0]['MonitoringLocationIdentifier'][0]]=extract_keyvalues(loc)
      rescue
        puts "Failure to access site"
      end
    end
    p "Final result: #{@result.inspect.to_s}"

    @result
  end
end 