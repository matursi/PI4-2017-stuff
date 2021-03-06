function angle_analysis(obj, analtype,datafolder)
% This function does two different things: a regular analysis, and a
% difference analysis. The regular analysis turned out not to be used so
% much, but it generates a figure of the angle differences between lead
% matrices of subject groups.  this was to see if subjects within a group
% were spread out or if they were more clustered. 
%
% The difference angle analysis takes angle differences between opposite
% runs of the same section for subjects, or opposite sessions for the same
% run for the same subject.  This is a different way of taking a
% "difference" between two lead matrices.  I ended up using this function
% far more than the 'regular' analogue. 
%
% INPUTS: 
% obj:              a leadinfo object
% analtype:         type 'difference' or 'regular': determines what kind of
%                   analysis you want
% datafolder:       name of folder to put in your data
% FIGURES:
% if 'regular is chosen, produces and saves a figure called
% 'sessioni_runj_angles', which gives a graphic representation of
% angle differences between subjects over session i and run j (as listed in
% obj). 
% If difference is chosen, gives a figure with two scatter plots containing
% angle run differences and angle session differences.


% These are colormap designations for 'map' a colormap
red=[linspace(1,0,50),zeros(1,50)]';
green = [zeros(1,50), linspace(0,1,50)]';
blue = zeros(100,1);

map = [red,green,blue];

%runs per subject, can't be 1
clen = obj.runspersubject;

% creates new folder in Figures named datafolder if it has not been created
list_of_files = dir('Figures');
list_of_files = {list_of_files.name}';

if ~ismember(datafolder,list_of_files)
str = input('datafolder does not exist.  Do you want to create new file? Y/N [Y]: ','s');
    if strcmp('Y',str)
        mkdir('Figures',datafolder)
    else
        output('exiting program...')
        return;
     end
end


% initiate regular analysis if regular option was chosen
if strcmp(analtype,'regular')

    
    vectors = obj.vectors;
    session = ['1','2']
    run = ['1','2']
    
%creates and saves image in blocks of ctr/tin vs ctr/tin.  Resulting figure is
%symmetric.
    for i=session
        for j = run
            ctrind = find(strcmp(cellstr(obj.filenames(:,[1:2 4:7 9:11])),['s' i 'run' j 'ctr']));
            tinind = find(strcmp(cellstr(obj.filenames(:,[1:2 4:7 9:11])),['s' i 'run' j 'tin']));
            
            a=angle_anal(vectors(ctrind,:),vectors(tinind,:),length(ctrind),length(tinind),map);
            title(['Session ' i ' Run ' j ' angle differences'])
           
            savefig(['Figures/' datafolder '/session' i '_run' j '_angles']);
        end
    end
    
% initiate angle difference analysis if difference was chosen
elseif strcmp(analtype,'difference')
    

    diffsettings = {'**','1*','2*','*1','*2'};
    vectornums = {[1 2 3 4], [1 2], [1 2], [1 2]};
    full_vector_set = obj.vectors;
 
        
% sirj consists of the lead vectors of subjects corresponding to session i and run j    
s1r1 = full_vector_set(find(strcmp(cellstr(obj.filenames(:,[1 2 4:7])),'s1run1')),:);
s1r2 = full_vector_set(find(strcmp(cellstr(obj.filenames(:,[1 2 4:7])),'s1run2')),:);
s2r1 = full_vector_set(find(strcmp(cellstr(obj.filenames(:,[1 2 4:7])),'s2run1')),:);
s2r2 = full_vector_set(find(strcmp(cellstr(obj.filenames(:,[1 2 4:7])),'s2run2')),:);

size(s1r1(:,:))
size(s1r2(:,1)')

% xi, yi will be coordinates in one of the scatter subplots of the figure
% to be generated
x1=[];
y1=[];
x2=[];
y2=[];

% ctrind, tinind, are the indices of filenames corresponding to control,
% tinnitus patients respectively
ctrind = find(strcmp(cellstr(obj.filenames(:,[1:2 4:7 9:11])),'s1run1ctr'));
tinind = find(strcmp(cellstr(obj.filenames(:,[1:2 4:7 9:11])),'s1run1tin'));

%throws in coordinates: x coordinate is run/session 1 angle difference, y
%coordinate is run/session 2 difference.
for i=1:length(obj.subjects)
    x1(i) = acos(s1r1(i,:)*(s1r2(i,:)')/( norm(s1r1(i,:))*norm(s1r2(i,:)) ));
    y1(i) = acos(s2r1(i,:)*(s2r2(i,:)')/( norm(s2r1(i,:))*norm(s2r2(i,:)) ));
    x2(i) = acos(s1r1(i,:)*(s2r1(i,:)')/( norm(s1r1(i,:))*norm(s2r1(i,:)) ));
    y2(i) = acos(s1r2(i,:)*(s2r2(i,:)')/( norm(s1r2(i,:))*norm(s2r2(i,:)) ));

    
    
end

% create a figure with two subplots: the left one will involve session
% differences, the right one will involve run differences

% stuff for creating subplot 1
figure('Position',[100,100, 1000,400])
ax1 = subplot(1,2,1)
hold on
scatter(x1(ctrind),y1(ctrind), 'filled');
scatter(x1(tinind),y1(tinind),40, 'd');
legend({'NH','Tin'},'Location','Northwest')
title({'Ses1 vs. Ses2';datafolder})
hold off

% labels for points in subplot 1 and 2, according to subject number
labels = [obj.subjects(ctrind); 
          obj.subjects(tinind)]
      
c = [x1(ctrind),x1(tinind);y1(ctrind),y1(tinind)];

[x1(tinind);y1(tinind)]

text(ax1,c(1,:),c(2,:), labels,...
    'VerticalAlignment','bottom','HorizontalAlignment','right');

% build up subplot 2, for run differences
ax2 = subplot(1,2,2)
hold on
scatter(x2(ctrind),y2(ctrind), 'filled');
scatter(x2(tinind),y2(tinind),40, 'd');
title({'Run1 vs Run2'; datafolder})

c = [x2(ctrind),x2(tinind);y2(ctrind),y2(tinind)];

text(ax2,c(1,:),c(2,:), labels,...
    'VerticalAlignment','bottom','HorizontalAlignment','right');
hold off

% save the figure
savefig(['Figures/' datafolder '/angle_comparisons'])

f=figure

%This other figure presents the angles as they would appear on the unit
%circle.  So if you have theta = v11'*v12, for some subject, (x,y) would be
% (cos(theta), sin(theta))

subplot(2,2,1)
hold on
scatter(cos(x1(ctrind)),sin(x1(ctrind)), 'filled');
scatter(cos(x1(tinind)),sin(x1(tinind)),40', 'd');
xlim([-1,1])
ylim([0.3,1.2])
title('Session 1')
legend({'NH','Tin'},'Location','Northwest')
hold off

subplot(2,2,2)
hold on
scatter(cos(x2(ctrind)),sin(x2(ctrind)), 'filled');
scatter(cos(x2(tinind)),sin(x2(tinind)),40, 'd');
xlim([-1,1])
ylim([0.3,1.2])
title('Run 1')
hold off

subplot(2,2,3)
hold on
scatter(cos(y1(ctrind)),sin(y1(ctrind)), 'filled');
scatter(cos(y1(tinind)),sin(y1(tinind)),40, 'd');
xlim([-1,1])
ylim([0.3,1.2])
title('Session 2')
hold off

subplot(2,2,4)
hold on
scatter(cos(y2(ctrind)),sin(y2(ctrind)), 'filled');
scatter(cos(y2(tinind)),sin(y2(tinind)),40,'d');
xlim([-1,1])
ylim([0.3,1.2])
title('Run 2')
hold off

savefig(f,['Figures/' datafolder '/angle_differences_for_sessions_and_runs']);

end

end

function a= angle_anal(vects1,vects2,lengthvar1,lengthvar2,map)
% This function gives the actual image for the angle differences
%INPUTS:
% vects1,vects2:            sets of vectors of the same length
% lengthvar1, lengthvar2:   number of vectors in vects1, vects2
% map:                      colormap for the image to be created
% OUTPUTS:
% a:      graphical image for angle differences,  ctr subjects are on the
%         left and the top, tin subjects are on the right and bottom.


% creates angle differences
A=[vects1; ones(1,size(vects1,2)); vects2];
B=A*A';

% adds one for image, to show a clear line separating tinnitus from normal
% hearing subjects.
r= ones(lengthvar1+lengthvar2+1,1);

% If normalized, r(i) is just 1, but this is done in case it's an issue
for i=1:lengthvar1
    r(i) = norm(vects1(i,:));
end

% adds 1 in between, to allow for lines of separation
for i = 1:lengthvar2
    r(i+1+lengthvar1) = norm(vects2(i,:));
end
length(r)

% gets the product of norms for lead vectors of subject pairs, but also
% creates lines of separation.
C = r*r';
C(lengthvar1+1,:)=1;
C(:,lengthvar1+1) = 1;
B(lengthvar1+1,:)=-1;
B(:,lengthvar1+1) = -1;

size(B)
size(C)

% gets angle using dot product formula, and taking the arc-cosine
angles = B./C;

angles=real(acos(angles));
%angles(1:30,1:30);

%generates image
a=image(angles,'CDataMapping', 'scaled');
colormap(map)
colorbar
end

