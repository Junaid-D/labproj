clc;
clear all;

Fs = 120;
T = 1/Fs;

x = csvread('with_analogue_without_digital.csv');

sig = x(:,1).';
time = x(:,end).';
L = length(time);
figure()
plot(time,sig);


Y = fft(sig);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
figure();
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

