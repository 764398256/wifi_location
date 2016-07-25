% compare different send/receive location
close all; 
clear all;
data_path='../../data/exp5/';
file_folder=strcat(data_path,'mat/');
figure_folder=strcat(data_path, 'figure/');
mat_folder=strcat(data_path,'mat/');

% extract main features
empty_file=dir(strcat(file_folder,'m*_empty.mat'));
static_file=dir(strcat(file_folder,'m*one_stand_left_mid.mat'));
subcarrier_num = 30;
M = 16; N = 12;
voxel_num = M*N;
Tx = [7,5];
Rx = [1,12;16,6;1,4];
[l,dim] = size(Rx);
b = 2;
grid_inv = 1;
feature_dim = subcarrier_num;
W = zeros(l*feature_dim, voxel_num);
Cx = zeros(voxel_num, voxel_num);
sigmac = 10;
sigmax = 0.4;
sigman = 10;
sigma_va = 10^(-10);
for k = 1:l
    for x = 1: M
        for y = 1: N
            p = [x*grid_inv, y*grid_inv];
            dt = norm(p - Tx);
            dr = norm(p - Rx(k,:));
            dl = norm(Tx - Rx(k,:));
            a = norm([b, dl/2]); 
            area = pi*a*b;
            rem = dt + dr  - 2* a;
            if rem < 0
                W((k-1)*feature_dim + 1: k*feature_dim, (x-1)*N + y ) = 1/area + sigma_va*rand(feature_dim,1);
            else
                W((k-1)*feature_dim + 1: k*feature_dim, (x-1)*N + y ) = 1/area* exp(- 10*(dt+dr - 2*a)) + sigma_va*rand(feature_dim,1);
            end
        end
    end
end

%convariance matrix
for x = 1:N*M
    for y = 1:N*M  
        px = [ 1 + mod(x + M-1, M) + M , 1 + floor(x/M)  ] * grid_inv;
        py = [ 1 + mod(y + M-1, M) + M , 1 + floor(y/M)  ] * grid_inv;
        Cx(x,y) = sigmax* exp(-norm(px - py) /sigmac);
    end
end
W_ext = W;
%ones(subcarrier_num,l)*W;
W_eq = inv((transpose(W_ext)*W_ext + inv(Cx)*sigman))*transpose(W_ext);
% load csi emptyroom,
sample_len = 200;
empty_amp = zeros(feature_dim*l, 1);
for k = 1: l
    load(strcat(file_folder, empty_file(k).name));
    empty_amp((k-1)*feature_dim+1: k*feature_dim) = feature_extract(sample_csiM(:,:,:,1:sample_len));
end
empty_img = image_estimate(voxel_num, empty_amp, W_eq);
% img_diff = diff(empty_img')';
% %add threshold
% threshold = 10^(-10);
% new_img_diff = img_diff;
% new_img_diff(img_diff < threshold) = 0;
figure;
%load csi standingman
slice = 5;
sample_len = 20;
amp = zeros(feature_dim*l, 1);
for i = 1: slice 
for k = 1:l
    f_name = static_file(k).name;
    f_nonext=f_name(1:end-4);
    load(strcat(mat_folder,f_name));
    sample_csiM_one = sample_csiM;
    amp((k-1)*feature_dim+1: k*feature_dim) = feature_extract(sample_csiM(:,:,:,(i-1)*sample_len + 1: i*sample_len));
end
est_img_one = image_estimate(voxel_num, amp , W_eq);
% for i=1: sample_len
% if mod(i,10) ~= 1
%     continue;
% end
%empty = mean(empty_img,2);
img_diff = abs(est_img_one - empty_img );
%img_diff = abs(mean(est_img_one,2) - mean(empty_img,2));
%img_diff = abs(est_img_one(:,i));
%img_diff = abs(mean(est_img_one,2));
new_img_diff = double_to_image(est_img_one);
show_image = reshape(new_img_diff, M, N);
show_image = imgaussfilt(show_image, 2);
%imshow(show_image);
imshow(show_image, 'InitialMagnification', 'fit');
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
disp(i)
pause(1);
end
%imwrite(show_image, strcat('image/',f_nonext, '.bmp'));
