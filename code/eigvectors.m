function domeigvectors(obj1,obj2,datafolder)
% generates a scatterplot of points which are projections of lead/
% difference vectors of obj1 and obj2 to their respective domain
% INPUTS: 
% obj1, obj2:       two leadinfo objects, should have different subject
%                   types, but the same sessions and runs
% datafolder:       the name of the folder where you want to put the
%                   figures.  The name should specify the norm, subject
%                   type, sessions and runs used, and subject/roi outliers
% FIGURES:
% saves a figure displaying dominant eigenvectors, as well as the angle
% between said vectors
% if run = '*', does the same for session difference eigenvectors, 
% if session = '*', does the same for run difference eigenvectors

type1 = obj1.type;
type2 = obj2.type;


% Checks to make sure that objs are of different subject type, but have the
% same runs and sessions
if strcmp(type1,type2) 
    error('same types for objects: need different types')
elseif strcmp(obj1.sessions, obj2.sessions)==0 
    error('different session choice: need same sessions')
elseif strcmp(obj1.runs, obj2.runs) == 0
    error('different run choice: need same runs')
end



% Makes new data file named datafolder if it does not exist.
M=dir('Figures');
list_of_files = {M.name}';
if ~ismember(datafolder,list_of_files)
    str = input('datafolder does not exist.  Do you want to create new file? Y/N [Y]: ','s');
    if strcmp('Y',str)
        mkdir('Figures',datafolder)
    else
        print('exiting program...')
        return;
    end
end


% gets session and run choices for objs
session = obj1.sessions;
run = obj1.runs;

% a colormap for a graphical image of the dominant eigenvector
map = [linspace(1,0,50) zeros(1,49); zeros(1,99); zeros(1,49) linspace(0,1,50)]';

% gets the dominant eigenvectors of each object
x1 = obj1.coveigvects(:,1);
x2 = obj2.coveigvects(:,1);
figure('Position',[100,100,1000,400])

% creates a figure containing images of both dominant eigenvectors
subplot(1,2,1)
vectorImage(x1,length(obj1.ROIs),map,-1);
title(type1);
subplot(1,2,2)
vectorImage(x2,length(obj2.ROIs),map,-1);
title(type2);

% Title gives angle 'a' between dominant eigenvectors
suptitle({['eigenvectors for session ' session ' run ' run]; 
        ['a= ' num2str(x1'*x2) ' ' datafolder]})

% save and close figure inside of Figures/datafolder
savefig(['Figures/' datafolder '/'  'ctr-vs-tin-eigenvectors_session_' session '_run_' run])
close


% does the same, but for session difference dominant eigenvectors
if strcmp('*', run)
    
    x1 = obj1.sesdifcoveigvects(:,1);
    x2 = obj2.sesdifcoveigvects(:,1);
    figure('Position',[100,100,1000,400])

  
    subplot(1,2,1)
    vectorImage(x1,length(obj1.ROIs),map,-1);
    title(type1);
    subplot(1,2,2)
    vectorImage(x2,length(obj2.ROIs),map,-1);
    title(type2);

    suptitle({['eigenvectors for session difference session ' session]; 
               ['a= ' num2str(x1'*x2) ' ' datafolder]})

    savefig(['Figures/' datafolder '/ctr-vs-tin-eigenvectors_session_difference_session_' session])
    close
end

% does the same, but for run difference dominant eigenvectors
if strcmp('*', session)
    x1 = obj1.rundifcoveigvects(:,1);
    x2 = obj2.rundifcoveigvects(:,1);
    figure('Position',[100,100,1000,400])


    subplot(1,2,1)
    vectorImage(x1,length(obj1.ROIs),map,-1);
    title(type1);
    subplot(1,2,2)
    vectorImage(x2,length(obj2.ROIs),map,-1);
    title(type2);

    suptitle({['eigenvectors for run difference run ' run];
       ['a= ' num2str(x1'*x2) ' ' datafolder]})

    savefig(['Figures/' datafolder '/ctr-vs-tin-eigenvectors_run_difference_run_' run])
    close

    end


end