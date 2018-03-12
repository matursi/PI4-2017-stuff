
function B=bar_graph(r)
% This is called bar_graph, but it also makes some box and whiskers
% plots, since I thought those gave a better sense of the distribution of
% data than mere bar-graphs.  These give the radii of non-normed lead
% matrices projections distributed over subject, session and run choice.  
% INPUT: r: a length 5 cell, r{1} gives all the radii for each subject,
% collected from some other data I had before

ave_r = [];
std_r = [];

allr=r{1}
%calculates median and range of radii according to each session, type,
%subject.  r{1} has data when all catagories are used.  r{2}-r{5} is
%limited to choice of section/run or section/run differences.
for i = 2:5
    s=r{i};
    avs=[];
    stds=[];
    for j=1:2
        avs(2*j-1) = median(allr{2*i-4+j});
        avs(2*j) = median(s{j});
        stds(2*j-1) = range(allr{2*i-4+j});
        stds(2*j) = range(s{j});
    end
    ave_r = [ave_r;avs];
    std_r = [std_r; stds];
end

% creates bar graphs comparing medians and stds for each type-session-run,
% also depending on whether projection space was formed by all points, or
% just points specific to group (hence legend saying part i vs all part i)
figure()
y=categorical({'NH ses','Tin ses','NH run','Tin run'});
bar(ave_r)
set(gca,'XTickLabel',{'NH ses','Tin ses','NH run','Tin run'})
legend({'all part 1','part 1','all part 2','part 2'});
title('Median values of ratios')

figure()
y=categorical({'NH ses','Tin ses','NH run','Tin run'});
bar(std_r)
set(gca,'XTickLabel',{'NH ses','Tin ses','NH run','Tin run'});
legend({'all part 1','part 1','all part 2','part 2'});
title('std for ratios')

% creates boxplot of radial distributions, dependent on whether projection
% was over all data, or just internal data.
figure()
boxr=[r{2}{1},r{2}{2},r{3}{1}, r{3}{2},r{4}{1},r{4}{2},r{5}{1},r{5}{2}]';
boxlabels = [repmat('NHses1',12,1);repmat('TIses1',23,1);
            repmat('NHses2',12,1);repmat('TIses2',23,1);
            repmat('NHrun1',12,1);repmat('TIrun1',23,1);
            repmat('NHrun2',12,1);repmat('TIrun2',23,1)];
boxplot(boxr,boxlabels)
title('Plots for Session and Run differences')

figure()
boxr=[r{1}{1},r{1}{3},r{1}{2}, r{1}{4},r{1}{5},r{1}{7},r{1}{6},r{1}{8}]';
boxplot(boxr,boxlabels)
title('Plots for differences over all trials')
end