# http://cm2010.sourceforge.net/ 
# Values are in Big Endian
# Data block width 34 byte (4 blocks each second = one slot update each second)

import struct
import time
import signal 
import threading 

SERIAL = "/dev/ttyUSB0"
CSV_OUTPUT = "output.csv"
 
# Open serial device for reading
fp = open(SERIAL, "rb")

# Synchronize
print "Synchronizing..."
synced = False
sync = fp.read(136)
while not synced:
	# Read 4 blocks of 34 bytes
	print ".",

	# Find syncpoint	
	for i in xrange(34):
		slot0 = ord(sync[i])

		inline = True 
		for slot in xrange(1, 4):
			slotN = ord(sync[slot * 34 + i])
			inline = inline and slot0 == (slotN - slot)

		if inline:
			skip = i
			fp.read(skip)
			synced = True
			
			print
			print "SYNCED skipping %i bytes..." % skip
			break

	# Read next block
	next_block = fp.read(34)
	sync = sync[34:]
	sync = sync + next_block


class Block(object):

	def __init__(self, slot):
		print "Setup slot %i" % slot
		self.slotId = slot

	def read(self, block):
		# Read slot ID
		self.slot = ord(block[0])
	
		# Read display state
		display = ord(block[1])
		display = display & 0x0F
		self.display = "None"
		if display == 0x00:
			self.display  = "---"
		elif display == 0x01:
			self.display  = "SELECT AUTO/MAN: AUTO"
		elif display == 0x02:
			self.display  = "SELECT AUTO/MAN: MANUAL"
		elif display == 0x03:
			self.display  = "SELECT PROGRAM: CHARGE"
		elif display == 0x04:
			self.display  = "SELECT PROGRAM: DISCHARGE"
		elif display == 0x05:
			self.display  = "SELECT PROGRAM: CHECK"
		elif display == 0x06:
			self.display  = "SELECT PROGRAM: CYCLE"
		elif display == 0x07:
			self.display  = "SELCT PROGRAM: ALIVE"
		elif display == 0x08:
			self.display  = "CHA"
		elif display == 0x09:
			self.display = "DIS"
		elif display == 0x0A:
			self.display  = "CHK"
		elif display == 0x0B:
			self.display  = "CYC"
		elif display == 0x0C:
			self.display  = "ALV"
		elif display == 0x0D:
			self.display  = "RDY"
		elif display == 0x0E:
			self.display = "ERR"
		elif display == 0x0F:
			self.display = "TRI"

		# Read manual battery capacity
		cap = ord(block[2])
		cap = cap & 0xF0
		self.capacity = "None"
		if cap == 0x00:
			self.capacity = "AUTO"
		elif cap == 0x10:
			self.capacity = "100-200 mAh"
		elif cap == 0x20:
			self.capacity = "200-350 mAh"
		elif cap == 0x30:
			self.capacity = "350-600 mAh"
		elif cap == 0x40:
			self.capacity = "600-900 mAh"
		elif cap == 0x50:
			self.capacity = "900-1200 mAh"
		elif cap == 0x60:
			self.capacity = "1200-1500 mAh"
		elif cap == 0x70:
			self.capacity = "1500-2200 mAh"
		elif cap == 0x80:
			self.capacity = "2200-... mAh"

		# Read program state
		state = ord(block[2])
		state = state & 0x0F
		self.program_state = "None"
		if state == 0x00:
			self.program_state = "No battery"
		elif state == 0x01:
			self.program_state = "Charge" # Alive
		elif state == 0x02:
			self.program_state = "Discharge"
		elif state == 0x03:
			self.program_state = "Charge" # Cycle
		elif state == 0x04:
			self.program_state = "Discharge" # Check
		elif state == 0x05:
			self.program_state = "Charge" # Charge
		elif state == 0x06:
			self.program_state = "Discharge" # Discharge
		elif state == 0x07:
			self.program_state = "Trickle"
		elif state == 0x08:
			self.program_state = "Ready"	

		# Read program hours
		self.hours = ord(block[5])

		# Read program minutes
		self.minutes = ord(block[6])

		# Read current voltage
		self.voltage = struct.unpack(">h", block[8:10])[0]

		# Read current fill state
		self.fill = ord(block[10])

		# Read amperage
		self.amperage = struct.unpack(">h", block[13:15])[0]

		# Read voltage battery
		self.voltage_battery = struct.unpack(">h", block[15:17])[0]

		# Charged capacity
		self.charged_capacity = struct.unpack(">i", "\0" + block[17:20])[0]

		# Discharged capacity
		self.discharged_capacity = struct.unpack(">i", "\0" + block[20:23])[0]
		
		# Pre pre pre voltage
		self.pre3_voltage = struct.unpack(">h", block[24:26])[0]

		# Pre pre voltage
		self.pre2_voltage = struct.unpack(">h", block[26:28])[0]

		# Pre voltage
		self.pre1_voltage = struct.unpack(">h", block[28:30])[0]

		# Voltage
		self.pre0_voltage = struct.unpack(">h", block[30:32])[0]

		# Resistor in slot
		self.resistor = struct.unpack(">h", block[32:34])[0]

	def dump(self):
		print "Slot: %i" % self.slot
		print "Display: %s" % self.display
		print "Program state: %s" % self.program_state
		print "Capacity: %s" % self.capacity
		print "---"
		print "Charged capacity: %i (10^-2 mAh)" % self.charged_capacity
		print "Discharged capacity: %i (10^-2 mAh)" % self.discharged_capacity
		print "Charging hours: %i" % self.hours
		print "Charging minutes: %i" % self.minutes
		print "Charger voltage: %i (mV)" % self.voltage
		print "Charger amperage: %i (mA)" % self.amperage
		print "Batter fill: %i" % self.fill
		print "Battery voltage: %i (mV)" % self.voltage_battery
		print "Battery resistor: %i (10^-2 MOhm)" % self.resistor
		print "Pre 3 voltage: %i (mV)" % self.pre3_voltage
		print "Pre 2 voltage: %i (mV)" % self.pre2_voltage
		print "Pre 1 voltage: %i (mV)" % self.pre1_voltage
		print "Pre 0 voltage: %i (mV)" % self.pre0_voltage
		print
		
	def csv(self):
		ts = int(time.time())		
		vals = (self.slot, ts, self.display, self.program_state, self.capacity, self.hours, self.minutes, self.voltage, self.amperage, self.fill, self.voltage_battery, self.charged_capacity, self.discharged_capacity, self.resistor, self.pre3_voltage, self.pre2_voltage, self.pre1_voltage, self.pre0_voltage)
		return "%i;%i;'%s';'%s';'%s';%i;%i;%i;%i;%i;%i;%i;%i;%i;%i;%i;%i;%i" % vals

# Handle signals
sigterm = False
def handler(signum, frame):
	global sigterm
	sigterm = True 
signal.signal(signal.SIGINT, handler)

# Open CSV file to capture results
out = open(CSV_OUTPUT, "w")
out.write("slot; time; state; display; capacity; hrs; min; lvol; lamp; fill; bvol; charged; discharged; resistor; pre3vol; pre2vol; pre1vol; pre0vol")
out.write("\n")

# Read data from charger
def read_data():
	slots = [Block(i) for i in xrange(4)]
	while not sigterm: 
		# Get next data block
		block = fp.read(34)
		
		# Update data
		slot = slots[ord(block[0]) - 1]
		slot.read(block)

		# Dump to command line
		slot.dump()
		
		# Dump to CSV vile
		csv_text = slot.csv()
		out.write(csv_text)
		out.write("\n")
		out.flush()
	out.close()

# Read in thread
thr = threading.Thread(target = read_data, args=[])
thr.start()

# Wait for signal
signal.pause()

# Wait for thread
thr.join()

