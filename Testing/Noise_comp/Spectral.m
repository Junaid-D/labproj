clc;
clear all;


x = csvread('with_analogue_without_digital.csv');

sig = x(:,1).';
time = x(:,end).';

Ts=(time(2)-time(1))/1000;
Fs=1/Ts;

L = length(time);
figure()
plot(time,sig);


Y = fft(sig);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
figure();
plot(f(1:end),P1(1:end)) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

