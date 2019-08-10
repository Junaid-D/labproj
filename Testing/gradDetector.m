function [dets] = gradDetector(time,sig,threshold)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    filterCoeffs = [0.00490978693901733, 0.00552744069659965, 0.00735239064715894, 0.0103052953470635, 0.0142574274541768, 0.0190362972401042, 0.0244331937254776, 0.0302123134725768, 0.0361210774221532, 0.0419011840213643, 0.0472999145473743, 0.0520811954082435, 0.0560359327901525, 0.0589911668561715, 0.0608176443926426, 0.0614354780794468, 0.0608176443926426, 0.0589911668561715, 0.0560359327901525, 0.0520811954082435, 0.0472999145473743, 0.0419011840213643, 0.0361210774221532, 0.0302123134725768, 0.0244331937254776, 0.0190362972401042, 0.0142574274541768, 0.0103052953470635, 0.00735239064715894, 0.00552744069659965, 0.00490978693901733];
    numTaps = 31;

    filterWindow = zeros(1,numTaps);
    sampleRate = 120;
    slowRate = 0.1;

    sendCtr = 20;

    windowSize = ceil(sampleRate/slowRate/32);
    flag = 0;

    window = zeros(1,windowSize);
    gradScaleFac = 1000;

    triggersX = [];
    triggersY = [];


    for i = 1:length(time)



        window = [window(2:end) sig(i)*gradScaleFac];
            xy = 0;
            x2 = 0;
            xi = 0;
            for j=1:windowSize
                xy = xy+ j*window(j);
                x2 = x2 +j*j;
                xi = xi +j;
            end
        grad = (windowSize*xy - xi*sum(window)) / (windowSize * x2 - xi*xi);

        grads(i) = grad;


        if (abs(grad)>threshold)
                if(grad<0 && flag==0)%crossover
                    flag=1;
                    triggersX(end+1)=time(i);
                    triggersY(end+1)=window(end)/gradScaleFac;
                end

                if(flag==1 && grad>0)
                    flag=0;
                end
         end

    end
    dets = horzcat(triggersX.',triggersY.');


end

