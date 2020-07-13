/* 
 This program usage is for educational and research purposes only.
 Author: Kyprianidis Alexandros-Charalampos
 Email: alexkypr.ece@gmail.com
 Last Changed: 29.05.2017 
 */
 
#include <cstddef>
#include <ctime>
#include <iostream>
#include <stdlib.h>
#ifndef    OPENCV_3
#include <opencv/cv.h>
#include <opencv/highgui.h>
#else
#include "opencv2/opencv.hpp"
#include "opencv2/features2d.hpp"
#include "opencv2/xfeatures2d.hpp"
#include "opencv2/xfeatures2d/cuda.hpp"
#include "opencv2/imgcodecs.hpp"
#include "opencv2/highgui.hpp"
#include "opencv2/imgproc.hpp"
#include "opencv2/video/tracking.hpp"

#endif  /* OPENCV_3 */
#include <libvibe++/ViBe.h>
#include <libvibe++/distances/Manhattan.h>
#include <libvibe++/system/types.h>

using namespace std;
using namespace cv;
using namespace ViBe;
static unsigned int counter_identity = 0;


static int tracked_vehicles = 0;
static int occluded_vehicles =0;
static int flagTrue = 0;

class Vehicle{
  unsigned int identity;
  unsigned int occludedId1;
  unsigned int occludedId2;
  unsigned int indice;
  unsigned int number;
  Mat image;
  Scalar rectColor;
  Point Br;
  Point Tl;
  Point center;
  Point centerFeature;
  Point du;
  Rect boundRect;
  bool tracked;
  bool occluded;

  Mat descriptorSIFT;
  vector<KeyPoint> KeypointsSIFT;
  vector<KeyPoint> KeypointsCombined;

  vector<DMatch> good_matchesSIFT;
  vector<DMatch> good_matches;

public:
  Vehicle(){tracked = false;occluded = false;};
  Vehicle(const Vehicle &obj){identity = obj.identity;image = obj.image.clone();boundRect = obj.boundRect;rectColor = obj.rectColor;center = obj.center;Br = obj.Br;Tl = obj.Tl;descriptorSIFT = obj.descriptorSIFT.clone();KeypointsSIFT = obj.KeypointsSIFT;KeypointsCombined = obj.KeypointsCombined;tracked = obj.tracked;occluded = obj.occluded;du = obj.du;occludedId1 = obj.occludedId1;occludedId2 = obj.occludedId2;good_matchesSIFT = obj.good_matchesSIFT;good_matches = obj.good_matches;number = obj.number;}
  ~Vehicle(){};
  void begIdentity(){identity = ++counter_identity;}
  void setId(unsigned int id){identity = id;}
  void setNumber(unsigned int num){number = num;}
  void setOccludedId(unsigned int id1, unsigned int id2){occludedId1 = id1; occludedId2 = id2;}
  void setBoundRect(Rect bound){boundRect = bound;}
  void setRectColor(Scalar Col){rectColor = Col;}
  void setImage(Mat im){image = im.clone();}
  void setCenter(int x,int y,int width,int height){center = Point(x + width/2,y+height/2);}
  void setCenter(Point k){center = k;}
  void setCenterFeature(Point m){centerFeature = m;}
  void setDu(Point newe,Point old){du.x = newe.x - old.x;du.y = newe.y - old.y;}
  void setDimensions(Point T,Point B){Tl = T;Br = B;}
  void setDescriptorSIFT(Mat des){descriptorSIFT = des.clone();}
  void setKeypointsSIFT(vector<KeyPoint> KP){KeypointsSIFT = KP;}
  void setKeypointsCombined(vector<KeyPoint> Combo){KeypointsCombined = Combo;}
  void setGoodMatches(vector<DMatch> gm){good_matches = gm;}
  void setGoodMatchesSIFT(vector<DMatch> gmSIFT){good_matchesSIFT = gmSIFT;}
  void setIndice(unsigned int p){indice = p;}
  void isTracked(bool x){tracked = x;}
  void isOccluded(bool y){occluded = y;}

  unsigned int getIdentity(){return identity;}
  unsigned int getOccludedIdentity1(){return occludedId1;}
  unsigned int getOccludedIdentity2(){return occludedId2;}
  unsigned int getNumber(){return number;}
  unsigned int getIndice(){return indice;}
  Rect getBoundRect(){return boundRect;}
  Scalar getRectColor(){return rectColor;}
  Mat getDescriptorSIFT(){return descriptorSIFT;}
  vector<KeyPoint> getKeypointsSIFT(){return KeypointsSIFT;} 
  vector<KeyPoint> getKeypointsCombined(){return KeypointsCombined;} 
  vector<DMatch> getGoodMatches(){return good_matches;}
  vector<DMatch> getGoodMatchesSIFT(){return good_matchesSIFT;}
  Point getTl(){return Tl;}
  Point getBr(){return Br;}
  Mat getImage(){return image;}
  Point getCenter(){return center;}
  Point getCenterFeature(){return centerFeature;}
  Point getDu(){return du;}
  bool getTracked(){return tracked;}
  bool getOccluded(){return occluded;}
};

vector<vector<Point>> morphologicalOps(Mat map,vector<vector<Point>> con, Mat drawing);
vector<Vehicle> setValuesNew(vector<Rect> boundRect, vector<vector<Point>> contours, Mat frame, vector<Vehicle> newDetected, vector<Mat> *newCroppedImages,RNG rng);
void setValuesNewTracked(Vehicle *newDetected, Vehicle oldDetected, bool occluded);
int findCorrelatedOccluded(vector<Vehicle> Occluded, Vehicle newDetected, Mat descriptorSIFT1);

int main(int argc, char** argv) {
  
  if (argc != 2) {
    cerr << "A video file must be given as an argument to the program!";
    cerr << endl;

    return EXIT_FAILURE;
  }

  /* Parameterization of ViBe. */
  typedef ViBeSequential<3, Manhattan<3> >                                ViBe;
  /* Random seed. */
  srand(time(NULL));
  RNG rng(12345);
  cv::VideoCapture decoder(argv[1]);
  cv::Mat frame;
  vector<vector<Point>> contours;
  int32_t height = decoder.get(CV_CAP_PROP_FRAME_HEIGHT);
  int32_t width  = decoder.get(CV_CAP_PROP_FRAME_WIDTH);
  ViBe* vibe = NULL;
  cv::Mat segmentationMap(height, width, CV_8UC1);
  bool firstFrame = true;
  /*SIFT INITIALIZATION*/
  cv::Ptr<Feature2D> detectorSIFT = xfeatures2d::SIFT::create();
  BFMatcher matcherSIFT;
  
  std::vector<std::vector< DMatch>> matchesSIFT;
  std::vector<std::vector< DMatch>> matches;  
  vector<Mat> newdescriptorSIFT;
  vector<Mat> newCroppedImages;
 
  vector<vector<KeyPoint>> newKeypointsSIFT;
  

  vector<Vehicle> newDetected;
  vector<Vehicle> oldDetected;
  
  vector<Vehicle> Tracked(20);
  vector<Vehicle> Occluded(20);
  
  while (decoder.read(frame)) {
    if (firstFrame) {
      /* Instantiation of ViBe. */
      vibe = new ViBe(height, width, frame.data);
      firstFrame = false;
    }
   
   if(counter_identity > 100){
  	counter_identity = 0;
  }
  
 
    /* Segmentation and update. */
    vibe->segmentation(frame.data, segmentationMap.data);
    vibe->update(frame.data, segmentationMap.data);
    
//SETTING ROI It's used to demonstrate better check at older version ViBe_8UC3demonstration file
    // line(frame,Point(0,0.4*frame.rows),Point(frame.cols,0.4*frame.rows),Scalar(0,0,0),3);
     /*
     int alpha = 1;
     int beta = -60;
     for( int y = 0; y < 0.4*frame.rows; y++ ) {
        for( int x = 0; x < frame.cols; x++ ) {
            for( int c = 0; c < 3; c++ ) {
                frame.at<Vec3b>(y,x)[c] =
                  saturate_cast<uchar>( alpha*( frame.at<Vec3b>(y,x)[c] ) + beta );
            }
        }
    }
*/
    // Mat roi = frame(Rect(0,0.4*frame.rows,frame.cols,0.6*frame.rows)).clone();
     //Mat blackroi = segmentationMap(Rect(0,0.4*frame.rows,frame.cols,0.6*frame.rows)).clone();
//END SETTING

    cv::Mat drawing = Mat::zeros(segmentationMap.rows + 2,segmentationMap.cols + 2, CV_8UC1);
    //Function doing all the morphological operations to find the blobs
    contours = morphologicalOps(segmentationMap,contours,drawing);
    vector<Rect> boundRect( contours.size() );
    newDetected.resize(contours.size());
    //Function setting values to new Detected blobs
    newDetected = setValuesNew(boundRect, contours, frame, newDetected, &newCroppedImages,rng);
    //Computation of SIFT Characteristics of the detected objects in the frame t
    detectorSIFT->detect(newCroppedImages,newKeypointsSIFT);
    detectorSIFT->compute(newCroppedImages,newKeypointsSIFT,newdescriptorSIFT);
    Mat img_matches;
    std::vector<DMatch> good_matchesSIFT;
    float Rate,maxRate = 0;
    unsigned int keepj = 0,keyj1, keyj2, keyi, OnetoNj;
    bool intersects = 0,OnetoN;
    int countFullIntersects;
    vector<int> countOnetoN(oldDetected.size(),0);
    vector<unsigned int> OnetoNi1(oldDetected.size(),1000);
    vector<unsigned int> OnetoNi2(oldDetected.size(),1000);

   

    for (unsigned int i = 0; i < newDetected.size();i++){
      //Set the keypoints and descriptors to the new detected blobs
      newDetected[i].setKeypointsSIFT(newKeypointsSIFT[i]);
      newDetected[i].setDescriptorSIFT(newdescriptorSIFT[i].clone());
      keyi = 1000;
      keyj1 = 1000;
      keyj2 = 1000;
      countFullIntersects = 0;
      OnetoNj = 1000;
      bool occluded = 0;
      //Find the Rect of the new blobs and check if the area is big enough and if the overlap is big enough to detect occlusion
      Rect iRect(newDetected[i].getTl().x,newDetected[i].getTl().y,newDetected[i].getBoundRect().width,newDetected[i].getBoundRect().height);
        for (unsigned int j = 0; j < oldDetected.size();j++){   
          intersects = 0;
          OnetoN = 0;
          Rect jRect(oldDetected[j].getTl().x,oldDetected[j].getTl().y,oldDetected[j].getBoundRect().width,oldDetected[j].getBoundRect().height);
          if(jRect.area() > 250 && iRect.area() > jRect.area()){
            //2->1 occlusion
            intersects = ((iRect & jRect).area() >= 0.9*jRect.area());
          }
          
          if(iRect.area()>200 && jRect.area() > iRect.area()){
            //1->2 occlusion
            OnetoN = ((iRect & jRect).area() >= 0.4*iRect.area());
          }
          
          Mat tempdescriptorSIFT;
          Mat descriptorSIFT;
          descriptorSIFT = newDetected[i].getDescriptorSIFT().clone();
          tempdescriptorSIFT = oldDetected[j].getDescriptorSIFT().clone();
     	  
/*  Show Keypoints snippet code
     	  Mat playing = Mat::zeros(newCroppedImages[i].rows,newCroppedImages[i].cols,CV_8UC3);
     	  drawKeypoints(newCroppedImages[i],newDetected[i].getKeypointsSIFT(),playing);
     	  imshow("Keypoints",playing);
     	  waitKey(1);
     	  getchar();
 */
          //find matches
          if(newDetected[i].getKeypointsSIFT().size() != 0 && oldDetected[j].getKeypointsSIFT().size() != 0){
            matcherSIFT.knnMatch(descriptorSIFT,tempdescriptorSIFT,matchesSIFT,2);
          }
          
          /*Filter matches -> good matches */
          for(unsigned int z = 0; z < matchesSIFT.size(); z++){
              const float ratio = 0.8; // it can be tuned
              if(matchesSIFT[z][0].distance < ratio*matchesSIFT[z][1].distance){
                good_matchesSIFT.push_back(matchesSIFT[z][0]);
              }
          }
          /*END-filter matches -> good matches*/

          newDetected[i].setGoodMatchesSIFT(good_matchesSIFT);
          newDetected[i].setGoodMatches(good_matchesSIFT);
          //Save the combined keypoints 
          vector<KeyPoint> combinedNewKeypoints = newDetected[i].getKeypointsSIFT();
          vector<KeyPoint> combinedOldKeypoints = oldDetected[j].getKeypointsCombined();
          newDetected[i].setKeypointsCombined(combinedNewKeypoints);
		  /* Show matching keypoints snippet code
		  Mat matGood = Mat::zeros(frame.rows,frame.cols,CV_8UC3);
		  Mat matNorm = Mat::zeros(frame.rows,frame.cols,CV_8UC3);
		  drawMatches(newCroppedImages[i],newDetected[i].getKeypointsSIFT(),oldDetected[j].getImage(),oldDetected[j].getKeypointsSIFT(),good_matchesSIFT,matGood);
          drawMatches(newCroppedImages[i],newDetected[i].getKeypointsSIFT(),oldDetected[j].getImage(),oldDetected[j].getKeypointsSIFT(),matchesSIFT,matNorm);
          imshow("Good matches",matGood);
          waitKey(100);
          getchar();
          imshow("Normal matches",matNorm);
          waitKey(100);
          getchar();
*/
          //Check whether the #matches are enough for calculating Rate
          if(good_matchesSIFT.size() > 4 && combinedNewKeypoints.size() > 0 && combinedOldKeypoints.size() > 0){
          //Calculate Rate
            Rate = (float)good_matchesSIFT.size()/(float)max(combinedNewKeypoints.size(),combinedOldKeypoints.size());
            //Detect 1->2 state
            if(OnetoN && Rate >= 0.07  && Rate <= 0.9 && oldDetected[j].getOccluded()){
              countOnetoN[j]++;
              if(countOnetoN[j] == 1 && OnetoNi1[j] == 1000){
                OnetoNi1[j] = i;
              }
              if(countOnetoN[j] == 2 && flagTrue > 0 && OnetoNi1[j] != 1000){
                OnetoNi2[j] = i;
                OnetoNj = j;
                flagTrue--;
              }
            }
            //Detect 2->1 state
          if(intersects && Rate >= 0.1 && Rate <= 0.9 && oldDetected[j].getTracked()){
            countFullIntersects++;
            if(countFullIntersects == 1 && keyj1 == 1000){
             keyj1 = j;
             
            }
            if(countFullIntersects == 2 && keyj1 != 1000){
              keyj2 = j;
              keyi = i;
            }
          }
         
          //Check if we have the maximum Rate in order to keep it as the most suited to match
            if(Rate >= 0.26 && Rate < 1 && Rate > maxRate){
                keepj = j;
                maxRate = Rate;  
            }
          }

         matchesSIFT.clear();
         good_matchesSIFT.clear();
        }

        //Check whether there is newDetected Vehicle to be tracked
        if(maxRate != 0){
           //Actions on transition 2 -> 1 
          if((keyj1 == keepj || keyj2 == keepj) && (keyj1 != 1000 && keyj2 != 1000) && countFullIntersects == 2){
              //Code snippet to locate occlusion start
              //cout<<"STOP"<<" i: "<<i<<" j: "<<keepj<<" keyj1: "<<keyj1<<" keyj2: "<<keyj2<<endl;
              occluded = 1;
              occluded_vehicles+=2;
              Occluded.resize(occluded_vehicles);
              //if occluded set to occluded the oldDetected Vehicles
              Occluded[occluded_vehicles - 2] = oldDetected[keyj1];
              Occluded[occluded_vehicles - 1] = oldDetected[keyj2];
              //when we have the transition from 2 -> 1
              //the detected is the merged blob
              newDetected[i].setOccludedId(Occluded[occluded_vehicles - 2].getIdentity(),Occluded[occluded_vehicles - 1].getIdentity());
              newDetected[i].setNumber(2);
              //cout<<"Occluded id 1 "<<newDetected[i].getOccludedIdentity1()<<" Occluded id 2"<<newDetected[i].getOccludedIdentity2()<<endl;
              flagTrue++;
          }
          //END Detected Transition 2->1

          //Set new Detected to Tracked & set more values of new Detected with setValuesNewTracked
          ++tracked_vehicles;
          Tracked.resize(tracked_vehicles);
          setValuesNewTracked(&newDetected[i], oldDetected[keepj], occluded);
          Tracked[tracked_vehicles - 1] = newDetected[i];
          Tracked[tracked_vehicles - 1].setIndice(i); 
        }
       
        //Actions on transition 1 -> 2
        if(OnetoNj != 1000 && occluded_vehicles > 0){//not occluded anymore
          Mat descriptorSIFT1;
          descriptorSIFT1 = newDetected[OnetoNi1[OnetoNj]].getDescriptorSIFT().clone();
          //Find the correlated newDetected with the occluded vehicles to transit from 1 to 2
          //cout<<"Occluded Vehicles "<<occluded_vehicles<<endl;
          int keyL = findCorrelatedOccluded(Occluded, newDetected[OnetoNi1[OnetoNj]], descriptorSIFT1);
          //Evala oti ama einai p.x to zeugari 0-1 kai vrw oti einai to 1 profanws to prohgoymeno einai to prwto
          //i saw that if the pair is the (0,1) then if the correlated object is 1(keyL = 1) then keyL2 = 0.
          //The same logic applies if the correlated object is 0(keyL = 0) etc..
          int keyL1 = keyL;
          int keyL2;
          if(keyL % 2 == 1){
            keyL2 = keyL - 1;
          }else{
            keyL2 = keyL + 1;
          }
          //cout<<"keyL1 "<<keyL1<<" keyL2 "<<keyL2<<endl;
          newDetected[OnetoNi1[OnetoNj]].setId(Occluded[keyL1].getIdentity());
          newDetected[OnetoNi1[OnetoNj]].setRectColor(Occluded[keyL1].getRectColor());
          newDetected[OnetoNi1[OnetoNj]].isOccluded(false);
          newDetected[OnetoNi1[OnetoNj]].setNumber(1);
          newDetected[OnetoNi2[OnetoNj]].setId(Occluded[keyL2].getIdentity());
          newDetected[OnetoNi2[OnetoNj]].setRectColor(Occluded[keyL2].getRectColor());
          newDetected[OnetoNi2[OnetoNj]].isOccluded(false);
          newDetected[OnetoNi2[OnetoNj]].setNumber(1);
           for(int r = 0; r < tracked_vehicles - 1; r++){
              if(Tracked[r].getIdentity() == newDetected[OnetoNi1[OnetoNj]].getIdentity()){
                Tracked[r] = newDetected[OnetoNi1[OnetoNj]];
                Tracked[r].setIndice(OnetoNi1[OnetoNj]);
              }else if(Tracked[r].getIdentity() == newDetected[OnetoNi2[OnetoNj]].getIdentity()){
              	Tracked[r] = newDetected[OnetoNi2[OnetoNj]];
                Tracked[r].setIndice(OnetoNi2[OnetoNj]);
              }
          }
          //Found which occluded corresponds to the newDetected Vehicles
          //Resize occluded vector because we discard 2 of them
           vector<Vehicle> Occludedtemp;
           for(int i = 0; i < Occluded.size(); i++ ){
              if(i == keyL1){
                Occludedtemp.push_back(Occluded[keyL1]);
              }else if(i == keyL2){
                Occludedtemp.push_back(Occluded[keyL2]);
              }
            }
          Occluded.clear();
          Occluded = Occludedtemp;
          Occludedtemp.clear();
          occluded_vehicles -= 2;
          Occluded.resize(occluded_vehicles);
          //Code snippet to locate occlusion ends
          //cout<<"STOP 2 STOP"<<endl;
          //cout<<" i: "<<i<<" j: "<<j<<" OnetoNi1 "<<OnetoNi1[j]<<" OnetoNi2: "<<OnetoNi2[j]<<endl;
          //getchar();
        }
        maxRate = 0;//Re-initiallization
    }
    
  //Drawing Rectangles,Id and number of vehicles
  Mat drawRect = Mat::zeros( drawing.size(), CV_8UC3 ); 
 for (unsigned int i = 0; i < Tracked.size(); ++i){
      unsigned int j = Tracked[i].getIndice();
      if(boundRect.size() > 0){
        drawContours( drawRect, contours, j, Tracked[i].getRectColor(), 1, 8, vector<Vec4i>(), 0, Point() );
        rectangle( frame, Tracked[i].getTl(), Tracked[i].getBr(), Tracked[i].getRectColor(), 2, 8, 0 );
      	stringstream ss;
      	if(Tracked[i].getOccluded()){
      		ss << "#"<<Tracked[i].getNumber()<<" ID1: "<<Tracked[i].getOccludedIdentity1()<<" ID2: "<<Tracked[i].getOccludedIdentity2();
      	}else{
      		ss << "#"<<Tracked[i].getNumber()<<" ID:"<<Tracked[i].getIdentity();
      	}
      	string str = ss.str();
      	putText(frame,str,Tracked[i].getTl(), FONT_HERSHEY_SIMPLEX,1,Tracked[i].getRectColor(),3);
      }
    }
    //END Drawing 

    /* Update new to old */
    oldDetected.clear();
    oldDetected.resize(newDetected.size());
    for(unsigned int i = 0;i < newDetected.size();i++){
      oldDetected[i] = newDetected[i];
    }
    /* Release space */
    newDetected.clear();
    newdescriptorSIFT.clear();
    newCroppedImages.clear();
    newKeypointsSIFT.clear();
    Tracked.resize(0);
    tracked_vehicles = 0;

    /* Show Results */
    imshow("Input video", frame);
    imshow("detected_edges", drawing);
    waitKey(1);
    //getchar();
    /* END Show Results */
    
  }

  delete vibe;
  cvDestroyAllWindows();
  decoder.release();
  return EXIT_SUCCESS;
}

/* Morphological Operations to detect objects */
 vector<vector<Point>> morphologicalOps(Mat map,vector<vector<Point>> con,Mat drawing){

  cv::Mat seg,closing,detected_edges;
  vector<Vec4i> hierarchy;
  int lowThreshold = 100,morph_size = 5,morph_size2 = 1,ratio = 3, kernel_size = 5;
  double min_area = 100;
  cv::Mat element = getStructuringElement( MORPH_RECT, Size( 2*morph_size + 1, 2*morph_size+1 ), Point( morph_size, morph_size ) );
  cv::Mat element2 = getStructuringElement( MORPH_RECT, Size( 2*morph_size2 + 1, 2*morph_size2+1 ), Point( morph_size2, morph_size2 ) );
  vector<vector<Point>> contoursTemp;
  //Post-processing: 5x5 median filter to reduce noise 
  medianBlur(map, map, 5);
  cv::copyMakeBorder(map,seg,1,1,1,1,BORDER_CONSTANT,Scalar(0,0,0));//Create border in order to find contour at edges  
  Canny(seg, detected_edges, lowThreshold,lowThreshold*ratio,kernel_size);
  //Closing edges
  morphologyEx(detected_edges,closing,MORPH_CLOSE,element);
  dilate( closing, closing, element2 );
  erode( closing, closing, element2 );
  //Finding Contours
  findContours(closing, con, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE,Point(-1, -1) );//RETR_EXTERNAL because we want only outer contour
  ///Trying to Discard very small noise
  for(unsigned int i = 0; i < con.size(); i++ ){
     if(!(contourArea(con[i]) < min_area)){
       contoursTemp.push_back(con[i]);
     }
  }
    con.clear();
    con = contoursTemp;
    contoursTemp.clear();

    //Discard border
    drawContours(drawing, con,-1,Scalar(255,255,255),CV_FILLED);
    Rect r(2, 2, seg.cols - 2, seg.rows - 2);
    drawing = drawing(r); 
    con.clear();
    //Search again for contours after removing Border
    findContours(drawing, con, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE,Point(0, 0) );//RETR_EXTERNAL because we want only outer contour
    for(unsigned int i = 0; i < con.size(); i++ ){
      if(!(contourArea(con[i]) < min_area)){
        contoursTemp.push_back(con[i]);
      }
    }
    con.clear();
    con = contoursTemp;
    contoursTemp.clear();
    //Return contours of detected objects
    return con;
}



  vector<Vehicle> setValuesNew(vector<Rect> boundRect, vector<vector<Point>> contours, Mat frame, vector<Vehicle> newDetected, vector<Mat> *newCroppedImages, RNG rng){

    cv::Mat cropImage(frame.rows, frame.cols, CV_8UC3);
    cv::Mat mask = Mat::zeros(frame.rows,frame.cols, CV_8UC1);
    //Set ID,COLOR,CROPPEDIMAGE,TL,BR,CENTER
    for (unsigned int i = 0; i < contours.size(); ++i){
      boundRect[i] = boundingRect(Mat(contours[i]));
      //Crop the selected ROI
      rectangle( mask, boundRect[i].tl(), boundRect[i].br(), Scalar(255), -1);
      frame.copyTo(cropImage,mask);
      cropImage = cropImage(boundRect[i]).clone();
      //Set some useful information to the new detected blob
      newDetected[i].begIdentity();
      newDetected[i].setBoundRect(boundRect[i]);
      newDetected[i].setImage(cropImage.clone());
      newDetected[i].setRectColor(Scalar( rand()%255, rand()%255, rand()%255 ));
      newDetected[i].setDimensions(boundRect[i].tl(),boundRect[i].br());
      newDetected[i].setCenter(boundRect[i].x,boundRect[i].y,boundRect[i].width,boundRect[i].height);
      newDetected[i].setNumber(1);
      newCroppedImages->push_back(cropImage.clone());

    }
    return newDetected;   
  }

void setValuesNewTracked(Vehicle *newDetected, Vehicle oldDetected, bool occluded){
  //Set values to newDetected because it's Tracked to keep the useful info of the oldDetected
        newDetected->setId(oldDetected.getIdentity());
        newDetected->setRectColor(oldDetected.getRectColor());
        newDetected->isOccluded(oldDetected.getOccluded());
        newDetected->isTracked(true);
        newDetected->setNumber(oldDetected.getNumber());
        newDetected->setDu(newDetected->getCenter(),oldDetected.getCenter());
        if(occluded){
          newDetected->setNumber(2);
          newDetected->isOccluded(true);
        }else{
          newDetected->setOccludedId(oldDetected.getOccludedIdentity1(),oldDetected.getOccludedIdentity2());
        }
}

int findCorrelatedOccluded(vector<Vehicle> Occluded, Vehicle newDetected,Mat descriptorSIFT1){
  //Find which Occluded Vehicle matches with the New Detected Object
  float maxRateL = 0;
  int keyL = -1;
  //Scan all of occluded vehicles
  for(int l = 0; l < occluded_vehicles; ++l){
             float RateL;
              Mat tempdescriptorSIFT1;
              BFMatcher matcherSIFT1;
              std::vector<std::vector< DMatch>> matchesSIFT1;
              std::vector<DMatch> good_matchesSIFT1;
              tempdescriptorSIFT1 = Occluded[l].getDescriptorSIFT().clone();
              //Find matches
              if(newDetected.getKeypointsSIFT().size() != 0 && Occluded[l].getKeypointsSIFT().size() != 0){
                matcherSIFT1.knnMatch(descriptorSIFT1,tempdescriptorSIFT1,matchesSIFT1,2);
              }
              //Filter the matches
              for(unsigned int z = 0; z < matchesSIFT1.size(); z++){
               const float ratio = 0.8; // it can be tuned
                if(matchesSIFT1[z][0].distance < ratio*matchesSIFT1[z][1].distance){
                  good_matchesSIFT1.push_back(matchesSIFT1[z][0]);
                }
              }
              vector<KeyPoint> tempKeypointsCombined;
              vector<KeyPoint> tempOccluded;
              tempKeypointsCombined = newDetected.getKeypointsCombined();
              tempOccluded = Occluded[l].getKeypointsCombined();
              //Calculate Rate
              RateL = (float)good_matchesSIFT1.size()/(float)max(tempKeypointsCombined.size(),tempOccluded.size());
              //Find max Rate to see the best match
              if(maxRateL < RateL){
                maxRateL = RateL;
                keyL = l;
              }  
             matchesSIFT1.clear();
             good_matchesSIFT1.clear();
          } 
          //return the index of best match of occluded
          return keyL;
}
