#!/bin/python

import subprocess
import json
import os
import time

lockfile_folder = f'{os.getenv("HOME")}/.temp/device-battery'

if not os.path.exists(lockfile_folder):
    subprocess.run(['mkdir', '-p', lockfile_folder])

device_name_header = 'Device:'
model_name_header = 'model:'
has_statistiscs_header = 'has statistics:'
percentage_header = 'percentage:'

model_property = 'model'
has_statistiscs_property = 'has_statistiscs'
percentage_property = 'percentage'

warning_threshold = 15.0

result = subprocess.run(['upower', '--dump'], stdout=subprocess.PIPE, encoding='UTF-8')

devices = []
device_index = -1

def filter_with_model_and_statistics(device):
    return device[model_property] != None and device[has_statistiscs_property] == True

def parse_line_value(line):
    return line.split(':')[1].strip()

for line in result.stdout.split('\n'):
    stripped_line = line.strip()
    
    if stripped_line.startswith(device_name_header):
        device_index += 1
        devices.append({ model_property: None, has_statistiscs_property: None, percentage_property: None })
    
    if device_index >= 0:
        if stripped_line.startswith(model_name_header):
            devices[device_index][model_property] = parse_line_value(stripped_line)

        if stripped_line.startswith(has_statistiscs_header):
            devices[device_index][has_statistiscs_property] = parse_line_value(stripped_line) == 'yes'

        if stripped_line.startswith(percentage_header):
            devices[device_index][percentage_property] = parse_line_value(stripped_line)

device_string = '\n'
battery_numbers = []
lockfiles = []

for device in filter(filter_with_model_and_statistics, devices):
    battery_number = float(device[percentage_property].replace('%',''))
    battery_numbers.append(battery_number)
    if battery_number <= warning_threshold:
        simple_name = device[model_property].replace("/", "").replace(" ", "")
        lockfile_path = f'{lockfile_folder}/{simple_name}.notif.lock'
        if not os.path.exists(lockfile_path):
           lockfile = open(lockfile_path, "x")
           lockfile.close()
           lockfiles.append(lockfile_path)
           subprocess.run(['notify-send', f'[{device[model_property]}] \n\nLow Battery: {device[percentage_property]}'])
    device_string += f'{device[model_property]}: {device[percentage_property]}\n'

average_battery = int(sum(battery_numbers) / len(battery_numbers))
icon = "󰁺"

if average_battery > 10 and average_battery <= 20:
    icon = "󰁻"

if average_battery > 20 and average_battery <= 30:
    icon = "󰁼"

if average_battery > 30 and average_battery <= 40:
    icon = "󰁽"

if average_battery > 40 and average_battery <= 50:
    icon = "󰁾"

if average_battery > 50 and average_battery <= 60:
    icon = "󰁿"

if average_battery > 60 and average_battery <= 70:
    icon = "󰂀"

if average_battery > 70 and average_battery <= 80:
    icon = "󰂁"

if average_battery > 80 and average_battery <= 90:
    icon = "󰂂"

if average_battery > 90:
    icon = "󰁹"

json_response = {
    "text": f'{icon} {average_battery}%',
    "alt": f'{icon}',
    "tooltip": device_string
}

print(json.dumps(json_response))

time.sleep(3)

for lockfile in lockfiles:
    os.remove(lockfile)


