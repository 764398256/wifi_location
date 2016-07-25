function img = double_to_image(M)
img = uint8((M-min(M))/(max(M)-min(M))*255);

end