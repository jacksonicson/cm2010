require(ggplot2)
require(scales)
require(plyr)

data = read.csv("outputC.csv", sep=";", stringsAsFactors=FALSE, quote = "'")

data$slot = as.factor(data$slot)
data$time = as.POSIXct(data$time, origin="1970-01-01")

data$battery.voltage = data$battery.voltage / 1000 # mV to V
data$charger.voltage = data$charger.voltage / 1000 # mV to V
data$charger.amperage = data$charger.amperage / 1000 # mA to A
data$charged.capacity = data$charged.capacity / 100 # 10^-2 mAh to mAh
data$discharged.capacity = data$discharged.capacity / 100 # 10^-2 mAh to mAh
data$battery.resistor = data$battery.resistor / 100 # 10^-1 MOhm to MOhm

data.charge = data[data$program.state == 'Charge',]
data.discharge = data[data$program.state == 'Discharge',]
data.trickle = data[data$program.state == 'Trickle',]

runtime = ddply(data, .(slot), function(rows) {
  hour = max(rows$hours)
  min = tail(rows, 1)$minutes
  return(c(hour, min))
})
names(runtime) = c("Charger Slot", "Hours", "Minutes")

p = ggplot()
p = p + geom_line(data=data.charge, aes(x=time, y=charged.capacity, color=slot))
p = p + geom_line(data=data.discharge, aes(x=time, y=-discharged.capacity, color=slot))
p = p + geom_line(data=data.trickle, aes(x=time, y=charged.capacity, color=slot))
p = p + scale_color_discrete(name="Charger Slot")
p = p + labs(x="Time", y="(Dis)Charged (mAh)") 
p = p + theme(legend.position="top")
p.charge.discharge = p

p = ggplot()
p = p + geom_point(data=data.charge[data.charge$battery.resistor > 0,], aes(x=time, y=battery.resistor, color=slot), size=0.1)
p = p + geom_point(data=data.discharge[data.discharge$battery.resistor > 0,], aes(x=time, y=battery.resistor, color=slot), size=0.1)
p = p + geom_point(data=data.trickle[data.trickle$battery.resistor > 0,], aes(x=time, y=battery.resistor, color=slot), size=0.1)
p = p + scale_color_discrete(name="Charger Slot")
p = p + labs(x="Time", y="battery.resistor (MOhm)") 
p = p + theme(legend.position="top")
p.battery.resistor = p

p = ggplot()
p = p + geom_line(data=data.charge[data.charge$battery.voltage > 0,], aes(x=time, y=battery.voltage, color=slot))
p = p + geom_line(data=data.discharge[data.discharge$battery.voltage > 0,], aes(x=time, y=battery.voltage, color=slot))
p = p + geom_line(data=data.trickle[data.trickle$battery.voltage > 0,], aes(x=time, y=battery.voltage, color=slot))
p = p + scale_color_discrete(name="Charger Slot")
p = p + labs(x="Time", y="Battery Voltage (V)") 
p = p + theme(legend.position="top")
p.battery.voltage = p

p = ggplot()
p = p + geom_line(data=data.charge[data.charge$charger.voltage > 0,], aes(x=time, y=charger.voltage, color=slot))
p = p + geom_line(data=data.trickle[data.trickle$charger.voltage > 0,], aes(x=time, y=charger.voltage, color=slot))
p = p + scale_color_discrete(name="Charger Slot")
p = p + labs(x="Time", y="Charger Voltage (V)") 
p = p + theme(legend.position="top")
p.charger.voltage = p

p = ggplot()
p = p + geom_line(data=data.charge[data.charge$charger.amperage > 0,], aes(x=time, y=charger.amperage, color=slot))
p = p + geom_line(data=data.trickle[data.trickle$charger.amperage > 0,], aes(x=time, y=charger.amperage, color=slot))
p = p + scale_color_discrete(name="Charger Slot")
p = p + labs(x="Time", y="Charger Amperage (A)") 
p = p + theme(legend.position="top")
p.charger.amperage = p


