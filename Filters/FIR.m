clc;
clear all;
samprate=120;
nyq=samprate/2;
stop = 2/nyq;

b = fir1(30,stop);
freqz(b,1,512,120)

asd=b.'