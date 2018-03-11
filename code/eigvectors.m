function domeigvectors(obj1,obj2,datafolder)
% generates a scatterplot of points which are projections of lead/
% difference vectors of obj1 and obj2 to their respective domain

type1 = obj1.type;
type2 = obj2.type;


if strcmp(type1,type2) 
    error('same types for objects: need different types')
elseif strcmp(obj1.sessions, obj2.sessions)==0 
    error('different session choice: need same sessions')
elseif strcmp(obj1.runs, obj2.runs) == 0
    error('different run choice: need same runs')
end

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

session = obj1.sessions;
run = obj1.runs;


map = [linspace(1,0,50) zeros(1,49); zeros(1,99); zeros(1,49) linspace(0,1,50)]';

x1 = obj1.coveigvects(:,1);
x2 = obj2.coveigvects(:,1);
figure('Position',[100,100,1000,400])

subplot(1,2,1)
vectorImage(x1,length(obj1.ROIs),map,-1);
title(type1);
subplot(1,2,2)
vectorImage(x2,length(obj2.ROIs),map,-1);
title(type2);

suptitle({['eigenvectors for session ' session ' run ' run]; 
        ['a= ' num2str(x1'*x2) ' ' datafolder]})

savefig(['Figures/' datafolder '/'  'ctr-vs-tin-eigenvectors_session_' session '_run_' run])
close

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