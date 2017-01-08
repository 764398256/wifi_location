close all; 
clear all;
data_path='../../../data/exp6/';
file_folder=strcat(data_path,'mat/');
figure_folder=strcat(data_path, 'figure/');
mat_folder=strcat(data_path,'mat/');

% extract main features
%empty_file=dir(strcat(file_folder,'m*_empty.mat'));

stand_file=dir(strcat(file_folder,'m*_fg_s*.mat'));
multi_tg_file = dir(strcat(file_folder,'m*_fg_three_13_17_112.mat'));
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
map = ones(15,3);
[row, col] = size(map);
voxel_num = sum(sum(map == 1));
pos = find(map == 1);
index = [mod(pos + row - 1, row) + 1, floor((pos + row - 1)/row)];
sample_len = 300;
stream_num = 3;
subcarrier_num = 30;
voxel_num = voxel_num + 1;
%generate edges
edges = bfs(map, index);

%generate sampling data(single target)
phase = 1;
feature_dim = subcarrier_num;
if  phase
    feature_dim = 2*(subcarrier_num - 1);
end
M = zeros(voxel_num,stream_num, feature_dim,  sample_len*2);

train_data = 1;

if train_data == 1
if 0
    for i= 1:numel(stand_file)
    fname = stand_file(i).name;
    disp(fname);
    tag = str2double(regexpi(fname, '[\d+]*', 'match'));
    load(strcat(file_folder,fname));
    if length(tag) > 1
        voxel_id = find(ismember(index, [tag(2), tag(3)], 'rows'));
        static = length(strfind(fname, 'static'));
        if ~ phase
              h_avg_amp = amplitude(sample_csiM(:,:,:,1:sample_len));
        else
              h_avg_amp = feature_csi(sample_csiM(:,:,:,1:sample_len));
        end
        M(voxel_id, tag(1), :, ( static )* sample_len + 1: (static + 1) *sample_len ) = h_avg_amp;
    else
        voxel_id = voxel_num;
        if ~ phase
            h_avg_amp = amplitude(sample_csiM(:,:,:,1:sample_len*2));
        else
            h_avg_amp = feature_csi(sample_csiM(:,:,:,1:sample_len*2));
        end
        M(voxel_id, tag(1), :,  1: 2*sample_len ) = h_avg_amp;
    end

    end
end

load('M.mat', 'M');
M = M(:,:,21:25,:);
if phase
    histo = fingerprint_builder_csi(M); 
else
    histo = fingerprint_builder_refine(M); 
end
Config.histo = histo;
Config.edges = edges;
Config.mapper= index;
Config.grid  = map;
M = squeeze(M);
sample_len = 10;
feature_ext = 5;
K = zeros(voxel_num*sample_len*2,stream_num*feature_ext);
label = zeros(voxel_num*sample_len*2,1);
for i = 1: voxel_num
  %K((i-1)*sample_len*2+ 1:i*sample_len*2, :) =  reshape(permute(squeeze(M(i, :, :,1:sample_len)), [3,1,2]), sample_len*2, stream_num*feature_dim);
  K((i-1)*sample_len*2+ 1:i*sample_len*2, :) =  reshape(permute(squeeze(M(i, :, :,1:sample_len*2)), [3,1,2]), sample_len*2, stream_num*feature_ext);
  label((i-1)*sample_len*2+ 1:i*sample_len*2) = i;
end
Train.seq =  squeeze(K);
Train.label = label;


config_file = char(strcat(mat_folder,'config_s10_csi_amp_5.mat' ));
save(config_file, 'Config');
train_file = char(strcat(mat_folder, 'sample_s10_csi_amp_5.mat'));
save(train_file, 'Train');


end
% generate test data for multiple targets
M_test = zeros(sample_len, stream_num*feature_ext );
for i = 1: numel(multi_tg_file)
fname = multi_tg_file(i).name;
disp(fname);
prefix = fname(3:end-4);
load(strcat(file_folder,fname));        
if ~ phase
     h_avg_amp = amplitude(sample_csiM(:,:,:,1:sample_len));
else
     h_avg_amp = feature_csi(sample_csiM(:,:,:,1:sample_len));
end
M_test(:,(i-1)*feature_ext+1:i*feature_ext) = h_avg_amp(21:25,:)';
end
Test.seq=M_test;
M_test_file =  char(strcat(mat_folder,'Test',prefix , '_s10.mat' ));
save(M_test_file, 'Test');


