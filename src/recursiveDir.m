function list=recursiveDir(path,patter)
    fAll=dir(path);
    fls=dir([path patter]);
    if ~exist('list','var')
            list=[];
    end
    if length(fls) > 0
         for i=1:length(fls)
             l{i}=[path fls(i).name];
         end
        list=[list l];
    end
    for i=3:length(fAll) % skips . and .. rows
        if isdir([path fAll(i).name]) 
            lst=recursiveDir([path fAll(i).name filesep], patter);
            list=[list lst];
        end
    end
end