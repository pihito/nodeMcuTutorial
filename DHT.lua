PIN = 4 --  data pin, GPIO2

local dht= require 'dht'
SSID = "MySensorNetwork"
PASSWORD = "SebSensor"

function readDht()    
    status,temp,humi,temp_decimial,humi_decimial = dht.read(PIN)
    if( status == dht.OK ) then
        print("DHT Temperature:"..temp..";".."Humidity:"..humi)
    elseif( status == dht.ERROR_CHECKSUM ) then
        print( "DHT Checksum error." );
    elseif( status == dht.ERROR_TIMEOUT ) then
        print( "DHT Time out." );
    end
    return temp,humi
end

function wait_for_wifi_conn ( )
   tmr.alarm (1, 1000, 1, function ( )
      if wifi.sta.getip ( ) == nil then
         print ("Waiting for Wifi connection")
      else
         tmr.stop (1)
         print ("ESP8266 mode is: " .. wifi.getmode ( ))
         print ("The module MAC address is: " .. wifi.ap.getmac ( ))
         print ("Config done, IP is " .. wifi.sta.getip ( ))
      end
   end)
end

function connect()
    wifi.setmode(wifi.STATION)
    wifi.sta.config(SSID, PASSWORD, 1)
    wait_for_wifi_conn ( )
end

function http_conn(sock)
    sock:on("receive",function(sock,payload) 
        print(payload) -- for debugging only
       --generates HTML web site
        temp,humi =readDht()
sock:send('HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n\
   <!DOCTYPE HTML>\
    <html><head><meta content="text/html;charset=utf-8"><title>ESP8266</title></head>\
   <body bgcolor="#ffe4c4"><h2>Hygrometer with<br>DHT22 sensor</h2>\
   <h3><font color="green">\
   <IMG SRC="http://esp8266.fancon.cz/common/hyg.gif"WIDTH="64"HEIGHT="64"><br>\
   <input style="text-align: center"type="text"size=4 name="j"value="'..humi..'"> % of relative humidity<br><br>\
   <IMG SRC="http://esp8266.fancon.cz/common/tmp.gif"WIDTH="64"HEIGHT="64"><br>\
   <input style="text-align: center"type="text"size=4 name="p"value="'..temp..'"> Temperature grade C<br></font></h3>\
   <IMG SRC="http://esp8266.fancon.cz/common/dht22.gif"WIDTH="200"HEIGHT="230"BORDER="2"></body></html>')
    sock:on("sent",function(sock) sock:close() end)
    end)
end      

--main function
connect()
svr = net.createServer (net.TCP, 30)
svr:listen (80, http_conn)

