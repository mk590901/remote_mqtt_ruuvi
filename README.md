# Ruuvi-Remote-MQTT-App

Below is a description of a __mobile app__ in __Flutter__ displays information from the __Ruuvi Tag__ sensor, transmitted by a built-in app running on an __ESP32-S3__.

<img width="1204" height="1600" alt="ruuvi" src="https://github.com/user-attachments/assets/6f41619c-1e7b-45a1-83ef-a527a54c5549" />

## Background

Toit's online tutorials describe the __BME280__ sensor,  can measure __temperature__, __humidity__, and __pressure__. Also provide a diagram for connecting this device to an __ESP32__ and even provide __Toit__ code for working with the sensor: https://docs.toit.io/tutorials/hardware/bme280 . I've always had great respect for people who can distinguish a transistor from a resistor or capacitor, the positive and negative terminals on a 🔋 battery, or understand the ESP32 input/output markings, much less connect them together to create a working circuit. Unfortunately, I must admit that I don't possess such talents myself.

Life, however, makes its own adjustments, and sometimes you have to find a way out of such situations. With global warming problems worsening this summer and a desire to obtain real meteorological data, I decided to find an alternative to the BME280 sensor.

### Bluetooth sensors Ruuvi Tag

And I found such an alternative without much difficulty. It's a temperature sensor from __Ruuvi__ (www.ruuvi.com). It's designed for monitoring __temperature__, __humidity__, and __pressure__ in real time. The __Ruuvi Tag__ __BLE__ protocols are open source: https://docs.ruuvi.com/communication/bluetooth-advertisements. This allowed me to write and run a simple embedded application in the __Toit__ language on an __ESP32-S3__ microcontroller. Details are in repository https://github.com/mk590901/ruuvi_ble_toit.

## Application Architecture

The frontend is a simple app receives information from the embedded application via __MQTT__ in __JSON__ format, displays it on the information panel, and performs basic statistical processing of the data. More on this below.

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

> Dashboard

The buttons correspond to the previously described operations: start/final scan, stop app, and sync. Last determine the current state of the embedded application.

> Info Panel

A page consisting of two parts: analytics at the top, and at the bottom

> About

No comments

> Pictures

 <table>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/a6e709f8-ca04-44e3-b17f-b8be03b916eb" width="350"><br>
      <b>Dashboard</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/352b42dc-967e-46f2-aeff-7221942593b6" width="350"><br>
      <b>Information panel</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/f53905d2-f0c7-48d3-9fe2-9fe61221c05d" width="350"><br>
      <b>About</b>
    </td>  
  </tr>
</table>

## Movie

Hereinafter, a short video demonstrating the app's operation, displaying sensor information:

https://github.com/user-attachments/assets/4cddfbdd-0ed0-47fd-97c1-e88869990d88

