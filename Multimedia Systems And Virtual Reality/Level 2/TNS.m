% Napoleon-Christos Oikonomou AEM:7952
% Alexandros-Charalampos Kyprianidis AEM:8012

function [frameFout, TNScoeffs] = TNS(frameFin, frameType)
%
%

% coefficient range based on number of bits used
qstep = 0.1;
bits = 4;
aRange = qstep*(2^bits - 1); %0-1.5 -> [-0.75,0.75]
min = -aRange/2;             %  -0.75
load('TableB219.mat');
longFrameBands = B219a(:, 2); %#ok<NODEF>
longFrameBands(70) = 1024;
shortFrameBands = B219b(:, 2); %#ok<NODEF>
shortFrameBands(43) = 128;
P = getEnergy(frameFin, frameType);

if(strcmp(frameType, 'OLS') || strcmp(frameType, 'LSS') || strcmp(frameType, 'LPS'))
    %% Step 1
    %calculates normalization coefficients
    S = zeros(1024, 1);
    for i = 1 : 68
        for j = (longFrameBands(i) + 1) : longFrameBands(i + 1)
            S(j) = sqrt(P(i));
        end
    end
    S(939 : 1024) = sqrt(P(69, 1));
    for i = 1023 : -1 : 1
        S(i) = (S(i) + S(i + 1)) / 2;
    end
    for i = 2 : 1024
        S(i) = (S(i) + S(i - 1)) / 2;
    end
    % normalizes MDCT coefficients
    X = frameFin ./ S;
    
    %% Step 2
    %calculates a based on e^2 minimization
    [~, L] = corrmtx(X, 4);
    r = L(2 : 5, 1);
    R = L(1 : 4, 1 : 4);
    a = (R \ r)';
    %a1 = lpc(X, 4);
    
    %moves a values inside the proper range
    for i = 1 : 4
        if a(i) > 0.75
            a(i) = 0.75;
        elseif a(i) < -0.75
        a(i) = -0.75;
        end
    end
    %step 0.1
    sym = round((a-min)/(qstep));
    a = sym*qstep + min;
    %% Step 3
    % check if the filter will be stable
	b = roots([1 -a]);
	b = b .* (abs(b) < 1) + (1 ./ b) .* (abs(b) >= 1);
	a = poly(b);
	a = -a(2 : end);    
    for i = 1 : 4
        if a(i) > 0.75
            a(i) = 0.75;
        elseif a(i) < -0.75
            a(i) = -0.75;
        end
    end
	%step 0.1
	sym = round((a-min)/(qstep));
    a = sym*qstep + min;
    TNScoeffs = a';
    
    %% Step 4
    frameFout = filter([1 -a], 1, frameFin); 
    
elseif(strcmp(frameType, 'ESH'))
    %same procedure as above, but this time for 8 frames of length 128,
    %instead of one of length 1024
    %% Step 1
    frameFout = zeros(128,8);
    S = zeros(128, 8);
    for k = 0 : 7
        for j = 1 : 41
            for i = (shortFrameBands(j) + 1) : shortFrameBands(j + 1)
                S(i,k+1) = sqrt(P(j,k+1));
            end
        end
        S(128,k+1) = sqrt(P(j + 1,k+1));
    end
    
    for k = 0 : 7
        for i = 127 : -1 : 1
            S(i,k+1) = (S(i,k+1) + S(i,k+1)) / 2;
        end
    end
    
    for k = 0 : 7
        for i = 2 : 128
            S(i,k+1) = (S(i,k+1) + S(i-1,k+1)) / 2;
        end
    end
    X = frameFin ./ S;
    
    %% Step 2
    TNScoeffs = zeros(4, 8);
    for k = 0 : 7
        [~, L] = corrmtx(X(:,k+1), 4);
        r = L(2 : 5, 1);
        R = L(1 : 4, 1 : 4);
        a = (R \ r)';
        %a1 = lpc(X, 4);
        for i = 1 : 4
            if(a(i) > 0.75)
                a(i) = 0.75;
            elseif(a(i) < -0.75)
                a(i) = -0.75;
            end
        end
        sym = round((a-min)/(qstep));
        a = sym*qstep + min;
        
        %% Step 3
        b = roots([1 -a]);
        b = b .* (abs(b) < 1) + (1 ./ b) .* (abs(b) >= 1);
        a = poly(b);
        a = -a(2 : end);
        %step 0.1
        for i = 1 : 4
            if(a(i) > 0.75)
                a(i) = 0.75;
            elseif(a(i) < -0.75)
                a(i) = -0.75;
            end
        end
         sym = round((a-min)/(qstep));
         a = sym*qstep + min;
        TNScoeffs(:,k+1) = a';
        %% Step 4
        frameFout( 1 : 128,k+1) = ...
            filter([1 -a], 1,...
            frameFin(:,k+1));
    end
end
end
