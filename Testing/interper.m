function [tResamp,sigResamp] = interper(time,sig,factor)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
tResamp = interp(time,factor);
sigResamp = interp1(time,sig,tResamp);

end

