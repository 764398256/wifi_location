close all; 
clear all;
data_path='../../../data/exp3/';
file_folder=strcat(data_path,'mat/');
figure_folder=strcat(data_path, 'figure/');
mat_folder=strcat(data_path,'mat/');

% extract main features
%empty_file=dir(strcat(file_folder,'m*_empty.mat'));

stand_file=dir(strcat(file_folder,'csi_*.mat'));
% map = [-1, 1, -1, 1, -1, 1, -1; ...\
%         -1, 1, -1, 1, -1, 1, -1; ...\
%         -1, 1, -1, 1, -1, 1, -1; ...\
%         -1, 1, -1, 1, -1, 1, -1; ...\
%         -1, 1, -1, 1, -1, 1, -1; ...\
%         -1, 1, -1, 1, -1, 1, -1; ...\
%         -1, 1, -1, 1, -1, 1, -1; ...\
%         -1, 1, -1, 1, -1, 1, -1; ...\
%         -1, 1, -1, 1, -1, 1, -1; ...\
%         -1, 1, -1, 1, -1, 1, -1; ...\
%         -1, 1, -1, 1, -1, 1, -1; ...\
%         -1, 1, -1, 1, -1, 1, -1;...\
%         -1, 1, -1, 1, -1, 1, -1; ...\
%         1, 1, 1, 1, 1, 1, 1; ...\
%         1, 1, 1, 1, 1, 1, 1; ...\
%         1, 1, -1, -1, -1, 1, 1 ...\
% ];
map = ones(9,6);
[row, col] = size(map);
voxel_num = sum(sum(map == 1));
pos = find(map == 1);
index = [mod(pos + row - 1, row) + 1, floor((pos + row - 1)/row)];
sample_len = 300;
stream_num = 1;
subcarrier_num = 30;
%generate edges
edges = bfs(map, index);

%generate sampling data(single target)
phase = 1;
feature_dim = subcarrier_num;
if  phase
    feature_dim = 2*(subcarrier_num - 1);
end
M = zeros(voxel_num,stream_num, feature_dim,  sample_len);

train_data = 1;

if train_data == 1
if 0
    for i= 1:numel(stand_file)
    fname = stand_file(i).name;
    disp(fname);
    load(strcat(file_folder,fname));
    params = strread(fname(1:end-4),'%s','delimiter','_');
    tag = str2num(char(params(2:3)))/0.5;
    if length(tag) > 1
        voxel_id = find(ismember(index, [tag(1), tag(2)], 'rows'));
        if ~ phase
              h_avg_amp = amplitude(sample_csiM(:,:,:,1:sample_len));
        else
              h_avg_amp = feature_csi(sample_csiM(:,:,:,1:sample_len));
        end
        M(voxel_id, 1, :, : ) = h_avg_amp;
    end
    end
end

load('M_exp3.mat', 'M');
M = M(:,:,:,:);
if phase
    histo = fingerprint_builder_csi(M); 
else
    histo = fingerprint_builder_refine(M); 
end
Config.histo = histo;
Config.edges = edges;
Config.mapper= index;
Config.grid  = map;
sample_len = 10;
feature_ext = 5;
K = zeros(voxel_num*sample_len,stream_num*feature_ext);
label = zeros(voxel_num*sample_len,1);
for i = 1: voxel_num
  %K((i-1)*sample_len*2+ 1:i*sample_len*2, :) =  reshape(permute(squeeze(M(i, :, :,1:sample_len)), [3,1,2]), sample_len*2, stream_num*feature_dim);
  K((i-1)*sample_len+ 1:i*sample_len, :) =  reshape(permute(squeeze(M(i, :, :,1:sample_len)), [3,1,2]), sample_len, stream_num*feature_ext);
  label((i-1)*sample_len+ 1:i*sample_len) = i;
end
Train.seq =  squeeze(K);
Train.label = label;


config_file = char(strcat(mat_folder,'exp3_config_s10_csi_amp_5.mat' ));
save(config_file, 'Config');
train_file = char(strcat(mat_folder, 'exp3_sample_s10_csi_amp_5.mat'));
save(train_file, 'Train');


end


