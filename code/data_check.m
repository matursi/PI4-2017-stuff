function [r,az,el,x,y,z,vects] = data_check()


opts = {['*','*'],['1','*'],['2','*'],['*','1'],['*','2']}
opts_labels = {'all: NH session 1','all: NH session 2', ...
                'all: Tin session 1','all: Tin session 2' ...
                'all:run 1','all: run 2',...
                'NH session 1','NH session 2',...
                'Tin session 1', 'Tin session 2', 'NH run 1','NH run 2',...
                'Tin run 1','Tin run 2'};

r={};
az={};
el={};
x={};
y={};
z={};
vects={};
for i=1:5
    args = opts{i};
    [r{i},az{i},el{i},x{i},y{i},z{i},vects{i}] = difference_analysis(args(1),args(2));
end


end 

% Rest of code

