function f = TriPaint( X , V , CV )%h sunarthsh TriPaint pou xrwmatizei ena trigwno me orismata X,V,CV
%Arxikopoiw 4 Vectors pou tha xrhsimopoihsw gia na apothikeusw tis megistes
%kai elaxistes times tou x kai toy y se kathe pleyra tou trigwnou.
xkmax = zeros(1,3);
xkmin = zeros(1,3);
ykmin = zeros(1,3);
ykmax = zeros(1,3);


dimension = size(X);%Apothikeuw tis diastaseis tou matrix X.
dim = size(V);%Apothikeuw tis diastaseis tou pinaka V.
%Xrwmatizw tis korufes tou trigwnou wste na mporw na kanw grammikh paremvolh
%sthn synexeia
X(V(1,1),V(2,1),1) = CV(1,1);
X(V(1,1),V(2,1),2) = CV(1,2);
X(V(1,1),V(2,1),3) = CV(1,3);
X(V(1,2),V(2,2),1) = CV(2,1);
X(V(1,2),V(2,2),2) = CV(2,2);
X(V(1,2),V(2,2),3) = CV(2,3);
X(V(1,3),V(2,3),1) = CV(3,1);
X(V(1,3),V(2,3),2) = CV(3,2);
X(V(1,3),V(2,3),3) = CV(3,3);


%Apothikeuw ta xarakthristika twn pleurwn tou trigwnou.(klish eutheias kai statheros oros)
m(1) = (V(2,2)-V(2,1))/(V(1,2)-V(1,1));%(y2-y1)/(x2-x1)
m(2) = (V(2,3)-V(2,2))/(V(1,3)-V(1,2));
m(3) = (V(2,1)-V(2,3))/(V(1,1)-V(1,3));
betta(1) = V(2,1) - m(1)*V(1,1);% b = y1 - mx1
betta(2) = V(2,2) - m(2)*V(1,2);
betta(3) = V(2,3) - m(3)*V(1,3);


countDelete = 0;
excludedLine = zeros(1);%Arxikopoioume ton pinaka ston opoio tha swsoume thn pleura pou theloume na exairethei
%Arxikopoiw ena vector pou tha xrhsimopoihsw gia na antistoixisw thn pleura
%poy vriskomai me thn thesi y ston pinaka V sthn periptwsh pou antistoixei 
%sthn suntetagmenh ymin ths pleuras
identity = zeros(1,3);
%omoiws me to identity alla gia thn periptwsh pou antistoixei sthn
%syntetagmenh ymax ths pleuras.Einai kathara megethos poy xrhsimopoieitai
%gia ton algorithmo.
id = zeros(1,3);

LAOP = zeros(2,3);%Arxikopoiw ton pinaka LAOP pou tha xrhsimopoihsw gia na apothikeuw tis suntetagmenes twn energwn oriakwn shmeiwn kai thn pleura sthn opoia anhkei kathe oriako shmeio
LAL = zeros(1);%Arxikopoiw ton vector LAL pou tha xrhsimopoihsw gia na apothikeuw tis energes pleures

%Diatrexw to plithos twn korufwn tou trigwnou me skopo na vrw tis megistes
%kai elaxistes korufes kathe pleuras.
for k = 1:1:dim(2)
    l = k;
    if k == 3%sthn periptwsh pou eimai sthn 3 korufh thelw na parw to l = 1, opote kanw auto to texnasma wste na isxuei to l+1.Alliws tha eixa l+1 = 4 enw thelw l+1 = 1.
        l = 0;
    end
    if V(1,k) >= V(1,l+1)%elegxw gia thn x.
        xkmax(k) = V(1,k);
        xkmin(k) = V(1,l+1);
    else%elegxw gia thn x.
        xkmax(k) = V(1,l+1);
        xkmin(k) = V(1,k);
    end
    if V(2,k) >= V(2,l+1)%elegxw gia thn y.
        ykmax(k) = V(2,k);
        ykmin(k) = V(2,l+1);
        identity(k) = l+1;
        id(k) = k;
    else%elegxw gia thn y.
        ykmax(k) = V(2,l+1);
        ykmin(k) = V(2,k);
        identity(k) = k;
        id(k) = l+1;
    end
end

%Psaxnw to oliko ymin,ymax,xmin,xmax
ymin = min(ykmin);
ymax = max(ykmax);
xmax = max(xkmax);
xmin = min(xkmin);

%Psaxnw  thn lista energwn pleurwn pou sthn prwth epanalhpsh tha einai oi
%pleures pou exoun ws korufh ekeinh me to elaxisto y.
countA = 1;
countO = 1;
for k = 1:1:dim(2)
    if  ykmin(k) == ymin%elegxw an to elaxisto mias akmhs einai iso me to oliko elaxisto
        LAL(countA) = k;%thewrw k thn pleura dld k = 1 h prwth pleura anamesa sthn 1h kai sthn 2h korufh
        countA = countA + 1;%auxanw ton metrhth twn stoixeiwn tou vector LAL
    end
end

 
%Psaxnw thn lista energwn oriakwn shmeiwn to prwto energo oriako shmeio
%prepei na einai h "elaxisth" korufh(me to mikrotero y)
for k = 1:1:dim(2)
    if ykmin(k) == ymin
        LAOP(countO,1) = V(1,identity(k));%Eisagw to x toy shmeiou
        LAOP(countO,2) = ykmin(k); %Eisagw to y toy shmeiou
        LAOP(countO,3) = k;%Eisagw se poia pleura antistoixei to shmeio
        countO = countO + 1;%auxanw ton metrhth twn stoixeiwn tou matrix LAOP
    end
end

%Edw xekinaei h kuria leitourgia tou kwdika
%Skanarw ola ta shmeia tou pinaka X poy uparxei pithanothta na xreiazontai
%vapsimo.Opote skanarw to y apo thn elaxisth mexri thn megisth dunath timh
%poy mporei na parei mia korufh tou trigwnou.
for y = ymin:1:ymax
    countex = 0;%Arxikopoiw ton metrhth pou tha xrhsimopoihthei gia tis exairoumenes pleures tis listas twn energwn pleurwn
    %Kanw taxinomhsh ws pros x tou matrix LAOP(lista energwn oriakwn shmeiwn)
    %opws perigrafetai ston algorithmo plhrwshs me xrhsh tou
    %bubblesort.Epishs opws diatasw kai ta alla stoixeia tou pinaka gia na
    %antistoixoun sto idio shmeio.
    for j = 1:1:countO-2%xrhsimopoiw countO - 2 epeidh an kai o algorithmos kanonika einai gia countO - 1 sthn sugkekrimenh periptwsh otan prosthetoume ena stoixeio sto matrix to countO exei panta ena stoixeio parapanw apo auta pou periexontai ston pinaka
        for i = 1:1:countO-2
            if(LAOP(i,1)>LAOP(i+1,1))
                temp1 = LAOP(i,1);
                LAOP(i,1) = LAOP(i+1,1);
                LAOP(i+1,1) = temp1;
                temp2 = LAOP(i,2);
                LAOP(i,2) = LAOP(i+1,2);
                LAOP(i+1,2)=temp2;
                temp3 = LAOP(i,3);
                LAOP(i,3) = LAOP(i+1,3);
                LAOP(i+1,3) = temp3;
            end
        end
    end
    savedCoords = ones(2);%Arxikopoiw ton pinaka pou swzoume tis suntetagmenes twn energwn oriakwn shmeiwn.
    c = 0;%Arxikopoiw ton deikth c pou xrhsimopoeitai gia na deixnei to x ths suntetagmenhs pou swzoume(Ama einai h prwth h h deuterh).
    warn = 0;%Arxikopoiw to warn pou exei thn morfh kapoiou flag kai xrhsimopoieitai sthn periptwsh pou petuxoume kapoia korufh tou trigwnoy.
    to = size(LAOP);%Swzw tis diastaseis tou LAOP.
    %Skanarw ola ta dunata x gia na vrw ta 2 shmeia twn pleurwn pou "temnontai" apo to trexon y pou vrisketai h epanalhpsh.
    for x = xmin:1:xmax
        %Skanarw olh thn lista oriakwn shmeiwn kathws to zeugos shmeiwn
        %prepei na anhkei se auta.
        for p = 1:1:to(1)
            if x == round(LAOP(p,1))%elegxoume to x pou trexei sthn epanalhpsh an einai iso me to strogulopoihmeno x kapoiou apo thn lista energwn oriakwn shmeiwn gt to x einai akeraios arithmos enw tou LAOP mporei na periexei dekadika pshfia. 
                %Edw vlepoume thn xrhsh tou warn.Ousiastika to provlhma pou
                %eixe prokupsei htan oti otan petuxaine mia korufh ws
                %energo oriako shmeio opws leei o algorithmos 8ewrei pws
                %ama htan zugos o arithmos oriakwn shmeiwn paremene zugos
                %me apotelesma na mhn vafei ta shmeia ths pleuras kai na ta
                %afhnei leuka.
                if (x == V(1,1) && y == V(2,1)) || (x == V(1,2) && y == V(2,2)) || (x == V(1,3) && y == V(2,3))
                    warn = warn + 1;       
                else
                    warn = warn - 1;
                end
                 %elegxw an to warn <=1 epeidh an einai megalutero shmainei
                 %oti petuxe se korufh opote 8eloume mono mia fora na
                 %kanoume thn diadikasia kai den 8eloume na swsoume oti ta
                 %shmeia sta opoia endiamesa tous tha vapsoume tha einai to
                 %idio shmeio!
                 if warn<=1
                      c = c + 1;%To auxanw efoson mphka mesa sthn epanalhpsh ara tha xreiastei na swsw suntetagmenh me deikth c = c + 1    
                      %Vriskw gia kathe periptwsh thn apostash tou energou
                      %oriakou shmeiou apo tis 2 korufes ths pleuras sthn
                      %opoia vrisketai.Auto antistoixei sto distance1 kai
                      %distance 2.
                      %Epishs vriskw to xrwma se kathe periptwsh me tous
                      %deiktes R,G,B me grammikh paremvolh opws zhteitai
                      %sthn ekfwnhsh ths ergasias.
                    if LAOP(p,3) == 1%elegxw se poia pleura vriskomai wste na parw ta katallhla shmeia gia na vrw thn apostash apo to trexon oriako shmeio.
                        distance1 = ((sqrt((V(1,1)-x)^2 + (V(2,1)-y)^2))/(sqrt((V(1,1)-V(1,2))^2 + (V(2,1)-V(2,2))^2)));
                        distance2 = ((sqrt((V(1,2)-x)^2 + (V(2,2)-y)^2))/(sqrt((V(1,1)-V(1,2))^2 + (V(2,1)-V(2,2))^2)));
                        R = (1-distance1)*CV(1,1) + (1-distance2)*CV(2,1);
                        G = (1-distance1)*CV(1,2) + (1-distance2)*CV(2,2);
                        B = (1-distance1)*CV(1,3) + (1-distance2)*CV(2,3);
                     elseif LAOP(p,3) == 2%elegxw se poia pleura vriskomai wste na parw ta katallhla shmeia gia na vrw thn apostash apo to trexon oriako shmeio.
                       distance1 = ((sqrt((V(1,2)-x)^2 + (V(2,2)-y)^2))/(sqrt((V(1,2)-V(1,3))^2 + (V(2,2)-V(2,3))^2)));
                       distance2 = ((sqrt((V(1,3)-x)^2 + (V(2,3)-y)^2))/(sqrt((V(1,2)-V(1,3))^2 + (V(2,2)-V(2,3))^2)));
                       R = (1-distance1)*CV(2,1) + (1-distance2)*CV(3,1);
                       G = (1-distance1)*CV(2,2) + (1-distance2)*CV(3,2);
                       B = (1-distance1)*CV(2,3) + (1-distance2)*CV(3,3);
                      elseif LAOP(p,3) == 3%elegxw se poia pleura vriskomai wste na parw ta katallhla shmeia gia na vrw thn apostash apo to trexon oriako shmeio.
                       distance1 = ((sqrt((V(1,3)-x)^2 + (V(2,3)-y)^2))/(sqrt((V(1,3)-V(1,1))^2 + (V(2,3)-V(2,1))^2)));
                       distance2 = ((sqrt((V(1,1)-x)^2 + (V(2,1)-y)^2))/(sqrt((V(1,3)-V(1,1))^2 + (V(2,3)-V(2,1))^2)));
                       R = (1-distance1)*CV(3,1) + (1-distance2)*CV(1,1);
                       G = (1-distance1)*CV(3,2) + (1-distance2)*CV(1,2);
                       B = (1-distance1)*CV(3,3) + (1-distance2)*CV(1,3);
                    end
                     %Elegxw an to shmeio htan aspro h an exei hdh
                     %vaftei.Auto ginetai wste na mhn vapsw xana tis koines
                     %pleures diaforwn trigwnwn.Gia thn prwth fora pou tha
                     %kalestei h TriPaint den xreiazetai alla stis
                     %upoloipes einai aparaithtos elegxos.      
                        if X(x,y,1) == 1 && X(x,y,2)==1 && X(x,y,3) == 1
                         %Thetw sta shmeia pou vrisketai h epanalhpsh
                         %tis R,G,B times pou exoume upologisei.
                         X(x,y,1) = R;
                         X(x,y,2) = G;
                         X(x,y,3) = B;
                         %Apothikeuw tis suntetagmenes pou vapsame giati
                         %tha tis xreiastw gia na plhrwsw me xrwma ta
                         %endiamesa tous pixel.
                         savedCoords(c,1) = x;
                         savedCoords(c,2) = y; 
                        else
                          %exw else wste na swsw parola auta tis
                          %suntetagmenes akoma kai an einai vamena wste na
                          %ginei swsta h plhrwsh.
                          savedCoords(c,1) = x;
                          savedCoords(c,2) = y;
                        end
                 
                 end
                 
                 
            
            end
        end
        
    end    
    %Edw pera arxizei to gemisma anamesa sta trexon oriaka shmeia.
    cross_count = 0;%Arxikopoiw thn metavlhth pou mas leei poso fores exoume temnei se kapoia pleura
    %Pali skanarw ola ta dunata x.
     for x = xmin:1:xmax
         %Omoiws skanarw olh thn lista energwn oriakwn shmeiwn
         for p = 1:1:to(1)
            if x == round(LAOP(p,1))%elegxoume an to x einai iso me to x kapoiou apo ta energa oriaka shmeia 
                cross_count = cross_count + 1;%An einai shmainei oti exoume temnei se kapoia pleura alla to cross_count au3anei.
            end
            if (x == V(1,1) && y == V(2,1)) || (x == V(1,2) && y == V(2,2)) || (x == V(1,3) && y == V(2,3))%Elegxw an prokeitai gia korufh.An einai korufh thelw na isxuei o isxurismos oti otan petuxainw se korufh o arithmos menei zugos an htan zugos h an htan perittos paramenei perittos.
                     cross_count = cross_count + 1;       
            end
            if X(x,y,1) == 1 && X(x,y,2)==1 && X(x,y,3) == 1%elegxw an einai vammeno h oxi gia ton idio logo pou exei hdh anaferthei.
            if mod(cross_count,2) ~= 0%elegxw an einai perittos wste na vapsw alliws na mhn kanei tpt.
                %Vriskw thn apostash tou shmeiou apo ta oriaka shmeia wste
                %na kanw grammikh paremvolh.
                distance1 = ((sqrt((savedCoords(1,1) - x)^2 + (savedCoords(1,2) - y)^2))/(sqrt((savedCoords(2,1) - savedCoords(1,1))^2 +(savedCoords(2,2) - savedCoords(1,2))^2)));
                distance2 = ((sqrt((savedCoords(2,1) - x)^2 + (savedCoords(2,2) - y)^2))/(sqrt((savedCoords(2,1) - savedCoords(1,1))^2 +(savedCoords(2,2) - savedCoords(1,2))^2)));
                %Vriskw tis times R,G,B wste na vapsoume to sugkekrimeno
                %pixel me (x,y) suntetagmenes
                R = (1-distance1)*X(savedCoords(1,1),savedCoords(1,2),1) + (1-distance2)*X(savedCoords(2,1),savedCoords(2,2),1);
                G = (1-distance1)*X(savedCoords(1,1),savedCoords(1,2),2) + (1-distance2)*X(savedCoords(2,1),savedCoords(2,2),2);
                B = (1-distance1)*X(savedCoords(1,1),savedCoords(1,2),3) + (1-distance2)*X(savedCoords(2,1),savedCoords(2,2),3);
                %vafw to trexon pixel.
                X(x,y,1) = R;
                X(x,y,2) = G;
                X(x,y,3) = B;
            end
            end
            
         end
         
    end
    %edw teleiwnei h diadikasia gemismatos
   
    %Edw enhmerwnoume anadromika thn lista energwn akmwn
    %edw prosthetoume autes gia tis opoies isxuei ykmin = y + 1
    for k = 1:1:dim(2)
        if ykmin(k) == y + 1
            LAL(countA) = k;
            countA = countA + 1;
        end
        %edw exairoume tis pleures gia tis opoies isxuei ykmax = y
        if ykmax(k) == y
            for s = 1:1:countA-1
                if LAL(s) == k
                    delete_element = s;%psaxnw to stoixeio tou pinaka pou antistoixei sthn pleura poy thelw na diagrapsw
                end
            end
            countex = countex + 1;%Auxanoume ton metrhth efoson vrethei pleura pou tha exairethei
            excludedLine(countex) = LAL(delete_element);%Vlepoume poia pleura theloume na diagrafei
            LAL(delete_element) = [];%thetw to stoixeio poy thelw iso me to keno 
            countA = countA - 1;%meiwnw ton metrhth pou mas dinei to plithos twn energwn pleurwn sthn lista
        end
    end
    
    
    
    %Edw enhmerwnoume anadromika thn lista twn energwn oriakwn shmeiwn
    
    %Arxikopoiw to pinaka holdy pou tha swthoyn se auto oi theseis pou
    %theloume na diagrapsoume
    holdy(1) = -1;
    holdy(2) = -1;
    %arxikopoiw mia metavlhth flag gia na xrhsimopoihthei gia elegxo
    flagy = 0;
    
    %Prostithontai oi xamhloteres korufes me tetagmenh ymin(k) = y + 1
     for k = 1:1:dim(2)
        if ykmin(k) == y+1
            LAOP(countO,1) = V(1,identity(k));
            LAOP(countO,2) = ykmin(k);
            LAOP(countO,3) = k;
            countO = countO + 1;
        end
    end
    
    
    %Ålegxw ola ta shmeia tomhs wste na diagrapsw auta pou dn anhkoun pleon
    to = size(LAOP);
    for i = 1:1:to(1)
        for j = 1:1:countex %diatrexw mexri to countex pou to eixame orisei ws metrhth twn pleurwn pou tha exairethoun
            %Elegxw an to ykmax ths exairoumenhs pleuras einai iso me to
            %trexon y kathws kai ama einai iso me kapoio oriako shmeio kai
            %ama h exairoumenh pleura einai h idia me thn pleura pou
            %antistoixei sto oriako shmeio.
            if ykmax(excludedLine(j)) == y && ykmax(excludedLine(j)) == LAOP(i,2) && excludedLine(j) == LAOP(i,3)
                holdy(countDelete + 1) = i; %thetw sthn metavlhth holdy to x ths theshs pou theloume na diagrapsoume
                flagy = 1;
                countDelete = countDelete + 1;
            end
        end
    end
    %elegxw an to flagy egine 1 kai an h metavlhth holdy einai diaforh tou
    %-1 tote shmainei pws eixe mpei mesa sthn prohgoumenh if kai prepei na
    %diagrafei to stoixeio
     if flagy == 1 && holdy(2) ~= -1
        LAOP(holdy(2),:) = [];
    end
    if flagy == 1 && holdy(1) ~= -1
        LAOP(holdy(1),:) = [];
    end
   
    countO = countO - countDelete;%meiwnei ton metrhth plithous ths LAOP kata 1 efoson diagrapsame kapoio stoixeio ths
    countDelete = 0;%arxikopoiei thn metavlhth gia na mhn uparxei lathos sthn epomenh epanalhpsh
    excludedLine = zeros(1);%omoiws opws sthn countDelete
    
    %prosthetw sta upoloipa energa oriaka shmeia ton oro 1/mk
    to = size(LAOP);
    for i = 1:1:to(1)
       if y == LAOP(i,2) %elegxw an to y einai iso me to y tou energou oriakou shmeiou
           LAOP(i,2) = y + 1; %Auxaneis to y tou kata 1 efoson tha mpoyme sthn epomenh epanlhpsh ara tha skanaroume thn epomenh grammh
              if m(LAOP(i,3)) == inf || m(LAOP(i,3)) == -inf %elegxw ama h klish apeirizetai
                 LAOP(i,1) = LAOP(i,1); % ama apeiristei tote to x tha meinei idio kai dn tha prostethei o oros 1/mk
              else
                 LAOP(i,1) = LAOP(i,1) + 1/(m(LAOP(i,3))); %efoson den apeirizetai prosthetoume ton oro 1/mk
              end        
       end
    end
end
f = X; %h TriPaint epistrefei ton pinaka X molis teleiwsei.




