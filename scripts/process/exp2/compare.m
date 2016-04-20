% compare different send/receive location
close all; clear all;
data_path='../../data/exp2/';
file_folder=strcat(data_path,'mat/');
figure_folder=strcat(data_path, 'figure/');
btype = [cellstr('cloth');cellstr('metal'); cellstr('pvc'); cellstr('standman');cellstr('standwoman');cellstr('cruchman');cellstr('cruchwoman')];
% plot power-csi effect for each room state
for t = 1:numel(btype)
    files = dir(strcat(file_folder,'*barrier*',btype{t},'','*.mat'));
    h=figure;
    for i = 1:numel(files)
        f_name = files(i).name;
        load(strcat(file_folder,f_name));
        f_nonext =strsplit(f_name, '.');
        f_nonext = char(f_nonext(1));
        %[prefix,barrier, antenna,  btype, location] 
        param = strsplit(f_nonext, '_') ;
        %index = find(power_type == str2double(param(2)), 1);
        ax(i)=subplot(3,3,i);
        %C = del2(sample_pwM);
        surf(sample_pwM,'linestyle', 'none');
        ylabel('sc');
        xlabel('t(s)');
        zlabel('SNR [dB]');
        title(sprintf('LOC = %s ', char(param(5))));
    end
    cb = colorbar;
    %position: left, bottom, right, top
    set(cb, 'Position', [.9314 .11 .0181 .8150])
    for i=1:numel(files)
      pos=get(ax(i), 'Position');
      set(ax(i), 'Position', [pos(1) pos(2) 0.85*pos(3) 0.8*pos(4)]);
    end
    subtitle(strcat('EMPTY ROOM ',{' '}, '  CSI  OF VARIOUS BARRIER TYPE ',{' '},  upper(btype(t) ) ) );
    fign = char(strcat(figure_folder,'barrier_', btype(t),'.fig'));
   savefig(h, fign);
   close(h);
end
% plot people-csi effect at different tx-rx location
retenna= [cellstr('para');cellstr('orth');]
for t = 1:numel(retenna)
    files=dir(strcat(file_folder,'csi_empty_', retenna{t}, '*.mat'));
    files = regexpi({files.name}, '[\w]+_[\w]{2}.mat','match');
    files = [files{:}];
    h = figure;
    for i = 1:numel(files)
        load(strcat(file_folder,char(files(i))));
        f_nonext =strsplit(f_name, '.');
        f_nonext = char(f_nonext(1));
        %[prefix,empty, antenna,  location] 
        param = strsplit(f_nonext, '_') ;
        ax(i)=subplot(2,3,i);
        surf(sample_pwM, 'linestyle', 'none');
        ylabel('sc');
        xlabel('t(s)');
        zlabel('SNR [dB]');
        title(sprintf(' LOC=%s', char(param(4)) ));
    end
    cb = colorbar;
    %position: left, bottom, right, top
    set(cb, 'Position', [.9314 .11 .0181 .8150])
    for i=1:numel(files)
        pos=get(ax(i), 'Position');
        set(ax(i), 'Position', [pos(1) pos(2) 0.85*pos(3) 0.8*pos(4)]);
    end
    subtitle(strcat(' CSI  OF EMPTY ROOM WITH VARIOUS TxRx LOCATION'));
    fign = char(strcat(figure_folder,'tx_rx_location.fig'));
    savefig(h, fign);
    close(h);
end

% plot people-csi effect with other client at different tx-rx location
retenna= [cellstr('para');cellstr('orth');]
files=dir(strcat(file_folder,'csi_empty_', retenna{t}, '*.mat'));
files = regexpi({files.name},'[\w]+_[\w]{3,4}.mat','match');
files = [files{:}];
 h = figure;
    for i = 1:numel(files)
        load(strcat(file_folder,char(files(i))));
        f_nonext =strsplit(f_name, '.');
        f_nonext = char(f_nonext(1));
        %[prefix,empty, antenna,  location] 
        param = strsplit(f_nonext, '_') ;
        ax(i)=subplot(3,5,i);
        surf(sample_pwM, 'linestyle', 'none');
        ylabel('sc');
        xlabel('t(s)');
        zlabel('SNR [dB]');
        title(sprintf(' LOC=%s', char(param(4)) ));
    end
    cb = colorbar;
    %position: left, bottom, right, top
    set(cb, 'Position', [.9314 .11 .0181 .8150])
    for i=1:numel(files)
        pos=get(ax(i), 'Position');
        set(ax(i), 'Position', [pos(1) pos(2) 0.85*pos(3) 0.8*pos(4)]);
    end
    subtitle(strcat(' CSI  OF EMPTY ROOM WITH VARIOUS TxRxOC LOCATION'));
    fign = char(strcat(figure_folder,'tx_rx_oc_location.fig'));
    savefig(h, fign);
    close(h);
