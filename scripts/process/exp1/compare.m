close all; clear all;
file_folder = '../mat/';
figure_folder='../figure/';
status_type = [cellstr('empty');cellstr('stationarymid');cellstr('walkpara');cellstr('walkorth')];
power_type= [1, 10, 50, 100, 200, 500, 800, 1000];
% plot power-csi effect for each room state
for t = 1:numel(status_type)
    files = dir(strcat(file_folder,'*',status_type{t},'.mat'));
    h=figure;
    for i = 1:numel(files)
        f_name = files(i).name;
        load(strcat(file_folder,f_name));
        f_nonext =strsplit(f_name, '.');
        f_nonext = char(f_nonext(1));
        %[prefix, power,  trate, status] 
        param = strsplit(f_nonext, '_') ;
        index = find(power_type == str2double(param(2)), 1);
        ax(i)=subplot(2,4,index);
        %C = del2(sample_pwM);
        surf(sample_pwM,'linestyle', 'none');
        ylabel('sc');
        xlabel('t(s)');
        zlabel('SNR [dB]');
        title(sprintf('power = %s mW', char(param(2))));
    end
    cb = colorbar;
    %position: left, bottom, right, top
    set(cb, 'Position', [.9314 .11 .0181 .8150])
    for i=1:numel(files)
      pos=get(ax(i), 'Position');
      set(ax(i), 'Position', [pos(1) pos(2) 0.85*pos(3) 0.8*pos(4)]);
    end
    subtitle(strcat('ROOM',{' '}, upper(status_type(t)),'  CSI  OF VARIOUS TX POWER'));
    fign = char(strcat(figure_folder,status_type(t),'_txp.fig'));
   savefig(h, fign);
   close(h);
end
% plot people-csi effect at certain power 
sample_p = 100;
files = dir(strcat(file_folder,'csi_', int2str(sample_p),'_*.mat'));
h = figure;
for i = 1:numel(files)
        f_name = files(i).name;
        load(strcat(file_folder,f_name));
        f_nonext =strsplit(f_name, '.');
        f_nonext = char(f_nonext(1));
        %[prefix, power,  trate, status] 
        param = strsplit(f_nonext, '_') ;
        ax(i)=subplot(2,2,i);
        surf(sample_pwM, 'linestyle', 'none');
        ylabel('sc');
        xlabel('t(s)');
        zlabel('SNR [dB]');
        title(sprintf('Status %s', char(param(4))));
end
cb = colorbar;
%position: left, bottom, right, top
set(cb, 'Position', [.9314 .11 .0181 .8150])
for i=1:numel(files)
    pos=get(ax(i), 'Position');
    set(ax(i), 'Position', [pos(1) pos(2) 0.85*pos(3) 0.8*pos(4)]);
end
subtitle(strcat(' CSI  OF VARIOUS ROOM STATE AT 100mW TXPWR'));
fign = char(strcat(figure_folder,'people_status.fig'));
savefig(h, fign);
close(h);