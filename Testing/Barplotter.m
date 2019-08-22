clc;
clear all;

temps = {'Cold', 'Room', ' Hot'};
depths = {'Shallow', 'Normal', ' Deep'};
orifice = {'Nasal', 'Oral'};

tempsdelays = [0.2171 0.2569 0.2771];
depthsdelays = [0.2312 0.2729 0.2540];
orificedelays = [0.2653 0.2417];

tempserrs = {[2.9499 1.8265],[19.1973 2.3444],[44.8168 19.6655]};
depthserrs = {[4.2978 4.5724],[28.7668 6.6849],[29.3535 5.2735]};
orificeerrs = {[30.5470 7.6127],[11.8158 3.5286]};

outputFolder = uigetdir();

hold on;
%%temp
%bar(categorical(temps),horzcat(tempserrs{1}(1),tempserrs{2}(1),tempserrs{3}(1)),0.75,'LineStyle','--','FaceColor','m' );
%bar(categorical(temps),horzcat(tempserrs{1}(2),tempserrs{2}(2),tempserrs{3}(2)),0.65,'LineStyle','-.','FaceColor', 'g');
%xlabel('Ambient Temperatures')

%%depths
% bar(categorical(depths),horzcat(depthserrs{1}(1),depthserrs{2}(1),depthserrs{3}(1)),0.75,'LineStyle','--','FaceColor','m' );
% bar(categorical(depths),horzcat(depthserrs{1}(2),depthserrs{2}(2),depthserrs{3}(2)),0.65,'LineStyle','-.','FaceColor', 'g');
% xlabel('Depth of Breathing')

%%orifice
% bar(categorical(orifice),horzcat(orificeerrs{1}(1),orificeerrs{2}(1)),0.75,'LineStyle','--','FaceColor','m' );
% bar(categorical(orifice),horzcat(orificeerrs{1}(2),orificeerrs{2}(2)),0.65,'LineStyle','-.','FaceColor', 'g');
% xlabel('Orifice')
joinedCats = horzcat(temps,depths,orifice);
 h = bar(reordercats(categorical(joinedCats),joinedCats),horzcat(tempsdelays,depthsdelays,orificedelays));
 h.FaceColor = 'flat';
 h.CData(1,:) = [.5 0 .5];
 h.CData(2,:) = [.5 0 .5];
 h.CData(3,:) = [.5 0 .5];
 
 h.CData(4,:) = [0 0.5 .5];
 h.CData(5,:) = [0 0.5 .5];
 h.CData(6,:) = [0 0.5 .5];

 h.CData(7,:) = [0.5 0.5 0];
 h.CData(8,:) = [0.5 0.5 0];
 xlabel('Test Category')
 ylabel('Average Delay in Breath Detection (s)') 




set(gca, 'FontName', 'Times')

%ylabel('Relative error in number of detected breaths (%)') 
%legend('{\it findpeaks}','Manual');
 
hold off;


fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
file = 'orifice.pdf';
saveas(gcf,fullfile(outputFolder,file));
close;
