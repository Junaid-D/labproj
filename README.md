# Breath Detection and RR Calculation Algorithms for Arduino Deployment



### Two main categories of implementations can be found in this repo:

## Threshold-Based
 compare a signal to its average value and detect crossings (obtain average through some filtering technique)

 filters include SMA (boxcar), FIR butterworth, IIR

 `/SMA/`

`/Filters/`


## Gradient-Based

Detect peaks when gradient changes from + to -.

 `/Grad/`


### Some filters can also be found.

#This Repo also contains a GUI App (Matlab AppDesigner) for monitoring and plotting RR. Allowing for connection over BT or USB. 


### This code is intended for use with Atmega 168/328 with 16x2 LCD.