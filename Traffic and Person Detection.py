import sensor,image,lcd,time
import KPU as kpu

import utime
from Maix import GPIO
from board import board_info
from fpioa_manager import fm

lcd.init()
lcd.rotation(2)

sensor.reset()
sensor.set_pixformat(sensor.RGB565)
sensor.set_framesize(sensor.QVGA)
sensor.set_windowing((224, 224))
sensor.set_vflip(1)
sensor.run(1)

fm.register(20, fm.fpioa.GPIO0, force=True)
fm.register(21, fm.fpioa.GPIO1, force=True)
ored = GPIO(GPIO.GPIO0, GPIO.OUT)
ored.value(0)
oyellow = GPIO(GPIO.GPIO1, GPIO.OUT)
oyellow.value(0)


clock = time.clock()
classes = ['red','green','yellow','person']
task = kpu.load(0x200000)
a = kpu.set_outputs(task, 0, 7, 7, 45)
anchor = (1.1958,1.70, 1.4107,2.25, 1.7031,2.84, 2.1596,3.71, 2.7197,4.7957)
a = kpu.init_yolo2(task, 0.5, 0.3, 5, anchor)


while(True):
   clock.tick()
   img = sensor.snapshot()
   objects = kpu.run_yolo2(task, img)
   print(clock.fps())
   ored.value(0)
   oyellow.value(0)
   if objects:
       for obj in objects:
               img.draw_rectangle(obj.rect(),color=(0,255,0),thickness=5)
               img.draw_string(obj.x()+10, obj.y(), classes[obj.classid()], color=(255,0,0),scale=3)
               img.draw_string(obj.x()+10, obj.y()+38, '%.3f'%obj.value(), color=(0,0,255),scale=2)
               if obj.classid() == 0:
                   ored.value(1)
               elif obj.classid() == 3:
                   ored.value(1)

               elif obj.classid() == 2:
                   oyellow.value(1)

   lcd.display(img)
kpu.deinit(task)
