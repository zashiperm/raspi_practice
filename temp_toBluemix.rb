require 'pi_piper'
require 'couchrest'

  value = 0
  PiPiper::Spi.begin do |spi|
    raw = spi.write [0b01101000,0]
    value = ((raw[0]<<8) + raw[1]) & 0x03FF
  end
  volt = (value * 3300)/1024
  degree = 0.to_f
  degree =(volt - 500)/10
  degree = degree + 1.4

gettime = Time.now.strftime("%Y-%m-%d %H:%M:%S")

@db = CouchRest.database("https://e7d5e924-bfd3-4063-9143-96bec2e790b1-bluemix.cloudant.com/iot_pitest/_all_docs")
response = @db.save_doc({:temp => degree, 'timestamp' => gettime.to_s})
puts gettime.to_s
puts response['ok']
