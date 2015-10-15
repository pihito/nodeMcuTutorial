-- setup I2c and connect display
function init_i2c_display()
     -- SDA and SCL can be assigned freely to available GPIOs
     local sda = 5 -- GPIO14
     local scl = 6 -- GPIO12
     local sla = 0x3c
     i2c.setup(0, sda, scl, i2c.SLOW)
     --disp = u8g.u8g_dev_sh1106_128x64(sla)
     disp = u8g.ssd1306_128x64_i2c(sla)
end

function draw()
     --disp:setFont(u8g.font_unifont)
     disp:setFont(u8g.font_6x10)
     disp:drawStr(5,5,"temp: " )
end

init_i2c_display()

  -- picture loop
  disp:firstPage()  
  repeat 
    draw()
  until( disp:nextPage()==false )