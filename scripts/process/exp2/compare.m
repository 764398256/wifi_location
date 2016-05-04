% compare different send/receive location
close all; clear all;
data_path='../../data/exp2/';
file_folder=strcat(data_path,'mat/');
figure_folder=strcat(data_path, 'figure/');
btype = [cellstr('cloth');cellstr('metal'); cellstr('pvc'); cellstr('standman');cellstr('standwoman');cellstr('cruchman');cellstr('cruchwoman')];
%plot power-csi effect for each room state
for t = 1:numel(btype)
    files = dir(strcat(file_folder,'*barrier*',btype{t},'','*.mat'));
    files = {files.name};
    subgraph(file_folder,files,3,3,5, 'LOC=%s',...
                    strcat('EMPTY ROOM ',{' '}, '  CSI  OF VARIOUS BARRIER TYPE ',{' '},  upper(btype(t) ) ), ...
                     char(strcat(figure_folder,'barrier_', btype(t),'.fig')) );
end
% plot csi effect at different tx-rx location
antenna= [cellstr('para');cellstr('orth');];
for t = 1:numel(antenna)
    files=dir(strcat(file_folder,'csi_empty_', antenna{t}, '*.mat'));
    files = regexpi({files.name}, '[\w]+_[\w]{2}.mat','match');
    files = [files{:}];
       subgraph(file_folder,files,2,3,4, 'LOC=%s',...
                    strcat(' CSI  OF EMPTY ROOM TxRxLoc-Antenna-', antenna{t}), ...
                   char(strcat(figure_folder,'tx_rx_', antenna{t}, '_location.fig')) );
end

% plot csi effect with other client at different tx-rx location
files=dir(strcat(file_folder,'csi_empty_para*.mat'));
files = regexpi({files.name},'[\w]+_[\w]{3,4}.mat','match');
files = [files{:}];
subgraph(file_folder,files,3,5,4, 'LOC=%s',...
                    ' CSI  OF EMPTY ROOM TxRxOCLoc', ...
                     char(strcat(figure_folder,'tx_rx_oc_location.fig')) )
 % plot people-csi effect with other client at different tx-rx location
loc=[cellstr('ABG1');cellstr('ABE');cellstr('ABG2');cellstr('ACE'); cellstr('ACB');cellstr('EAF1');cellstr('EAF2'),;cellstr('EAF3');cellstr('EAH')];
for t = 1:numel(loc)
    files=dir(strcat(file_folder,'csi_barrier_para_*_',loc{t},'.mat'));
    files={files.name};
    subgraph(file_folder,files,2,4,4, 'Barrier=%s',...
                    char(strcat('CSI  OF BARRIERED ROOM',{' '}, loc{t}, ' BARRIERS')), ...
                     char(strcat(figure_folder,'tx_rx_barrier_', loc{t},'.fig' ) ));
end
