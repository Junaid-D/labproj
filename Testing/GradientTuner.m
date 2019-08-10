clc;
clear all;
file = 'M-35-N-N-M.csv';
x = csvread(file);

detsWStamps=x;

[~,idu] = unique(detsWStamps(:,3));
uniqueDetVals = detsWStamps(idu,:);
uniqueDetVals = uniqueDetVals(2:end,:);

hold on;

%x = resample(x,120,3);
t = x(:,5).'/1000;
tResample = interp(t,40);
signal = interp1(t,x(:,2).',tResample);

%signal = awgn(signal,60);
%plot(tResample,signal);
%plot(x(:,5).'/1000,x(:,2).');
hold off;

%consistent with arduino
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

thresh = 0.05;
triggersX = [];
triggersY = [];

for i = 1:length(tResample)
    
    
    
    window = [window(2:end) signal(i)*gradScaleFac];
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


    if (abs(grad)>thresh)
            if(grad<0 && flag==0)%crossover
                flag=1;
                triggersX(end+1)=tResample(i)
                triggersY(end+1)=window(end)/gradScaleFac;
            end

            if(flag==1 && grad>0)
                flag=0;
            end
     end

end
hold on;
%plot(tResample, signal);
%line([t(windowSize) t(windowSize)], [27 33],'Color','black'); 
%plot(triggersX,triggersY,'r*');
%plot(uniqueDetVals(:,5).'/1000,uniqueDetVals(:,2).','go');
band1 = ones(1,length(tResample))*thresh;

above = 1;
hsytCount = 0;
%%%detect hysterysis errors
crossPos = [];
crossNeg = [];
grads = grads - thresh;

zci = @(v) find(v(:).*circshift(v(:), [-1 0]) <= 0);% Returns Zero-Crossing Indices Of Argument Vector
zeroCrosses1 = zci(grads);


grads = grads + 2*thresh;


zeroCrosses2 = zci(grads);
grads = grads - thresh;

%%%%

plot(tResample, grads,'b');
plot(tResample, band1,'g');
plot(tResample, -band1,'g');
plot(tResample(zeroCrosses1),grads(zeroCrosses1),'r*')
plot(tResample(zeroCrosses2),grads(zeroCrosses2),'m*')


hold off


