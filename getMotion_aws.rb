require 'pi_piper'
require 'mysql2'
require 'net/http'
require 'uri'
require 'json'
include PiPiper


watch :pin => 17 do
	t = Time.now
        strTime = t.strftime("%Y%m%d%H%M%S")
        strTimedate = t.strftime("%Y/%m/%d %H:%M:%S")

	puts "Pin change from #{last_value} to #{value}"
	puts system("sudo raspistill -w 480 -h 360 -n -o /work/img/#{strTime}.jpg")


	uri = URI.parse("http://ec2-52-192-215-250.ap-northeast-1.compute.amazonaws.com/server_post")
	response = nil

	request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})

	http = Net::HTTP.new(uri.host, uri.port)
	http.set_debug_output $stderr

	sdata = { 
	:type => "meeting",
	:id => "10F Cue_Lab",
	:flag => #{value},
	:exedate => #{strTimedate}
	}.to_json
	request.body = sdata

	http.start do |h|
	  response = http.request(request)
	end
end

PiPiper.wait
