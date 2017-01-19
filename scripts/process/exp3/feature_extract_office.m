% compare different send/receive location
close all; clear all;
data_path='../../data/exp6/';
file_folder=strcat(data_path,'mat/');
figure_folder=strcat(data_path, 'figure/');
mat_folder=strcat(data_path,'mat/');

% extract main features
files=dir(strcat(file_folder,'m*_fg_s*.mat'));
subcarrier_num = 30;
stream_num = 3;
feature_dim = (subcarrier_num-1)*2;
labels = zeros(2,numel(files));
train_sample=2000;
test_sample=1000;
features_train = zeros(feature_dim,numel(files));
corr_train = zeros(feature_dim,feature_dim,numel(files));
features_test = zeros(feature_dim,numel(files));
for i=1:numel(files)
    fname= char(files(i).name);
    load(strcat(file_folder, fname ) );
    tag = str2double(regexpi(fname, '[\d+]*', 'match'));
    labels(:,i) = str2num(char(tag(2:3)));
    sample_size = size(sample_csiM);
    h_avg = squeeze(mean(sample_csiM,1));
    h_avg = squeeze(mean(h_avg,1));
    h_avg_amp = squeeze(abs(h_avg));
    h_avg_ph = squeeze(angle(h_avg));
    % Generate train sample features
    h_amp_diff_train_detail = diff(h_avg_amp(:,1:train_sample));
    
    h_ph_diff_train_detail = diff(h_avg_ph(:,1:train_sample));
    features_train_detail = [h_amp_diff_train_detail; h_ph_diff_train_detail];
    features_train(:,i) = mean(features_train_detail,2);
    corr_train(:,:,i) = cov(features_train_detail.');
    % Generate test sample features
    h_amp_diff_test_detail = diff(...
        h_avg_amp(:,train_sample+1:train_sample+test_sample));
    h_ph_diff_test_detail = diff(...
        h_avg_ph(:,train_sample+1:train_sample+test_sample));
    features_test_detail = [h_amp_diff_test_detail; h_ph_diff_test_detail];
    features_test(:,i) = mean(features_test_detail,2); 
end
save(char(strcat(mat_folder,'features_train.mat')), 'features_train');
save(char(strcat(mat_folder,'features_test.mat')), 'features_test');
save(char(strcat(mat_folder,'corr_train.mat')), 'corr_train');
save(char(strcat(mat_folder,'labels.mat')), 'labels');
% files = [files{:}];

