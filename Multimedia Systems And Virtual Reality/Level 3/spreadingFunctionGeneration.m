%This is the code we used to calculate Ssf_Lsf.mat it was placed in
%function psycho.m
%1.For long frames
Lsf = zeros(69,69);
for i = 1:69
	for j = 1:69
        Lsf(i,j) = spreadingFunction(i,j,'long');
	end
end
%1.for ESH
Ssf = zeros(42,42);
for i = 1:42
	for j = 1:42
        Ssf(i,j) = spreadingFunction(i,j,'short');
	end
end
save ('Ssf_Lsf.mat', 'Lsf', 'Ssf');


%this is the function that we called in the psycho.m
function x = spreadingFunction(i,j,type)
    load('TableB219.mat');
switch type
    %check type
    case 'short'
        bvalBands = B219b(:, 5); %#ok<NODEF>
        if(i>=j)%if i index is bigger than j
            tmpx = 3.0*(bvalBands(j)-bvalBands(i));%calculate tmpx
        else
            tmpx = 1.5*(bvalBands(j)-bvalBands(i));%calculate tmpx
        end
        % the rest is simple calculations
        tmpz = 8*min((tmpx-0.5)^2 - 2*(tmpx-0.5),0);
        tmpy = 15.811389 + 7.5*(tmpx + 0.474) - 17.5*(1.0+ (tmpx + 0.474)^2)^0.5;
        if(tmpy < -100)
            x = 0;
        else
            x = 10^((tmpz+tmpy)/10);
        end
    case 'long'
        %check type
        bvalBands = B219a(:, 5); %#ok<NODEF>
        if(i>=j)%if i index is bigger than j
            tmpx = 3.0*(bvalBands(j)-bvalBands(i));%calculate tmpx
        else
            tmpx = 1.5*(bvalBands(j)-bvalBands(i));%calculate tmpx
        end
        % the rest is simple calculations
        tmpz = 8*min((tmpx-0.5)^2 - 2*(tmpx-0.5),0);
        tmpy = 15.811389 + 7.5*(tmpx + 0.474) - 17.5*(1.0+ (tmpx + 0.474)^2)^0.5;
        if(tmpy < -100)
            x = 0;
        else
            x = 10^((tmpz+tmpy)/10);
        end

end

end
