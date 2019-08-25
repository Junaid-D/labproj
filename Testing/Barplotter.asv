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
% joinedCats = horzcat(temps,depths,orifice);
%  h = bar(reordercats(categorical(joinedCats),joinedCats),horzcat(tempsdelays,depthsdelays,orificedelays));
%  h.FaceColor = 'flat';
%  h.CData(1,:) = [.5 0 .5];
%  h.CData(2,:) = [.5 0 .5];
%  h.CData(3,:) = [.5 0 .5];
%  
%  h.CData(4,:) = [0 0.5 .5];
%  h.CData(5,:) = [0 0.5 .5];
%  h.CData(6,:) = [0 0.5 .5];
% 
%  h.CData(7,:) = [0.5 0.5 0];
%  h.CData(8,:) = [0.5 0.5 0];
%  xlabel('Test Category')
%  ylabel('Average Delay in Breath Detection (s)') 


 joinedCats = horzcat(temps,depths,orifice);
 joinedErrsfp = horzcat(tempserrs{1}(1), tempserrs{2}(1), tempserrs{3}(1),depthserrs{1}(1),depthserrs{2}(1), depthserrs{3}(1),orificeerrs{1}(1),orificeerrs{2}(1));
 joinedErrsman = horzcat(tempserrs{1}(2), tempserrs{2}(2), tempserrs{3}(2),depthserrs{1}(2),depthserrs{2}(2), depthserrs{3}(2),orificeerrs{1}(2),orificeerrs{2}(2));
xlabel('Test Category')

h1 = bar(reordercats(categorical(joinedCats),joinedCats),joinedErrsfp,0.8);
h2 = bar(reordercats(categorical(joinedCats),joinedCats),joinedErrsman,0.6);
 h1.FaceColor = 'flat';
 h1.CData(1,:) = [.5 0 .5];
 h1.CData(2,:) = [.5 0 .5];
 h1.CData(3,:) = [.5 0 .5];
 
 h1.CData(4,:) = [0 0.5 .5];
 h1.CData(5,:) = [0 0.5 .5];
 h1.CData(6,:) = [0 0.5 .5];

 h1.CData(7,:) = [0.5 0.5 0];
 h1.CData(8,:) = [0.5 0.5 0];
 
 
 h2.FaceColor = 'flat';
 h2.CData(1,:) = [1 0 .5];
 h2.CData(2,:) = [1 0 .5];
 h2.CData(3,:) = [1 0 .5];
 
 h2.CData(4,:) = [0 0.5 1];
 h2.CData(5,:) = [0 0.5 1];
 h2.CData(6,:) = [0 0.5 1];

 h2.CData(7,:) = [0.5 1 0];
 h2.CData(8,:) = [0.5 1 0];
set(gca, 'FontName', 'Times')
t1 = 'findpeaks - (Wide and Dark)';
t2 = 'Manual - (Narrow and Light)';
t = annotation('textbox');
t.Position  = [0.5 0.8 t.Position(3) t.Position(4)]% 0.4 0.5];
line = sprintf('%s\n%s', t1,t2);
t.String = line;
drawnow;
ylabel('Relative error in number of detected breaths (%)') 
%legend('{\it findpeaks}','Manual');
 
hold off;


fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
outputFolder = uigetdir();

file = 'allone.pdf';
saveas(gcf,fullfile(outputFolder,file));
close;
