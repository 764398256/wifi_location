function [ Filter ] = gaussFilter( input_args )

sigma = 5;
size = 30;
x = linspace(-size / 2, size / 2, size);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
Filter = gaussFilter / sum (gaussFilter); % normalize

end

