# Ruuvi-Remote-MQTT-App

Below is a description of a __mobile app__ in __Flutter__ displays information from the __Ruuvi Tag__ sensor, transmitted by a built-in app running on an __ESP32-S3__.

## Background

Toit's online tutorials describe the __BME280__ sensor,  can measure __temperature__, __humidity__, and __pressure__. Also provide a diagram for connecting this device to an __ESP32__ and even provide __Toit__ code for working with the sensor: https://docs.toit.io/tutorials/hardware/bme280 . I've always had great respect for people who can distinguish a transistor from a resistor or capacitor, the positive and negative terminals on a 🔋 battery, or understand the ESP32 input/output markings, much less connect them together to create a working circuit. Unfortunately, I must admit that I don't possess such talents myself.

Life, however, makes its own adjustments, and sometimes you have to find a way out of such situations. With global warming problems worsening this summer and a desire to obtain real meteorological data, I decided to find an alternative to the BME280 sensor.

### Bluetooth sensors Ruuvi Tag

And I found such an alternative without much difficulty. It's a temperature sensor from __Ruuvi__ (www.ruuvi.com). It's designed for monitoring __temperature__, __humidity__, and __pressure__ in real time. The __Ruuvi Tag__ __BLE__ protocols are open source: https://docs.ruuvi.com/communication/bluetooth-advertisements. This allowed me to write and run a simple embedded application in the __Toit__ language on an __ESP32-S3__ microcontroller. Details are in repository https://github.com/mk590901/ruuvi_ble_toit.

## Application Architecture

The frontend is a simple app receives information from the embedded application via __MQTT__ in __JSON__ format, displays it on the dashboard, and performs basic statistical processing of the data. More on this below.

In addition to the information panel, there is a dashboard for the embedded application: sensor scanning can be started, paused, resumed, or stopped completely by stopping the embedded app.

## Data Analysis

The application allows you to build trends and identify anomalies for temperature, humidity, pressure, and battery level.

Each parsed JSON packet received from the embedded application is converted into an instance of the RuuviSample class and added to a list, which is a fixed-size queue.
The RuuviAnalyzer.analyze method is called every ~20 seconds. For each parameter (__temperature__, __humidity__, __pressure__, __and battery level__), the following are calculated:
* averages for 1/6/24 hours
* derivatives (rate of change) (°C/h, %/h, hPa/h, V/h)
* deviation and rate of change anomalies
* The battery is additionally checked for absolute low levels.

## Application Pages

• Control Panel
The buttons correspond to the previously described operations: start/final scan, stop app, and sync. Last determine the current state of the embedded application.
• Dashboard
A page consisting of two parts: analytics at the top, and at the bottom
• About

## Movie
