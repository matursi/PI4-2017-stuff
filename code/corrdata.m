function [cor,line] = corrdata(handle1, handle2)
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


for j = 1:2
    for i = 1:2
        xdata{i,j} = st{i}(j).XData;
        ydata{i,j} = st{i}(j).YData;
        cor{i+1,j+1} = corr(xdata{i,j}',ydata{i,j}');
        line(i,2*j-1:2*j) = polyfit(xdata{i,j},ydata{i,j},1);
    end
    cor{4,j+1} = length(xdata{1,j});


end

save(['Figures/' handle1.Title.String{2} '/cordata.mat'], 'cor','line')

end