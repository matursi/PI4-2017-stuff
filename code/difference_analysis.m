
function [r,az,el,x,y,z,full_vector_set]= difference_analysis(obj,datafolder)
% Creates figures that show the projections of difference vectors onto the
% dominant eigenvectors of the lead matrices.  Also takes projections of
% difference vectors onto the dominant difference eigenvectors.
% INPUT:
%          obj:     Leadinfo object for projection
%   datafolder:     the folder where you want your data to be saved
% OUTPUT:
%         r,az,el:     ploar coordinates for projection to 3-D vector space
%         x,y,z  :     cartesian coordinates for the above,
% full_vector_set:     the set of vectors
% FIGURES:
%       - files of eigenvectors for each set of vector differences
%       - files showing the projections of differences onto the covariance
%       space


session = obj.sessions;     %number of sessions (1 or 2)
run = obj.runs;             %number of runs (1 0r 2)
vlen = obj.runspersubject;  %number of runs per subect (1 or 2 or 4)


% remove latek interpreter to enable filenames in titles
set(0,'DefaultTextInterpreter','none');



map = [zeros(1,50), linspace(0,1,50); 
    zeros(1,100);linspace(1,0,50),zeros(1,50)]';

% lists subjects in NH and Tin categories

M=dir('Figures');

list_of_files = {M.name}';

%creates folders to put in data, 

if ~ismember(datafolder,list_of_files)
    str = input('datafolder does not exist.  Do you want to create new file? Y/N [Y]: ','s');
    if strcmp('Y',str)
        mkdir('Figures',datafolder)
    else
        'exiting program... '
        return;
    end
end

% checks how many "differences" will be generated from the input data.  If
% both inputs were '*', the relevant lead matrix vectors are s1r1,s1r2,s2r1,s2r2.
% Otherwise it's only two lead matrix vectors
if vlen == 1
    error('need either both runs or both sessions for difference analysis')
end

%Set up vectors according tu subject group (to enable easy subtraction)

full_vector_set= obj.vectors;


%Checking computability conditions for  collection of lead matrices
%m=max(abs(full_vector_set(:)));

% isolates the three eigenvectors, makes them correspond to x,y,z axes of
% euclidean plane
x=obj.coveigvects(:,1);
y=obj.coveigvects(:,2);
z=obj.coveigvects(:,3);

%w=obj.coveigvects(:,4:end);

%graphically displays the eigenvectors with colormap images
figure('Position',[100,100,1400,400])


subplot(1,3,1)
vectorImage(x,length(obj.ROIs),map,-1);
subplot(1,3,2)
vectorImage(y,length(obj.ROIs),map,-1);
% title placed here in the center image
title({['Eigenvectors for session ' session ' run ' run]; datafolder}) 
subplot(1,3,3)
vectorImage(z,length(obj.ROIs),map,-1);
savefig(['Figures/' datafolder '/eigenvectors_session_' session '_run_' run])
close

% gives indices of filenames that correspond to ctr or tin subjects
ctrind = find(strcmp('ctr',cellstr(obj.filenames(:,9:11)) ));
tinind = find(strcmp('tin',cellstr(obj.filenames(:,9:11)) ));

% gives # of indices for each subject types
clen = length(ctrind)
tlen = length(tinind)


if vlen == 4  % If the number of subject runs is 4

    % set current projective space for difference eigenvectors to the
    % covariance space
obj.setcoordspace({obj.coveigvects, obj.coveigvects},{'session','run'});

Difs = {};
RealDifs = [];

size(obj.sesdifs)
%Subtracting differences between runs
RealDifs{1}=obj.sesdifs(ctrind(1:clen/4),:);        %Ctr session differences for session 1
RealDifs{2}=obj.sesdifs(tinind(1:tlen/4),:);        %Tin session differences for session 1
RealDifs{3}=obj.sesdifs(ctrind(clen/4+1:clen/2),:); %Ctr session differences for session 2
RealDifs{4}=obj.sesdifs(tinind(tlen/4+1:tlen/2),:); %Tin session differences for session 2

size(RealDifs{1})

%Subtracting differences between sessions
RealDifs{5}=obj.rundifs(ctrind(1:clen/4),:);
RealDifs{7}=obj.rundifs(ctrind(clen/4+1:clen/2),:);
RealDifs{6}=obj.rundifs(tinind(1:tlen/4),:);
RealDifs{8}=obj.rundifs(tinind(tlen/4+1:tlen/2),:);

Difs{1}=obj.sesdifcurrentprojcoords(:,ctrind(1:clen/4));
Difs{3}=obj.sesdifcurrentprojcoords(:,ctrind(clen/4+1:clen/2));
Difs{2}=obj.sesdifcurrentprojcoords(:,tinind(1:tlen/4));
Difs{4}=obj.sesdifcurrentprojcoords(:,tinind(tlen/4+1:tlen/2));


% Difference between sessions for each run
Difs{5}=obj.rundifcurrentprojcoords(:,ctrind(1:clen/4));
Difs{6}=obj.rundifcurrentprojcoords(:,tinind(1:tlen/4));
Difs{7}=obj.rundifcurrentprojcoords(:,ctrind(clen/4+1:clen/2));
Difs{8}=obj.rundifcurrentprojcoords(:,tinind(tlen/4+1:tlen/2));

%titles to be used in figure files
savetit = {'Session_1','Session_2','Run_1','Run_2'};

% Create and save colormaps of average differences for each session / run/ subject
% group

size(sum(RealDifs{2}))
for i = 1:4
    vectorImage(sum(RealDifs{2*i-1})',length(obj.ROIs),map,-1);
    title({['NH Lead Difference ' savetit{i}]; datafolder},'Interpreter','none');
    savefig(['Figures/' datafolder '/NH_Lead_difference_' savetit{i}])
    vectorImage(sum(RealDifs{2*i})',length(obj.ROIs),map,-1);
    title(['Tin Lead Difference ' savetit{i}],'Interpreter','none')
    savefig(['Figures/' datafolder '/Tin_Lead_difference_' savetit{i}])
end

close
%Create a scatterplot with projections of differences within sessions
figure('Position',[100 100 900 400])
hold on
ax1=subplot(1,2,1)
hold on
x={};
y={};
z={};
%Get x,y,z coordinates of projection onto subspace
for i = 1:4
    x{i} = Difs{i}(1,:);
    y{i} = Difs{i}(2,:);
    z{i} = Difs{i}(3,:);
    scatter3(x{i},y{i},z{i},'filled')
  
end
  %  scatter3(Acoords(1,:),Acoords(2,:),Acoords(3,:),'filled')
  %  scatter3(Bcoords(1,:),Bcoords(2,:),Bcoords(3,:),'filled')
legend({'NH: Ses 1', 'Tin: Ses 1','NH: Ses 2','Tin: Ses 2'},'location','best')  
xlabel('eigvect 1');
ylabel('eigvect 2');
%zlabel('eigvect 3');

r={};
az={};
el={};
subplot(1,2,2)
hold 
% Get Spherical coordinates for projections
for i = 1:4
[az{i},el{i},r{i}] =cart2sph(x{i},y{i},z{i});
    scatter3(r{i},az{i},el{i},'filled')
    
    
end  

% finds subject outliers in the data, and attaches labels to them.  I used
% this to look at the subjects that were causing major distortion in data,
% and to remove outliers for other figures.
c = [x{1}, x{3}, x{2}, x{4}; 
     y{1}, y{3}, y{2}, y{4};
     z{1}, z{3}, z{2}, z{4}];
 
outliers = isoutlier([r{1},r{3},r{2},r{4}]);

outliers = find(outliers)

labels = [repmat(obj.subjects(ctrind(1:clen/4)),2,1); 
          repmat(obj.subjects(tinind(1:tlen/4)),2,1)];
      
labels(outliers)

text(ax1,c(1,outliers),c(2,outliers), c(3,outliers), labels(outliers),...
    'VerticalAlignment','bottom','HorizontalAlignment','right');

%set up axis labels for polar coordinate scatterplot
xlabel('radius');
ylabel('azimuth');
%zlabel('elevation');
suptitle({'Projections of differences of runs for sessions'; datafolder})
savefig(['Figures/' datafolder '/difference_Session_All'])
hold off

close
%
% Create and save scatterplot of differences within runs
figure('Position', [100,100,900,400])

ax2 = subplot(1,2,1)
hold on
for i = 5:8
    x{i} = Difs{i}(1,:);
    y{i} = Difs{i}(2,:);
    z{i} = Difs{i}(3,:);
    scatter3(x{i},y{i},z{i},'filled')
end
   % scatter3(Acoords(1,:),Acoords(2,:),Acoords(3,:),'filled')
   % scatter3(Bcoords(1,:),Bcoords(2,:),Bcoords(3,:),'filled')
legend({'NH: Run 1','Tin:Run 1','NH: Run 2','Tin: Run 2'},'location','best')  
xlabel('eigvect 1');
ylabel('eigvect 2');
zlabel('eigvect 3');

subplot(1,2,2)
hold on

%Again, get polar/spherical coordinates
for i = 5:8
[az{i},el{i},r{i}] =cart2sph(x{i},y{i},z{i});
    scatter3(r{i},az{i},el{i},'filled')

end 
%Again, get outliers and label them
d = [x{5}, x{7}, x{6}, x{8}; 
     y{5}, y{7}, y{6}, y{8};
     z{5}, z{7}, z{6}, z{8}];

 size(d) 
 
outliers = isoutlier([r{5},r{7},r{6},r{8}]);

outliers = find(outliers);

%Again, label axes for polar/spherical coordinates
text(ax2, d(1,outliers),d(2,outliers), d(3,outliers), labels(outliers),...
    'VerticalAlignment','bottom','HorizontalAlignment','right');

xlabel('radius');
ylabel('azimuth');
zlabel('elevation');

suptitle({'Projections of differences of sessions for runs'; datafolder})

savefig(['Figures/' datafolder '/difference_Run_All'])
close

    
end

%If number of runs per subject is 2 instead of 4, we can't do all the
%above, so we have to figure out if there is a session difference vs if
%there is a run difference, and then save only one difference type set of
%figures.

if vlen == 2
    
    %If both sessions were used, but only one run used, you have a run
    %difference
    if strcmp(session,'*') == 1
        
        obj.setcoordspace({obj.coveigvects},{'run'})
        savepart = ['Run_' run]; %This is for the title and filename of figure to be saved
        RealDifA=obj.rundifs(ctrind(1:length(ctrind)/2),:);
        RealDifB=obj.rundifs(tinind(1:length(tinind)/2),:);
        DifA=obj.rundifcurrentprojcoords(:,ctrind(1:length(ctrind)/2));
        DifB=obj.rundifcurrentprojcoords(:,tinind(1:length(tinind)/2));
    else
    % otherwise, you have a session difference.   
        obj.setcoordspace({obj.coveigvects},{'session'})
        savepart = ['Session_' session];
        RealDifA=obj.sesdifs(ctrind(1:length(ctrind)/2),:);
        RealDifB=obj.sesdifs(tinind(1:length(tinind)/2),:);
        DifA=obj.sesdifcurrentprojcoords(:,ctrind(1:length(ctrind)/2));
        DifB=obj.sesdifcurrentprojcoords(:,tinind(1:length(tinind)/2));
    end 
    
    

% creates figures and saves them.
vectorImage(sum(RealDifA)',length(obj.ROIs), map, -1);
title(['NH Lead difference only ' savepart],'Interpreter','none')
savefig(['Figures/' datafolder '/NH_Lead_difference_Only_' savepart])
close

vectorImage(sum(RealDifB)',length(obj.ROIs), map, -1);
title(['Tin Lead difference only ' savepart],'Interpreter','none')
savefig(['Figures/' datafolder '/Tin_Lead_difference_Only_' savepart])
close


%Do the same as in vlen = 4
az={};
el={};
x={DifA(1,:),DifB(1,:)};
y={DifA(2,:),DifB(2,:)};
z={DifA(3,:),DifB(3,:)};

figure('Position',[100 100 900 400]);
hold on;



ax1=subplot(1,2,1)
hold on
scatter3(DifA(1,:),DifA(2,:),DifA(3,:),'filled')
scatter3(DifB(1,:),DifB(2,:),DifB(3,:),'filled')
legend({'Normal Hearing','Tinnitus'},'location','best');
xlabel('eigvect 1');
ylabel('eigvect 2');
zlabel('eigvect 3');

[az{1},el{1},r{1}] = cart2sph(DifA(1,:),DifA(2,:),DifA(3,:));
[az{2},el{2},r{2}] = cart2sph(DifB(1,:),DifB(2,:),DifB(3,:));

subplot(1,2,2)
hold on
scatter3(r{1},az{1},el{1},'filled')
scatter3(r{2},az{2},el{2},'filled')
xlabel('radius');
ylabel('azimuth');
zlabel('elevation');

suptitle({['Projections of Differences: ' savepart]; datafolder})

c = [x{1}, x{2}; 
     y{1}, y{2};
     z{1}, z{2}];

 size(c) 
 
outliers = isoutlier([r{1},r{2}]);

outliers = find(outliers);


labels = [obj.subjects(ctrind(1:clen/2)); 
          obj.subjects(tinind(1:tlen/2))];

text(ax1, c(1,outliers),c(2,outliers), c(3,outliers), labels(outliers),...
    'VerticalAlignment','bottom','HorizontalAlignment','right');


savefig(['Figures/' datafolder '/difference_' savepart])
close
end

end