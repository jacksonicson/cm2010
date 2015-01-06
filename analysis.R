require(ggplot2)

charge.data = read.csv("output.csv", sep=";", stringsAsFactors=FALSE, quote = "'")

charge.data$slot = as.factor(charge.data$slot)
charge.data$time = as.POSIXct(charge.data$time / 1000, origin="1970-01-01")

charge.data$bvol = charge.data$bvol / 1000
charge.data$lvol = charge.data$lvol / 1000

charge = charge.data
charge = charge[charge$display=='Discharge',]

p = ggplot(charge)
p = p + geom_line(aes(x=time, y=discharged, color=slot))
print(p)
