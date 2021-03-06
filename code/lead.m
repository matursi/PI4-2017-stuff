function [ lm, lm_vals] = lead(data,norm_type)

% generates the lead matrix for inputed data up to scale, with rows and columns
% equal to the number of rows in the data matrix.  The result
% should be a skew symmetric matrix where the elements are 
% an approximation of lm_ij = \int f_j df_i - f_i.  

%INPUT:
%     data: an n x m matrix, where n is the number of chanels, series to be
%     used, etc. amd m is the length of the time series
%     norm_type: choose from 'fro','inf', or other acceptable matlab norm
%     specifications.  Type 'none' if you don't want your data to be
%     normalized

%OUTPUT:
%     lm_vals: is the unraveled vector representing the upper triangular
%     elements of the lead matrix (used for separability analyses
%     lm is the matrix itself (used for depictions of the lead elements)

[rgns, times] = size(data);



data = match_ends(data);
data = zero_mean(data);

%remove normalizing the matrix if you want to calculate covariance data,
%and separability
%put it back in for other things, like calculating the lead vector

if strcmp(norm_type,'none')==0
    data = data/norm(data,norm_type);
end

lm = zeros(rgns);
lm_vals = [];

for i = 1:rgns
    ri = data(i,:);%/norm(data(i,:),norm_type);
    dri = diff([data(i,end),ri]);
    for j = i+1:rgns
        rj = data(j,:);%/norm(data(j,:),norm_type);;
        drj = diff([data(j,end),rj]);
        lm(i,j) = rj*dri' - ri*drj';
        lm(j,i) = -lm(i,j);  
        lm_vals = [lm_vals, lm(i,j)];
    end 
end 

end

function m = match_ends(data)

% match the first and last columns of the matrix through a linear 
% adjustment.  This is to enable a cyclic "continuity" in the data
% in order to get the values of the lead matrix.

num_cols = size(data, 2);

m  = data - (data(:,1) - data(:,end))*linspace(0,1,num_cols);

end


function [Zm] = zero_mean(Z)
% Shifts vector(s) Z so that the mean is 0.

Zm = Z - repmat(mean(Z, 2),1,size(Z, 2));
end