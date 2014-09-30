function T1s = LookForSwitching(HistT1s)


disp('looking for switching T1s')


done = [];

T1s = {};

for f=2:length(HistT1s)
    ks = cell2mat(HistT1s{f}.keys);
    for i=1:length(ks)
        T1 = [];
        k = ks(i);
        if ismember(k,done) continue; end;
        Vs = HistT1s{f}(k);
        T1 = [T1 ; [ Vs , f]];
        fprintf('\nTransition - %i<->%i / + %i<->%i\n', Vs(1),Vs(2),Vs(3),Vs(4));
        % now look for similar T1s
        
        for f2 = f+1:length(HistT1s)
            ks2 = cell2mat(HistT1s{f2}.keys);
            if ismember(k,ks2)
                fprintf('got a repeat here!  ')
                Vs2 = HistT1s{f2}(k);
                fprintf('%i Transition - %i<->%i / + %i<->%i\n', f2, Vs2(1),Vs2(2),Vs2(3),Vs2(4));
                T1 = [T1 ; [Vs2 , f2]];
            end
            if ismember(Hkey(Vs(3),Vs(4)),ks2)
                fprintf('got a back one here!')
                Vs2 = HistT1s{f2}(Hkey(Vs(3),Vs(4)));
                fprintf('%i Transition - %i<->%i / + %i<->%i\n', f2 ,Vs2(1),Vs2(2),Vs2(3),Vs2(4));
                T1 = [T1 ; [Vs2 , f2]];
            end
        end
        done = [done k Hkey(Vs(1) , Vs(2))];
        T1s = [T1s ; T1];
    end
    
end
end
            
            
    function k = Hkey(x,y)
        k = 10000*min(x,y)+max(x,y);
    end
    
    