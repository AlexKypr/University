%Napoleon - Christos Oikonomou AEM:7952
%Alexandros-Charalampos Kyprianidis AEM:8012

function window = getWindow(N, windowType, a)
%
%Takes as input the length of the asking window and the constant a
if strcmp(windowType, 'KBD') == 1
    wn = kaiser(N/2 + 1,a);
    paranomastis = sum(wn);
    window = zeros(N, 1);
    for i = 1 : N / 2 
        temp1 = sum(wn(1 : i));
        window(i) = temp1 / paranomastis;
    end
    window(1:N/2) = sqrt(window(1:N/2));
    window(N:-1:(N/2+1)) = window(1:N/2);
elseif strcmp(windowType, 'SIN') == 1
    window = sin(pi * ((0 : (N - 1)) + 0.5) / N)';
end
