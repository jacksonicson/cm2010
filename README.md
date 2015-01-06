cm2010
======

Python script that records log-data of the Conrad Charge Manager 2010 serial interface (tty). All relevant data is stored into a CSV file for later analysis (R-Scripts).

# Byte Format

Based on [CM2010](http://cm2010.sourceforge.net/)

| Byte   | Description                                                                   |
|--------|-------------------------------------------------------------------------------|
| 0      | Number of the charger slot                                                    |
| 1 high | Unknown                                                                       |
| 1 low  | Current display state (see display states table)                              |
| 2 high | Battery capacity (manual selection or automatic) (see battery capacity table) |
| 2 low  | Charging program state (see program state table)                              |
| 3      | Unknown                                                                       |
| 4      | Internal counter (time)                                                       |
| 5      | Charging hours                                                                |
| 6      | Charging minutes                                                              |
| 7      | Unknown                                                                       |
| 8-9    | Voltage (U in mV) if charging otherwise 0x0000                                |
| 10     | Unknown                                                                       |
| 11     | Unknown                                                                       |
| 12     | Unknown                                                                       |
| 13-14  | Amperage (I in mA) if charging and discharging                                |
| 15-16  | Voltage (U in mV) of the battery                                              |
| 17-19  | Charged capacity (CCap in 10e-2 mAh)                                          |
| 20-22  | Discharged capacity (DCap in 10e-2 mAh)                                       |
| 23     | Unknown                                                                       |
| 24-25  | Previous voltage (-4 intervals)                                               |
| 25-27  | Previous voltage (-3 intervals)                                               |
| 28-29  | Previous voltage (-2 interval)                                                |
| 30-31  | Previous voltage (-1 interval)                                                |
| 32-33  | Resistor in charger slot (0xFFFF if no battery otherwise in 10e-2 MOhm)       |

## Display State

| HEX    | Description               |
|--------|---------------------------|
| 0x00   | --- (no battery in slot)  |
| 0x01   | SELECT AUTO/MAN: AUTO     |
| 0x02   | SELECT AUTO/MAN: MANUAL   |
| 0x03   | SELECT PROGRAM: CHARGE    |
| 0x04   | SELECT PROGRAM: DISCHARGE |
| 0x05   | SELECT PROGRAM: CHECK     |
| 0x06   | SELECT PROGRAM: CYCLE     |
| 0x07   | SELECT PROGRAM: ALIVE     |
| 0x08   | CHA                       |
| 0x09   | DIS                       |
| 0x0A   | CHK                       |
| 0x0B   | CYC                       |
| 0x0C   | ALV                       |
| 0x0D   | RDY                       |
| 0x0E   | ERR                       |
| 0x0F   | TRI                       |

## Selected Battery Capacity

| HEX  | Description         |
|------|---------------------|
| 0x00 | Automatic detection |
| 0x01 | 100-200 mAh         |
| 0x02 | 200-350 mAh         |
| 0x03 | 350-600 mAh         |
| 0x04 | 600-900 mAh         |
| 0x05 | 900-1200 mAh        |
| 0x06 | 1200-1500 mAh       |
| 0x07 | 1500-2200 mAh       |
| 0x08 | 2200-... mAh        |

## Charging Program State

| HEX  | Description                                             |
|------|---------------------------------------------------------|
| 0x00 | No charging program active (no battery in charger slot) |
| 0x01 | Charging (Alive)                                        |
| 0x02 | Discharging                                             |
| 0x03 | Charging (Cycle)                                        |
| 0x04 | Discharging (Check)                                     |
| 0x05 | Charging (Charge)                                       |
| 0x06 | Discharging (Discharge)                                 |
| 0x07 | Trickle charge                                          |
| 0x08 | Ready (done charging)                                   |

# Example Output

![Battery Voltage of 4 Charge Slots](/batteryVoltage.png)
