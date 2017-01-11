function I = ambientLight(P,ka,Ia)%Synarthsh poy ypologizei to fwtismo logw diaxytoy fwtos apo to perivallon
ka = ka/255;%kanonikopoihsh tou ka wste na anhkei sto [0,1]
I = ka.*Ia;%pollaplasiazw kata stoixeio tous 2 pinakes gia na upologisw ton fwtismo
end

