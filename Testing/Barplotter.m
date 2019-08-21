clc;
clear all;

temps = {'Cold', 'Room', ' Hot'};
depths = {'Shallow', 'Normal', ' Deep'};


tempserrs = {[2.9499 1.8265],[19.1973 2.3444],[44.8168 19.6655]};
%outputFolder = uigetdir();

hold on;
bar(categorical(temps),horzcat(tempserrs{1}(1),tempserrs{2}(1),tempserrs{3}(1)),0.75,'LineStyle','--','FaceColor','m' );
bar(categorical(temps),horzcat(tempserrs{1}(2),tempserrs{2}(2),tempserrs{3}(2)),0.65,'LineStyle','-.','FaceColor', 'g');


set(gca, 'FontName', 'Times')
xlabel('Ambient Temperatures')
ylabel('Relative error in number of detected breaths (%)') 
legend('{\it findpeaks}','Manual');
 
hold off;


fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
file = 'temps.pdf';
saveas(gcf,fullfile(outputFolder,file));
close;
