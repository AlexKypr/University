function P = colordemo() %Function that shows an image based on the data that has been given
 Q = [1 2 3;2 3 5;3 4 5];%Array that consists of three numbers per line. Every line is the index of the array T and CV in order to form a triangle.
 T = [10 30;290 40;20 180;130 270;380 190];%Array that consists of the coordinates of every corner of the triangles.
 CV = [0.8 0.2 0.1;1 0 0;0.4 0.8 0.9;0 0 1;0.2 0.5 0.6];%Matrix that consists of color (R,G,B) of every corner of the triangles.
 M = 300;%Dimension X
 N = 400;%Dimension Y
 P = Painter(Q,T,CV,M,N);It calls the Painter and returns a MxNx3 array that contain three combined triangles
 imshow(P);%Shows image
end

