clc;
clear all;
samprate=120;
nyq=samprate/2;
stop = 0.1/nyq;

b = fir1(10,stop);
freqz(b,1,512)