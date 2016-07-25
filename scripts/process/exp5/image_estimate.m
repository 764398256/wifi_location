function est_img = image_estimate(voxel_num, y, W)
[~, sample_len] = size(y);
est_img = zeros(voxel_num, sample_len);
for i = 1: sample_len
    tmp = W* y(:, i);
    est_img(:,i) = tmp;
    %est_img(:, i) = (tmp - min(tmp))/(max(tmp) - min(tmp));
end
end
