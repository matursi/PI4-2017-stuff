classdef leadinfo
    %Class containing lead information, covariance information, and
    %information on differences between sessions and runs
  
    properties
        %initial data
        timeseries      % time series, size is numsubs x numrois x timelength. 
        ROIs            % regions of interest
        ROInames        % names of chosen ROIS
        subjects        % subject numbers, is in cell string form
        type            % takes 'ctr','tin', or '*' for both subjects
        sessions        % takes '1' '2' or '*' for both sessions
        runs            % takes '1' '2' or '*' for both runs
        times           % time interval for series
        filenames       % filenames containing time series, in char form
                        % to allow for greater manipulation 
        leadnorm        % norm to be used for lead matrix.  If none is
                        % used then the value is 'none'
        runspersubject  % number of total runs per subject, can be 1,2, or 4
        missingROIs     % tracks removed ROIs (typically outliers)
        missingSubs     % track removed subjects (typically outliers)
        
        % created data: these are properties generated from the above
        matrices            % cell of lead matrices for each subject and run
        vectors             % array of vectors representing the lead matices.
                            % each vector comprises a row of the array, so
                            % the dimensions are num. of individual runs x
                            % num of lead matrix elements
        sesdifs             % lead matrix differences over a session
        rundifs             % lead matrix differences over a single run
        covariance          % covariance matrix for lead vectors.
        sesdifcovariance    % covariance matrix for session differences.
        rundifcovariance    % covariance matrix for run differences.
        coveigvals          % covariance matrix eigenvalues 
        coveigvects         % covariance matrix eigenvectors
        sesdifcoveigvals    % session diff. covariance matrix eigenvalues
        sesdifcoveigvects   % session diff. covariance matrix eigenvectors
        rundifcoveigvals    % run diff. covariance matrix eigenvalues
        rundifcoveigvects   % run diff. covariance matrix eigenvectors
        
        currentprojcoords   % current projection coordinates of lead vectors
                            % to a current projection space
        currentprojspace    % the current projection space for lead vectors
        sesdifcurrentprojcoords     % same as above, but for sesdifs
        sesdifcurrentprojspace 
        rundifcurrentprojcoords     % same as above, but for rundifs
        rundifcurrentprojspace
        
        %default data (needed for changing values back to defaults when
        %necessary)
        defaultprojcoords       % default projection coordinates for lead vectors
        sesdifdefaultprojcoords % default projection coordinates for sesdifs
        rundifdefaultprojcoords % default projection coordinates for rundifs
        defaulttimeseries       % default time series of original data, without
                                % removed subjects or ROIs

    end
    
    methods
        function obj = leadinfo(session,run,type,intervals,rois,leadnorm)
        %Creates a new object of class leadinfo: 
        %INPUTS:
        % session: can be '1','2','*' sessions to be used
        % run:     runs to be used, same possible input choices as sessions
        % type:     input 'ctr', 'tin', or '*' for subject type
        % intervals: time intervals to be used
        % rois:     ROIs to be used
        % leadnorm: norm to be used for lead vectors, if none, put 'none'
        % OUTPUT: a leadinfo object
        
        %gives ROIs of object and roi names
            obj.ROIs = rois;
            
            load('new_rois/rois_names.mat');
            
            obj.ROInames = roi_names(rois);
            
        %gives time intervals for time series
            object.times = intervals;
           
              
            obj.sessions = session;
            obj.runs = run;
            obj.type = type;      
            obj.times = intervals;
            obj.leadnorm = leadnorm;
            
        % gives subjects, filenames, current timeseries, subject names
            [obj.matrices, obj.vectors,obj.timeseries, names] = lead_data(session, run,'none', type,intervals,leadnorm,rois,'*');
                subs = char(names);
                obj.subjects = unique(cellstr(subs(:,end-6:end-4))); 
                obj.filenames = subs;
                obj.runspersubject = length(subs)/length(obj.subjects);
                
                % This is fixed, in case want to go back to original data
                obj.defaulttimeseries = obj.timeseries;

        % gives session difference and run difference vectors
            [obj.sesdifs,obj.rundifs] = vectdifs(obj.sessions,obj.runs,obj.vectors,obj.filenames);

        % gives covariance data
            [obj.covariance,obj.coveigvals, obj.coveigvects] = covdata(obj.vectors);
            
        % gives run difference data if both runs are used
            if strcmp(run, '*')
                [obj.sesdifcovariance,obj.sesdifcoveigvals, obj.sesdifcoveigvects] = covdata(obj.sesdifs);
            
                [obj.sesdifdefaultprojcoords, obj.sesdifcurrentprojcoords, obj.sesdifcurrentprojspace] = ...
                coordata(obj.sesdifcoveigvects,obj.sesdifs');
            end
            
        % gives session difference data if both sessions are used
            if strcmp(session,'*')
                [obj.rundifcovariance,obj.rundifcoveigvals, obj.rundifcoveigvects] = covdata(obj.rundifs);
                
                [obj.rundifdefaultprojcoords, obj.rundifcurrentprojcoords, obj.rundifcurrentprojspace] = ...
                coordata(obj.rundifcoveigvects,obj.rundifs');
            end

        % sets projection data
            [obj.defaultprojcoords, obj.currentprojcoords, obj.currentprojspace] = ...
            coordata(obj.coveigvects,obj.vectors');
        
            
        
            
           
        end
        
        function obj = removesubs(obj, subnums)
        % used to remove subjects (more efficient than creating an entire
        % new leadinfo class by doing the initial process all over again.
        % I used this when I wanted to remove outliers    
        % INPUTS: 
        % obj: leadinfo obj
        % subnums, subject numbers, in str form inside cell
        % OUTPUT: leadinfo object with removed subject, and resulting data
        
        % Checks current number of subjects, also used to check number of
        % files related to the subject.
            M = length(obj.subjects);
            v= obj.runspersubject;
       
        % changes subjects lists, gets index of elements with remaining
        % subject from the subject list
            [obj.subjects, raw_index] = setdiff(obj.subjects, subnums);
        
        % gets indices of all data related to removed subjects
            fullind = M*reshape(ones(1,length(raw_index))'*(0:v-1),v*length(raw_index),1);
            fullind = fullind+repmat(raw_index,v,1);
            
        % resets data with only remaining subjects
            obj.filenames = obj.filenames(fullind,:);
            obj.timeseries = obj.timeseries(fullind,:,:);
            obj.matrices = obj.matrices(raw_index);
            obj.vectors = obj.vectors(fullind,:);
            obj.missingSubs = union(obj.missingSubs, subnums);
            
        % recalculates some caluclated data with new initial data    
            [obj.sesdifs,obj.rundifs] = vectdifs(obj.sessions,obj.runs,obj.vectors,obj.filenames);
            [obj.covariance,obj.coveigvals, obj.coveigvects] = covdata(obj.vectors);
            [obj.defaultprojcoords, obj.currentprojcoords, obj.currentprojspace] = ...
            coordata(obj.coveigvects,obj.vectors');
        
       % same as above     
            if strcmp(obj.runs,'*')
                [obj.sesdifcovariance,obj.sesdifcoveigvals, obj.sesdifcoveigvects] = covdata(obj.sesdifs);
                [obj.sesdifdefaultprojcoords, obj.sesdifcurrentprojcoords, obj.sesdifcurrentprojspace] = ...
                coordata(obj.sesdifcoveigvects,obj.sesdifs');
            end
            
            if strcmp(obj.sessions, '*')
                [obj.rundifcovariance,obj.rundifcoveigvals, obj.rundifcoveigvects] = covdata(obj.rundifs);
                [obj.rundifdefaultprojcoords, obj.rundifcurrentprojcoords, obj.rundifcurrentprojspace] = ...
                coordata(obj.rundifcoveigvects,obj.rundifs');
            end
 
           
        end
      
        function obj = removerois(obj,rois)
      % removes ROI from initial data, changes resulting data
      % input is leadinfo object, and rois to remove, output is the altered
      % leadinfo object with data not involving removed rois    
      % INPUTS: leadinfo object, and roi numbers in list
      % OUTPUT: leadinfo object with removed ROI and resulting data
      
      % gets indices and values of remaining rois
            [ROIs, index] = setdiff(obj.ROIs, rois);
            
      % records default rois (in case we want to change back)
            defrois = default_rois();
            
      % gets remaining ROI names, timeseries, ROIs, and logs missing
      % ROIs.
            names = setdiff(cellstr(obj.ROInames),defrois(rois));
            obj.ROInames = char(names);
            obj.timeseries = obj.timeseries(:,index,:);
            obj.ROIs = ROIs;
            obj.missingROIs = unique([obj.missingROIs, rois]);
            
      % reevaluates lead matrices/ vectors, and difference vectors
            [obj.matrices,obj.vectors] = createleads(obj.timeseries,obj.times,obj.leadnorm);
            [obj.sesdifs,obj.rundifs] = vectdifs(obj.sessions,obj.runs,obj.vectors,obj.filenames);
            
      % reevaluates covariance and projection data
            [obj.covariance,obj.coveigvals, obj.coveigvects] = covdata(obj.vectors);
            [obj.defaultprojcoords, obj.currentprojcoords, obj.currentprojspace] = ...
            coordata(obj.coveigvects,obj.vectors');
            
            
            if strcmp(obj.runs, '*')
                [obj.sesdifcovariance,obj.sesdifcoveigvals, obj.sesdifcoveigvects] = covdata(obj.sesdifs);
                [obj.sesdifdefaultprojcoords, obj.sesdifcurrentprojcoords, obj.sesdifcurrentprojspace] = ...
                coordata(obj.sesdifcoveigvects,obj.sesdifs');
            end
            
            if strcmp(obj.sessions, '*')
                [obj.rundifcovariance,obj.rundifcoveigvals, obj.rundifcoveigvects] = covdata(obj.rundifs);
                [obj.rundifdefaultprojcoords, obj.rundifcurrentprojcoords, obj.rundifcurrentprojspace] = ...
                coordata(obj.rundifcoveigvects,obj.rundifs');
            end 

        end
        

        function obj = setcoordspace(obj, space,types)
        %changes projection space for lead or difference vectors:
        % INPUT: 
        % obj:          leadinfo object
        % space:        cell of new projection spaces (up to 3, one for
        %               lead, session diff. or run diff.
        % types:        cell of strings, can be 'none', 'session', or 'run'
        % OUTPUT:
        % obj:          leadinfo objected with new projection space and
        %               projection coordinates
        
        
            %make sure that number of projections is the same as number or
            %types you want to change
            if length(space) ~= length(types)
                error('spaces cell not same length as type cell')
            end
            
            % gets index for types
            [a,ind] = intersect(types,'none');
            
            % if wanting to change lead vector projection...
            if ~isempty(a)
                obj.currentprojspace = space{ind};
                obj.currentprojcoords = space{ind}\obj.vectors';
                
            end
            
            % gets index for 'session' if it appears in types cell
            [a,ind] = intersect(types,'session');
            
            % if you want to change session difference projections...
            if ~isempty(a)
                obj.sesdifcurrentprojspace = space{ind};
                obj.sesdifcurrentprojcoords = space{ind}\obj.sesdifs';
                
            end
            
            % same as above, but with run differences
            [a,ind] = intersect(types,'run');
            
            if ~isempty(a)
                obj.rundifcurrentprojspace = space{ind};
                obj.rundifcurrentprojcoords = space{ind}\obj.rundifs';
                
            end
           
        end
        
        %adding a subject or ROI, if it is not present.  I ended up never
        %needing to create this method, but I had it set up just in case.
        function addsubs(obj, subnums)
        end
        
        function addrois(obj, rois)

        end
        
        function leads = leadmatpics(obj,num,vis)
        % gives graphical color based image of lead matrices.  Can take
        % either individual subjects by name or can take groups of subjects
        % by session, type, run, etc.
        % INPUT:
        % obj:          leadinfo object
        % num:          lead matrices you want images for.  Enter either a
        %               number or a length 3 cell with a list of subject
        %               numbers, and the last two are some combo of
        %               characters '1','2','*'
        % vis:          put in 'on' or 'off' for whether you want to see the
        %               actual images pop out
        % OUTPUT: 
        % leads:        a cell of figures of the graphical images
            
        %if list of numbers was entered, just get the matrices with those
        %indices
            if isnumeric(num)
            
            matrices = obj.matrices(num);
            
        %otherwise, get indices corresponding to chosen subjects, sessions, runs    
            elseif iscell(num) & length(num) == 3 %need format to be {sublist, '1'/'*', '2'/'*' }
                1+1;
                subID = num{1};     
                sescheck = 1:(1+length(str2num(num{2})));       
                runcheck = 4:(6+length(str2num(num{3})));
                IDcheck = 17:19;
                
                for i = 1:length(num{1})
                    subID{i} = ['s', num2str(str2num( num{2})),'run', num2str(str2num(num{3})),subID{i}]
                end   
          % turns cell data into indices satisfying cell specifications   
                num = find(ismember(obj.filenames(:,[sescheck,runcheck,IDcheck]),subID))
                matrices = obj.matrices(num);
            
            
            end
            
          % gets titles to put on figures, based on file names of subject
          % data
            titles = cellstr(obj.filenames(num,1:19));
          
          % gives a colormap for the graphical image
            redtocyan = [linspace(1,0,50),zeros(1,50); zeros(1,50),linspace(0,1,50);zeros(1,50),linspace(0,1,50)]';

            l=length(matrices);
            leads = {}
            
          % creates images, shows them if vis is set to 'on'
            for i = 1:l
                leads{i}=figure('Visible',vis);
                image(matrices{i},'CDataMapping','scaled');
                colormap(redtocyan);
                colorbar;
                title(titles{i},'Interpreter','none');
            end
        end     
        
        function pics = vecpics(obj,vectors,imsize,symtype) %want datalength x number of subjects
        % This one is unlike the leadmat pics.  The above takes leadinfo
        % objects and uses the lead matrix data in matrix form.  This one
        % takes any vectors associated with the leadinfo object by calling vectorImage.  I wrote
        % it as a leadinfo object function because I only used it with data
        % associated with the leadinfo object, but it does not necessarily
        % call the object itself
        % INPUTS:
        % obj:      leadinfo obj.
        % vectors:  a list of vectors, must be of same length
        % imsize:   number of regions (vectors correspond to upper
        %           triangular part of a square matrix.  The imsize is just the
        %           size of the matrix.  It's square, so just put the
        %           number corresponding to the length)
        % symtype:  -1 for antisymmetric, 1 for symmetric
        % output: a cell of figures of vector images.

            greentopurple = [zeros(1,50), linspace(0,1,50);linspace(1,0,50), zeros(1,50); zeros(1,50) linspace(0,1,50)]';
            s = size(vectors); 
            pics={};

            for i=1:s(2)
                pics{i} = figure('Visible','off');
                vectorImage(vectors(:,i),imsize,greentopurple,symtype)
            end

        end
        
        %This was not a complete function either. I normally just created
        %new leadinfo objects if I wanted a different norm.
        function obj= changenorm(obj, newnorm)
            
            obj.leadnorm = newnorm;
            
            
        end
        
        
        
    end
    
end


function [difs,difs2] = vectdifs(session, run,vectors,filenames)
% calculates the session or run differences between lead vectors for
% of the same subjects
%

difs = []; %puts empty lists just in case either session or run is not '*'
difs2 = [];

% if both runs are used, then we can take a session difference
if strcmp(run,'*') == 1
    
    % gets indices of lead vectors corresponding to 'run1' 
    r1files = find(strcmp(cellstr(filenames(:,4:7)),'run1')); 
    
    % gets indices of lead vectors corresponding to 'run2'
    r2files = find(strcmp(cellstr(filenames(:,4:7)),'run2'));
    
    %takes the difference
    difs = vectors(r2files,:) - vectors(r1files,:);
       
end

% if both sessions are used, then we can take a run difference.  Code is
% just like the above with session differences
if strcmp(session,'*') == 1
    s1files = find(strcmp(cellstr(filenames(:,1:2)),'s1'));
    s2files = find(strcmp(cellstr(filenames(:,1:2)),'s2'));
    difs2 = vectors(s2files,:) - vectors(s1files,:);
       
end
    
    
end

function [covs, eigs, vects] = covdata(vectors)
%computes the covariance matrix, the eigenvalues, and the eigenvectors of
%said covariance matrix for 'vectors' 

covs = cov(vectors);
[u,s,vects] = svd(covs);

eigs = diag(s);

end

function [coord,curcoord,space] = coordata(sp, v)
% gives coordinates, 'current' coordinates, and projection space.
% INPUTS: 
%sp:    projection space,
%v:     vectors that you want to project
% OUTPUTS:
% coord: The projection coordinates: i.e., This gives an array of x = (x_i) with
%        x_i = coordinates for vector v_i: i.e., least squares solution for
%        sp  x = v
% curcoord: gives a changeable copy of coord.  I did this because I wanted
%           to record both default coordinates for when the leadinfo obj is
%           first created, and the current projection coordinates, given
%           the latest choice of projection space
% space:    the projection space to be used.
 space = sp(:,:);
 coord = sp\v;
 curcoord = coord(:,:);

end

function d = default_rois()
%calls an file with the actual ROI names (for when I need to label
%something)
load('new_rois/rois_names.mat');
d= roi_names;

end



function [matrices, vectors] = createleads(mats,time,normalize)
%creates lead matrices and vectors for leadinfo object.
%mats are the time series, time is the time intercal, and normalize is the
%choice of norm.  We call the lead function several times to generate both
%matrix and vectors.  
matrices = {};
vectors = [];

s = size(mats(:,:,time));

for i = 1:s(1)
    [m,v]=lead(reshape(mats(i,:,time),s(2),s(3)),normalize);
    matrices = [matrices, m];
    vectors = [vectors;v];
end

end
