close all; clear all;
pwd
data_path='../../data/exp4/';
%data: ping rate: 100 packets/s
file_folder = strcat(data_path, 'data/'); 
figure_folder=strcat(data_path, 'figure/'); mkdir(data_path, 'figure');
mat_folder=strcat(data_path,'mat/'); mkdir(data_path, 'mat');
files = dir(strcat(file_folder,'csi_empty*.dat'));
addpath('../../../linux-80211n-csitool-supplementary/matlab/');
for i = 1:numel(files)
    f_name = files(i).name;
    f_nonext=f_name(1:end-4);
    disp(f_name)
    csi_trace = read_bf_file(strcat(file_folder,f_name));
    tx = 3;
    rx = 3;
    subcarrier = 30;
    sample_tx = 1;
    sample_rx = 1;
    ts =  length(csi_trace);
    pwM = zeros( tx, rx, subcarrier, ts);
    csiM = zeros( tx, rx, subcarrier, ts);
    antenna = zeros(ts);
    min_len = inf;
    for j = 1:numel(csi_trace)
        csi_entry = csi_trace{j};	
        if isempty(csi_entry)
            if min_len > j - 1
                    min_len= j - 1;
            end
            break
        end
        csi = get_scaled_csi(csi_entry);
        [tx_real, rx_real, sub_real] = size(csi);
        pw = db(abs(squeeze(csi)));
        antenna(j) = tx_real;
        pwM(1:tx_real,1:rx_real,:,j) = pw;
        csiM(1:tx_real,1:rx_real,:,j) = csi;
    end
    % plot each time-subcarrier-CSI graph at different tx*rx channel
    startcut = 50;
    endcut = 0;
    h = figure;
    for x = 1:3
        for y = 1:3
            id = (x-1)*3+y;
            ax(id) = subplot(3,3,id);
            surf(squeeze(pwM(x,y,:,startcut:min(min_len, numel(csi_trace) - endcut ))),'linestyle','none');
            ylabel('sc');
            xlabel('t(s)');
            zlim(ax(id), [0 40]);
            zlabel('Magnitude[dB]');
            title(sprintf('tx = %d,rx = %d', x, y));
    end
end
% set global colorbar and title
cb = colorbar;
%position: left, bottom, right, top
set(cb, 'Position', [.9314 .11 .0181 .8150])
for i=1:x*y
      pos=get(ax(i), 'Position');
      set(ax(i), 'Position', [pos(1) pos(2) 0.85*pos(3) 0.8*pos(4)]);
end
subtitle( upper(strrep(char(f_nonext),'_',' ')) );
fign = char(strcat(figure_folder,f_nonext,'_total.fig'));
saveas(h, fign);
mat = char(strcat(mat_folder,f_nonext,'.mat' ));
sample_csiM = squeeze(csiM(:,:,:, startcut:min(numel(csi_trace) - endcut, min_len)));
save(mat, 'sample_csiM');
close(h);

%plot antenna number
h = figure;
plot(antenna(startcut:min(min_len, numel(csi_trace))));
fign = char(strcat(figure_folder,f_nonext,'_antenna.fig'));
title('NUMBER OF TRANMISTTER ANTENNA');
saveas(h, fign);
close(h);
% subplot(312);
% plot(squeeze(pw(:,2,:)).');
% legend('TX Antenna A', 'TX Antenna B', 'TX Antenna C', 'Location', 'SouthEast' );
% xlabel('Subcarrier index');
% ylabel('SNR [dB]');
% title('RX Antenna B');
% subplot(313);
% plot(squeeze(pw(:,3,:)).');
% legend('TX Antenna A', 'TX Antenna B', 'TX Antenna C', 'Location', 'SouthEast' );
% xlabel('Subcarrier index');
% ylabel('SNR [dB]');
% title('RX Antenna C');
% db(get_eff_SNRs(csi), 'pow');
% fign = char(strcat('figure/',f_nonext,'.fig'));
% savefig(h, fign);
% close(h);
end   
