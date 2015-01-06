require(ggplot2)
require(scales)
require(plyr)

data = read.csv("output.csv", sep=";", stringsAsFactors=FALSE, quote = "'")

data$slot = as.factor(data$slot)
data$time = as.POSIXct(data$time, origin="1970-01-01")

data$bvol = data$bvol / 1000 # mV to V
data$lvol = data$lvol / 1000 # mV to V
data$lamp = data$lamp / 1000 # mA to A
data$charged = data$charged / 100 # 10^-2 mAh to mAh
data$discharged = data$discharged / 100 # 10^-2 mAh to mAh
data$resistor = data$resistor / 100 # 10^-1 MOhm to MOhm

data.charge = data[data$display == 'Charge',]
data.discharge = data[data$display == 'Discharge',]
data.trickle = data[data$display == 'Trickle',]

runtime = ddply(data, .(slot), function(rows) {
  hour = max(rows$hrs)
  min = tail(rows, 1)$min
  return(c(hour, min))
})

p = ggplot()
p = p + geom_line(data=data.charge, aes(x=time, y=charged, color=slot))
p = p + geom_line(data=data.discharge, aes(x=time, y=-discharged, color=slot))
p = p + geom_line(data=data.trickle, aes(x=time, y=charged, color=slot))
p = p + scale_color_discrete(name="Charger Slot")
p = p + labs(x="Time", y="(Dis)Charged (mAh)") 
p = p + theme(legend.position="top")
p.charge.discharge = p

p = ggplot()
p = p + geom_point(data=data.charge[data.charge$resistor > 0,], aes(x=time, y=resistor, color=slot), size=0.1)
p = p + geom_point(data=data.discharge[data.discharge$resistor > 0,], aes(x=time, y=resistor, color=slot), size=0.1)
p = p + geom_point(data=data.trickle[data.trickle$resistor > 0,], aes(x=time, y=resistor, color=slot), size=0.1)
p = p + scale_color_discrete(name="Charger Slot")
p = p + labs(x="Time", y="Resistor (MOhm)") 
p = p + theme(legend.position="top")
p.resistor = p

p = ggplot()
p = p + geom_line(data=data.charge[data.charge$bvol > 0,], aes(x=time, y=bvol, color=slot))
p = p + geom_line(data=data.discharge[data.discharge$bvol > 0,], aes(x=time, y=bvol, color=slot))
p = p + geom_line(data=data.trickle[data.trickle$bvol > 0,], aes(x=time, y=bvol, color=slot))
p = p + scale_color_discrete(name="Charger Slot")
p = p + labs(x="Time", y="Battery Voltage (V)") 
p = p + theme(legend.position="top")
p.battery.voltage = p

p = ggplot()
p = p + geom_line(data=data.charge[data.charge$lvol > 0,], aes(x=time, y=lvol, color=slot))
p = p + geom_line(data=data.trickle[data.trickle$lvol > 0,], aes(x=time, y=lvol, color=slot))
p = p + scale_color_discrete(name="Charger Slot")
p = p + labs(x="Time", y="Charger Voltage (V)") 
p = p + theme(legend.position="top")
p.charger.voltage = p

p = ggplot()
p = p + geom_line(data=data.charge[data.charge$lamp > 0,], aes(x=time, y=lamp, color=slot))
p = p + geom_line(data=data.trickle[data.trickle$lamp > 0,], aes(x=time, y=lamp, color=slot))
p = p + scale_color_discrete(name="Charger Slot")
p = p + labs(x="Time", y="Charger Amperage (A)") 
p = p + theme(legend.position="top")
p.charger.amperage = p


