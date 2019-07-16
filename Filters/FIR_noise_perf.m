clc;
clear all;
samprate=120;
nyq=samprate/2;
stop = 0.1/nyq;

b = fir1(1997,0.0001);
figure()
freqz(b,1,512,120)

rate=0.1;%Hz
breathFunc= @(x) 0.4*sin(2*pi*x*rate) + 3.2;
duration=20;
sampleRate=120;
SMA=0;
windowSize = length(b);
window=zeros(1,windowSize);

t=linspace(0,duration,sampleRate*duration);


sig=breathFunc(t);
sig= awgn(sig,40,'measured');

flag=0;

triggersX=[];
triggersY=[];
SMAs=zeros(1,length(t));


for i=1:length(t)
    window = [window(2:end) 0];
    window(end)=breathFunc(t(i));
    
    SMA=sum(window.*b);
    SMAs(i)=SMA;
    sample=breathFunc(t(i));
    
    if(sample>SMA && flag==0)%crossover
                disp('asd');
        flag=1;
        triggersX(end+1)=t(i);
        triggersY(end+1)=sample;
    end
    
    if(flag==1 && sample<SMA)
        flag=0;
    end    
    
end
set(gca,'fontname','times')  % Set it to times
figure()
triggersX

hold on;
plot(t,sig)
plot(t,SMAs)

line([t(windowSize) t(windowSize)], [0 5],'Color','black','LineStyle','--'); 
plot(triggersX,triggersY,'r*');
hold off;

%title('Performance of Simple Breath Detection Algorithm')
legend({'Breath Signal','SMA Window Size','Detected Crossovers'},'Location','southwest')
xlabel('Time (s)') 
ylabel('Temperature (°C)') 


