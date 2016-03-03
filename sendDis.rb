require 'net/http'
require 'uri'
require 'json'

module GPIO
  module_function

  def export(n, dir)
    File.open("/sys/class/gpio/export", "w") do |fp|
      fp.write(n.to_s)
    end
    sleep 0.1
    File.open("/sys/class/gpio/gpio#{n}/direction", "w") do |fp|
      fp.write(dir)
    end
  end

  def unexport(n)
    File.open("/sys/class/gpio/unexport", "w") do |fp|
      fp.write(n.to_s)
    end
  end

  def read(n)
    File.read("/sys/class/gpio/gpio#{n}/value")
  end

  def write(n, value)
    File.open("/sys/class/gpio/gpio#{n}/value", "w") do |fp|
      fp.write(value.to_s)
    end
  end

  class Edge
    def initialize(n, mode='both')
      File.open("/sys/class/gpio/gpio#{n}/edge", "w") do |fp|
        fp.write(mode)
      end
      @value = File.open("/sys/class/gpio/gpio#{n}/value")
    end

    def wait(timeout=nil)
      IO.select([], [], [@value], timeout)
      read
    end

    def read
      @value.seek(0)
      @value.read
    end

    def close
      @value.close
    end
  end
end

GPIO.export(17, 'out')
GPIO.export(22, 'in')

GPIO.write(17, 1)
sleep 0.00001
GPIO.write(17, 0)

edge = GPIO::Edge.new(22)
puts edge.read
puts edge.wait(10)
s = Time.now
puts edge.wait(10)
e = Time.now
edge.close

distance = (e.to_f - s.to_f) * 17000
puts distance.to_s

GPIO.unexport(17)
GPIO.unexport(22)

datetime_string = Time.now.strftime("%Y/%m/%d %H:%M:%S")

toiret_flag = 0
if distance < 150 then
	puts "closed"
        toiret_flag = 1
else
	puts "open"
        toiret_flag = 0
end

uri = URI.parse("http://ec2-52-192-215-250.ap-northeast-1.compute.amazonaws.com/server_post")
response = nil

request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})

http = Net::HTTP.new(uri.host, uri.port)
http.set_debug_output $stderr

sdata = { 
:type => "toiret",
:toiret_floor => "10F" ,
:toiret_num => "0" ,
:distance => distance,
:flag => toiret_flag ,
:datetime => datetime_string
}.to_json
request.body = sdata

http.start do |h|
  response = http.request(request)
end


