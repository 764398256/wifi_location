% compare different send/receive location
close all; 
clear all;
data_path='../../data/exp4/';
file_folder=strcat(data_path,'mat/');
figure_folder=strcat(data_path, 'figure/');
mat_folder=strcat(data_path,'mat/');

% extract main features
empty_file=strcat(file_folder,'csi_empty.mat');
files=dir(strcat(file_folder,'csi_*_*.mat'));
subcarrier_num = 30;
M = 9; N = 6;
voxel_num = M*N;
Tx = [0,0];
Rx = [3.4,5];
b = 0.5;
grid_inv = 0.5;
dl = norm(Tx - Rx);
a = 2*b/dl; 
area = pi*a*b;
W = zeros(1, voxel_num);
Cx = zeros(voxel_num, voxel_num);
sigmac = 4;
sigmax = 0.4;
sigman = 10;
for x = 1: N
    for y = 1: M
        p = [x*grid_inv, y*grid_inv];
        dt = norm(p - Tx);
        dr = norm(p - Rx);
        dl = norm(Tx - Rx);
        rem = dt + dr  - 2* a;
        if rem < 0
            W(:, (x-1)*M + y ) = 1/area;
        else
            W(:, (x-1)*M + y ) = 1/area* exp(- (dt+dr - 2*a)) ;
        end
    end
end

%convariance matrix
for x = 1:N*M
    for y = 1:N*M 
        
       px = [ 1 + mod(x + N-1, N) + N , 1 + floor(x/N)  ] * grid_inv;
       py = [ 1 + mod(y + N-1, N) + N , 1 + floor(y/N)  ] * grid_inv;
       Cx(x,y) = sigmax* exp(-norm(px - py) /sigmac);
    end
end
W_ext = ones(subcarrier_num,1)*W;
W_eq = inv((transpose(W_ext)*W_ext + inv(Cx)*sigman))*transpose(W_ext);
% load csi emptyroom, 
load(empty_file);
sample_csiM_empty = sample_csiM;
est_img_empty = process_csi(voxel_num, sample_csiM_empty, W_eq);
img_diff = diff(est_img_empty')';
%add threshold
threshold = exp(-10);
new_img_diff = img_diff;
new_img_diff(img_diff < threshold) = 0;
figure;
%load csi standingman
for i = 1:4
    f_name = files(i).name;
    f_nonext=f_name(1:end-4);
    load(strcat(mat_folder,f_name));
    sample_csiM_one = sample_csiM;
    est_img_one = process_csi(voxel_num,sample_csiM, W_eq);
    img_diff = mean(est_img_one,2) - mean(est_img_empty,2);
    new_img_diff = uint8((img_diff-min(img_diff))/(max(img_diff)-min(img_diff))*255);
    show_image = reshape(new_img_diff, M, N);
    %imshow(show_image);
    subplot(2, 2 ,i);
    imshow(show_image, 'InitialMagnification', 'fit');
    set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
    %imwrite(show_image, strcat('image/',f_nonext, '.bmp'));
end