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
map = [-1, 1, -1, 1, -1, 1, -1; ...\
        -1, 1, -1, 1, -1, 1, -1; ...\
        -1, 1, -1, 1, -1, 1, -1; ...\
        -1, 1, -1, 1, -1, 1, -1; ...\
        -1, 1, -1, 1, -1, 1, -1; ...\
        -1, 1, -1, 1, -1, 1, -1; ...\
        -1, 1, -1, 1, -1, 1, -1; ...\
        -1, 1, -1, 1, -1, 1, -1; ...\
        -1, 1, -1, 1, -1, 1, -1; ...\
        -1, 1, -1, 1, -1, 1, -1; ...\
        -1, 1, -1, 1, -1, 1, -1; ...\
        -1, 1, -1, 1, -1, 1, -1;...\
        -1, 1, -1, 1, -1, 1, -1; ...\
        1, 1, 1, 1, 1, 1, 1; ...\
        1, 1, 1, 1, 1, 1, 1; ...\
        1, 1, -1, -1, -1, 1, 1 ...\
];

[row, col] = size(map);
voxel_num = sum(sum(map == 1));
pos = find(map == 1);
index = [mod(pos + row - 1, row) + 1, floor((pos + row - 1)/row)];
sample_len = 600;
stream_num = 3;
subcarrier_num = 30;
M = zeros(voxel_num,stream_num, subcarrier_num,  sample_len*2);
%generate edges
edges = bfs(map, index);
edge_file = char(strcat(mat_folder,'edges.mat' ));
save(edge_file, 'edges');

%generate sampling data(single target)

train_data = 0;

if train_data == 1
label = zeros(numel(stand_file), 2);
for i= 1:numel(stand_file)
    fname = stand_file(i).name;
    disp(fname);
    tag = str2double(regexpi(fname, '[\d+]*', 'match'));
    load(strcat(file_folder,fname));
    voxel_id = find(ismember(index, [tag(2), tag(3)], 'rows'));
    h_avg_amp = amplitude(sample_csiM(:,:,:,1:sample_len));
    static = length(strfind(fname, 'static'));
    M( voxel_id, tag(1), :, ( static )* sample_len + 1: (static + 1) *sample_len ) = h_avg_amp;
end
M = mean(M, 3);
histo = fingerprint_builder(M); 
histo_file = char(strcat(mat_folder,'histo.mat' ));
sample_file = char(strcat(mat_folder, 'sample.mat'));
sample_label_file = char(strcat(mat_folder, 'sample_label.mat'));
M = squeeze(M);
save(histo_file, 'histo');
save(sample_file, 'M');
save(sample_label_file, 'label');

figure;
subplot(211);
plot([-30+0.5:0.5:30], squeeze(histo(1,2,1, :)));
subplot(212);
plot([-30+0.5:0.5:30], squeeze(histo(1,2,2, :)));

end
% generate test data for multiple targets
M_test = zeros(stream_num, sample_len );
for i = 1: numel(multi_tg_file)
fname = multi_tg_file(i).name;
disp(fname);
prefix = fname(3:end-4);
load(strcat(file_folder,fname));
h_avg_amp = amplitude(sample_csiM(:,:,:,1:sample_len));
M_test(i,:) = mean(h_avg_amp,1);
end
M_test_file =  char(strcat(mat_folder,'M_test',prefix , '.mat' ));
save(M_test_file, 'M_test');


