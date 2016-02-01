require 'pi_piper'
require 'mysql2'
include PiPiper

watch :pin => 17 do
	t = Time.now
        strTime = t.strftime("%Y%m%d%H%M%S")
        strTimedate = t.strftime("%Y/%m/%d %H:%M:%S")

	puts "Pin change from #{last_value} to #{value}"

	puts system("sudo raspistill -w 480 -h 360 -n -o /work/img/#{strTime}.jpg")

        client = Mysql2::Client.new(:host => 'localhost', :username => 'root', :password => 'Itpro')
        p strTimedate
        prequery = "insert into motion_test.motions values (#{strTime},'pi1',#{value},cast(\"#{t}\" as datetime))"
        p prequery
        results = client.query("#{prequery}")
        p results
end

PiPiper.wait
