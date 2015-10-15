
--****METTRE LA PIN DE CONNEXION DU DHT****
PIN = 4 --  data pin, GPIO2

local dht= require 'dht'

--****METTRE votre SSID et le password wifi****
SSID = "MySensorNetwork"
PASSWORD = "SebSensor"

--lecture du capteur de température 
--pin : numéro de la patte ou est branche le capteur
--temp,humi temperature et humidite
function readDht(pin)    
    status,temp,humi,temp_decimial,humi_decimial = dht.read(pin)
    if( status == dht.OK ) then
        print("DHT Temperature:"..temp..";".."Humidite"..humi)
    elseif( status == dht.ERROR_CHECKSUM ) then
        print( "DHT Checksum error." );
    elseif( status == dht.ERROR_TIMEOUT ) then
        print( "DHT Time out." );
    end
    return temp,humi
end
-- fonction qui attend la communication wifi une fois connecté, elle lance le serveur web
function wait_for_wifi_conn ( )
   tmr.alarm (1, 1000, 1, function ( )
      if wifi.sta.getip ( ) == nil then
         print ("Waiting for Wifi connection")
      else
         tmr.stop (1)
         print ("ESP8266 mode is: " .. wifi.getmode ( ))
         print ("The module MAC address is: " .. wifi.ap.getmac ( ))
         print ("Config done, IP is " .. wifi.sta.getip ( ))
         --lancement du serveur web
         svr = net.createServer (net.TCP, 30)
         svr:listen (80, http_conn)
      end
   end)
end

--fonction de connexion au WIFI en mode station
function connect()
    wifi.setmode(wifi.STATION)
    wifi.sta.config(SSID, PASSWORD, 1)
    wait_for_wifi_conn ( )
end

-- fonction de prise en charge des clients web, renvoie la pages HTML
function http_conn(sock)
    sock:on("receive",function(sock,payload) 
        print(payload) -- for debugging only
       --generates HTML web site
        temp,humi =readDht(PIN)
sock:send('HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n\
   <!DOCTYPE HTML>\
    <html><head><meta content="text/html;charset=utf-8"><title>ESP8266</title></head>\
   <body bgcolor="#ffe4c4"><h2>Capteur DHT22 en wifi</h2>\
   <h3><font color="green">\
   <IMG SRC="http://esp8266.fancon.cz/common/hyg.gif"WIDTH="64"HEIGHT="64"><br>\
   <input style="text-align: center"type="text"size=4 name="j"value="'..humi..'"> %  humidite<br><br>\
   <IMG SRC="http://esp8266.fancon.cz/common/tmp.gif"WIDTH="64"HEIGHT="64"><br>\
   <input style="text-align: center"type="text"size=4 name="p"value="'..temp..'"> Temperature en °C<br></font></h3>\
   <IMG SRC="http://esp8266.fancon.cz/common/dht22.gif"WIDTH="200"HEIGHT="230"BORDER="2"></body></html>')
    sock:on("sent",function(sock) sock:close() end)
    end)
end      

--main function
connect()

