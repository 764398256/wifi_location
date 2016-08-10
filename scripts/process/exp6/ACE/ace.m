close all; 
clear all;
data_path='../../../data/exp6/';
file_folder=strcat(data_path,'mat/');
figure_folder=strcat(data_path, 'figure/');
mat_folder=strcat(data_path,'mat/');

% extract main features
empty_file=dir(strcat(file_folder,'m*_empty.mat'));

stand_file=dir(strcat(file_folder,'m*.mat'));
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
sample_len = 200;
stream_num = 3;
subcarrier_num = 30;
M = zeros(voxel_num,stream_num, subcarrier_num,  sample_len*2);
% 
% for i= 1:numel(stand_file)
%     fname = stand_file(i).name;
%     disp(fname);
%     tag = str2double(regexpi(fname, '[\d+]*', 'match'));
%     load(strcat(file_folder,fname));
%     voxel_id = find(ismember(index, [tag(2), tag(3)], 'rows'));
%     h_avg_amp = amplitude(sample_csiM(:,:,:,1:sample_len));
%     static = length(strfind(fname, 'static'));
%     M( voxel_id, tag(1), :, ( static )* sample_len + 1: (static + 1) *sample_len ) = h_avg_amp;
% end
% M = mean(M, 3);
% histo = fingerprint_builder(M); 
% histo_file = char(strcat(mat_folder,'histo.mat' ));
% save(histo_file, 'histo');

%generate edge_pairs
qSize = 300;
eSize  = 100;
head = 1;
nextLoc = 2;
ehead = 1;
edge_pairs = cell(1, eSize);
Q = cell(1, qSize);
Q{head} = [1,1];
visited = zeros(size(map));
d = {[-1, 0], [1,0], [0, 1], [0, -1]};
while head < nextLoc
    q= Q{head};
    head = head + 1;
    voxel_id_st =  -1;
    if  map(q(1), q(2)) == 1
        voxel_id_st = find(ismember(index, [q(1), q(2)], 'rows'));
    end
    visited(q(1), q(2)) = 1;    
    for i =1: numel(d)
        delta = d{i};
        new_pos = [ delta(1) + q(1),  delta(2) + q(2) ];
        if new_pos(1) < 1 ||  new_pos(1) > row || new_pos(2) < 1 || new_pos(2) > col || visited(new_pos(1), new_pos(2)) == 1
            continue 
        else
            if visited(new_pos(1), new_pos(2)) == 0
                Q{nextLoc} = new_pos;
                nextLoc = nextLoc + 1;
                visited(new_pos(1), new_pos(2)) = -1;
            end
            if voxel_id_st > 0 && map(new_pos(1), new_pos(2)) == 1 && ehead <= eSize
                voxel_id_ed = find(ismember(index,[new_pos(1), new_pos(2)] , 'rows'));
                edge_pairs{ehead} = [voxel_id_st, voxel_id_ed ];
                ehead = ehead + 1;
            end
        end
    end
end
all_edges = {edge_pairs{1:ehead-1}};
edge_file = char(strcat(mat_folder,'edges.mat' ));
save(edge_file, 'all_edges');
