function [angs, points] = mixed_angles(obj1, obj2, m,n, labs,leg,misssubs)

% Computes the angle difference between dominant eigenvectors of two
% leadinfo objects.  Use this with respect to two objects that differ in
% some way, for example control and Tinnitus groups or session 1 vs session
% 2. angles.m also generates five different figures which are projections
% of points of both eigenvector onto two eigenvectors, one from each
% object.  
% INPUT: 
%   obj1:       a leadinfo object.  
%   obj2:       another lead info object
%      m:       the number of dominant eigenvectors from each object that 
%               you want to compare
%      n:       the eigenvector from each object for projecting the points.
%               For example, If m = 10, and n = 3, then the figure would
%               consist of projections of lead and difference matrices onto
%               a cartesian plane with the x axis being the 3rd eigenvector
%               from obj1, and the y axis being the 3rd eigenvector of
%               obj2.
%   labs:       The labels to be used for the two axes.  For example, If
%               comparing obj1 = Ctr leadinfo object, and obj2 = Tin 
%               leadinfo object, then I would set labs to {'ctr
%               eigenvector', 'Tin eigenvector'}.  Format should be a cell
%               of strings.
%    leg:       The legend for the plots: ex: {'Ctr','Tin').  Format should
%               be a cell of strings.
% missubs:      A string describing missing objects or ROIs in your
%               leadinfo objects.  This will be in your title, so make your
%               string short!

% The function generates five scatter plots and three colormaps with the 
%following info: 
%       1) projections of points onto the nth lead eigenvector of each
%       object. 
%       2) projections of session difference points onto the nth lead 
%       eigenvector of each object
%       3) projections of run difference points onto the nth lead
%       eigenvector of each object.
%       4) projections of session difference points onto the nth session
%       difference eigenvector of each object
%       5) projections of run difference points onto the nth run difference
%       eigenvevtor
%
%       6) an mxm colormap graphically showing the angles of the first m
%       lead eigenvectors of the two objects.  the the ith row and jth column
%       represent the angle difference for the ith eigenvector of obj1 and
%       the jth eigenvector of obj2
%       7) an mxm colormap showing the angles for the first m session
%       difference eigenvectors
%       8) an mxm colormap showing the angles for the first m run
%       difference eigenvectors

% OUTPUT
%   angles:         a 3xm the dot product of the m corresponding 
%                   eigenvectors of obj1 and obj2 for lead, session 
%                   difference, and run difference matrices.
%   points:         an mxm array with the numerical data for figure 6. 

% Check that norms are the same
nm = obj1.leadnorm;
nm2 = obj2.leadnorm;

if ~strcmp(nm,nm2)
    error("leadinfo norms not the same!")
end

% builds up name of folder for data to be stored.
if ~isempty(misssubs)
datafolder = [misssubs '-norm-' nm];
else
    datafolder = ['norm-' nm];
end

M=dir('Figures');

list_of_files = {M.name}';

%creates folders to put in data, or chooses already existing foldres

if ~ismember(datafolder,list_of_files)
    str = input('datafolder does not exist.  Do you want to create new file? Y/N [Y]: ','s');
    if strcmp('Y',str)
        mkdir('Figures',datafolder)
    else
        print('exiting program...')
        return;
    end
end

% these are mth and nth eigenvector
m1 = [obj1.coveigvects(:,1:m), obj2.coveigvects(:,1:m)];
m2 = [obj1.sesdifcoveigvects(:,1:m), obj2.sesdifcoveigvects(:,1:m)];
m3 = [obj1.rundifcoveigvects(:,1:m), obj2.rundifcoveigvects(:,1:m)];

n1 = [obj1.coveigvects(:,n), obj2.coveigvects(:,n)];
n2 = [obj1.sesdifcoveigvects(:,n), obj2.sesdifcoveigvects(:,n)];
n3 = [obj1.rundifcoveigvects(:,n), obj2.rundifcoveigvects(:,n)];

%these are the same as above?
ang1 = ang(obj2.coveigvects(:,1:m), obj1.coveigvects(:,1:m));
ang2 = ang(obj1.sesdifcoveigvects(:,1:m), obj2.sesdifcoveigvects(:,1:m));
ang3 = ang(obj1.rundifcoveigvects(:,1:m), obj2.rundifcoveigvects(:,1:m));

angs = [ang1;ang2;ang3]

%change the coordinate space to the default covariance space
A1 = obj1.setcoordspace({m1 m2 m3},{'none', 'session', 'run'});
B1 = obj2.setcoordspace({m1 m2 m3},{'none', 'session', 'run'});

% A2: obj1 with new coordinate spaces for the lead matrices (here it's only
% one dimensional
% B2: same but with obj2
A2 = obj1.setcoordspace({n1 n2 n3},{'none', 'session', 'run'});
B2 = obj2.setcoordspace({n1 n2 n3},{'none', 'session', 'run'});

% Sets obj1, obj2 with default space.
A3 = obj1.setcoordspace({n1 n1},{'session', 'run'});
B3 = obj2.setcoordspace({n1 n1},{'session', 'run'});


a = A2.runspersubject;
b = B2.runspersubject;


% creation of the figures 1-5 listed above
figureplot(A2.currentprojcoords, B2.currentprojcoords,...
    A2.subjects, B2.subjects, a, b, ang1, n,...
    ['projections-to-eigenvector-' num2str(n)], leg,labs,datafolder);


figureplot(A2.sesdifcurrentprojcoords, B2.sesdifcurrentprojcoords,...
    A2.subjects, B2.subjects, a/2, b/2, ang2, n,...
    ['projections-to-session-difference-eigenvector-' num2str(n)], leg,labs,datafolder);


figureplot(A2.rundifcurrentprojcoords, B2.rundifcurrentprojcoords,...
    A2.subjects, B2.subjects, a/2, b/2, ang3, n,...
    ['projections-to-run-difference-eigenvector-' num2str(n)], leg,labs,datafolder);


figureplot(A3.sesdifcurrentprojcoords, B3.sesdifcurrentprojcoords,...
    A2.subjects, B2.subjects, a/2, b/2, ang1, n,...
    ['session-difference-projections-to-eigenvector-' num2str(n)], leg,labs,datafolder)


figureplot(A3.rundifcurrentprojcoords, B3.rundifcurrentprojcoords,...
    A2.subjects, B2.subjects, a/2, b/2, ang1, n,...
    ['run-difference-projection-to-eigenvector-' num2str(n)], leg,labs, datafolder)
 

% write textfile with angles, write file with ratios as well
% f=figure()
%angle_anal(m1(:,1:m),m1(:,m+1:end))

%f=figure()
%angle_anal(m2(:,1:m),m1(:,m+1:end))

%f=figure()
%angle_anal(m3(:,1:m),m1(:,m+1:end))


end


function [angle,angs] = ang(eigvs1,eigvs2)

angle = [];

s= size(eigvs1)

[size(eigvs1(:,1)'), size(eigvs2(:,1))]

for i = 1:s(2)
    angle(i) = eigvs1(:,i)'*eigvs2(:,i)/(norm(eigvs1(:,i))*norm(eigvs2(:,i)));
end

end

%fix this!!!
function [angs,a]= angle_anal(vects1,vects2)
map = [linspace(1,0,50), zeros(1,49); zeros(1,99); zeros(1,49), linspace(0,1,50)]';

lengthvar1 = size(vects1,2);
lengthvar2 = size(vects2,2);
A=[vects1,vects2];

B=vects1'*vects2;

r= ones(lengthvar1+lengthvar2,1);
for i=1:lengthvar1+lengthvar2
    r(i) = norm(A(:,i));
end


C = r(1:lengthvar1)*r(lengthvar1+1:end)';
length(r)

size(B)
size(C)

angs = B./C;

angs=real(acos(angs));
%angles(1:30,1:30);
a=image(angs,'CDataMapping', 'scaled');

colormap(map)
colorbar
end

function figureplot = figureplot(acoords, bcoords, anames, bnames,...
    a, b, angle, n, tit, leg,labs,ms)
%Coordinates to be plotted :acoords, bcoords
%labels of acoords, bcoords
% number of points for subjects a, b
% angle

 
f = figure();
hold on

polyfit(acoords(1,:),acoords(2,:),1)
polyfit(bcoords(1,:),bcoords(2,:),1)
scatter(acoords(1,:),acoords(2,:),'filled')
scatter(bcoords(1,:),bcoords(2,:),'filled')

if labs == 1
    
r = [];
c=[acoords,bcoords];
size(c,2)
    for i = 1:size(c,2)
        r(i) = norm(c(:,i));
    end
    outliers = isoutlier(r);
   
    outliers = find(outliers);
    
labels = [repmat(anames,a,1); repmat(bnames,b,1)];

text(c(1,outliers),c(2,outliers), labels(outliers),...
    'VerticalAlignment','bottom','HorizontalAlignment','right');

end


xlabel([leg{1} ' eigenvector']);

ylabel([leg{2} ' eigenvector']);


title({tit; ['angle = ' num2str(angle(n))]; ms  } );
legend(leg);

savefig(['Figures/' ms '/' tit])
close

end

