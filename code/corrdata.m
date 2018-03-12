function [cor,line] = corrdata(handle1, handle2)
% Generates correlation data and lines of best fit for figures.  I wrote
% this after I had already made some figures, but I wanted to extract data
% from the points on the scatterplots (the figures were the
% 'angle_differences_for_sessions_and_runs' data)
% INPUTS:
% handle1:      Figure handle for tinnitus data
% handle2:      Figure handle for ctr data
% OUTPUTS:      
% cor:          a 4x3 cell with the following layout:
%           ''               'tin'                  'ctr'
%       'sessions'          corr(ses1,ses2) data    ...
%                           for tin subjects
%       'runs'              ...                     ...
%       'sample size'       number of tin subs      ...
% line:         a 2x4 array whose numbers contain the slope and intercept
%               for lines of best fit for the four combos of session 1 vs
%               session 2, run 1 vs run 2 for ctr and ti  Hence if your line of best fit
%               for tin/ctr vs ses/run were y = a_ij x +b_ij, the array is
%               in the form
%               [ a_11   b_11   a_12   b_12]
%               [ a_21   b_21   a_22   b_22]
%           

cor = {'', 'tin','ctr';'sessions', 0, 0;'runs    ', 0, 0; 'sample size', 0, 0};
line = zeros(2,4);
xdata= {0,0;0,0}
ydata= {0,0;0,0}
dt={};
st={};
dt{1} = get(handle1,'children');
st{1} = dt{1}(end-1:end);
dt{2} = get(handle2,'children');
st{2} = dt{2}(end-1:end);

%st has the actual coordinates of four types of points: session ctr
%points, session1 run2 points, session 2 run1 points, session 2 run2
%points.
   
for j = 1:2
    for i = 1:2
        xdata{i,j} = st{i}(j).XData;        % gets X and Y coordinates type i vs
                                            % session/run j.  the x,y
                                            % coordinates are correlated,
                                            % and then line is used to get
                                            % line of best fit coefficients
        ydata{i,j} = st{i}(j).YData;
        cor{i+1,j+1} = corr(xdata{i,j}',ydata{i,j}');  
        line(i,2*j-1:2*j) = polyfit(xdata{i,j},ydata{i,j},1);
    end
    cor{4,j+1} = length(xdata{1,j});


end

save(['Figures/' handle1.Title.String{2} '/cordata.mat'], 'cor','line')

end