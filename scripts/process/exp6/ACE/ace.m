close all; 
clear all;
data_path='../../../data/exp5/';
file_folder=strcat(data_path,'mat/');
figure_folder=strcat(data_path, 'figure/');
mat_folder=strcat(data_path,'mat/');

% extract main features
empty_file=dir(strcat(file_folder,'m*_empty.mat'));
static_file=dir(strcat(file_folder,'m*one_stand_left_mid.mat'));
