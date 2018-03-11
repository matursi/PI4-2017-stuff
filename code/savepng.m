function m = savepng(folder)
%Saves matlab images in folder as png images.  I did this to be quick after
%having a bunch of matlab images that needed to be accessible outside of
%matlab.  

m=dir(folder) %gets names of files
m = {m.name}';
length(m)
for i = 3: length(m) %starting from 3 since parts 1,2 are just .,..
    name = m{i};
    if strcmp(name(end-2:end),'fig') %find .png files, 
                                    %replace asterisk with a, since
                                    %otherwise can't access easily
        h = openfig([pwd '/' folder '/' name],'invisible');
        if strcmp(name(end-4), '*')
            name(end-4) = 'a';
        end
        if strcmp(name(end-10), '*')
            name(end-10) = 'a';
        end
        saveas(h,[folder '/' name(1:end-3) 'png']); %save as .png
    i   
    end
    
end
    

