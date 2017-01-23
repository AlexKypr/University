% Napoleon-Christos Oikonomou AEM:7952
% Alexandros-Charalampos Kyprianidis AEM:8012


function frameFout = iTNS(frameFin, frameType, TNScoeffs)
%
% calculates original frame by filtering with the inverse filter
if(strcmp(frameType, 'OLS') || strcmp(frameType, 'LSS') || strcmp(frameType, 'LPS'))
    frameFout = filter(1, [1 -TNScoeffs'], frameFin);
elseif(strcmp(frameType,'ESH'))
    frameFout = zeros(128,8);
    for k = 0 : 7
       frameFout(:,k+1) = filter(1, [1 -TNScoeffs(:,k+1)'], frameFin(:,k+1));
    end
end
end
