require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("http://ec2-52-192-215-250.ap-northeast-1.compute.amazonaws.com/server_post")
response = nil

request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})

http = Net::HTTP.new(uri.host, uri.port)
http.set_debug_output $stderr

sdata = { 
:type => "toiret",
:toiret_floor => "10F" ,
:toiret_num => "0" ,
:distance => 100.2343,
:flag => 0 ,
:datetime => "2016/02/18 15:05:01"
}.to_json
request.body = sdata

http.start do |h|
  response = http.request(request)
end
