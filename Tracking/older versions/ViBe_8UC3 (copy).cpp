/* 
 This program usage is for educational and research purposes only.
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


  //bool matched;
  //bool tracked;
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
//void setCenFeature(Vehicle *newDetected,vector<DMatch> good_matches);
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
  

  vector<Vehicle> newDetected;//THELW SUNEXEIA NA MHDENIZETAI OPOTE VOLEUEI EDW
  vector<Vehicle> oldDetected;
  
  vector<Vehicle> Tracked(20);
  vector<Vehicle> Occluded(20);
  
  while (decoder.read(frame)) {
    if (firstFrame) {
      /* Instantiation of ViBe. */
      vibe = new ViBe(height, width, frame.data);
      firstFrame = false;
    }
    //getchar();
   if(counter_identity > 100){
  	counter_identity = 0;
  }
  
 
 
  //Allocate big bunch of memory from the beginning to decrease computational cost
  //SiftData siftData;
  //InitSiftData(siftData, 25000, true, true);
    /* Segmentation and update. */
    vibe->segmentation(frame.data, segmentationMap.data);
    vibe->update(frame.data, segmentationMap.data);
    
//SETTING ROI
     //line(frame,Point(0,0.35*frame.rows),Point(frame.cols,0.35*frame.rows),Scalar(0,0,0));
     //Rect RectRoi(0,0.35*frame.rows,frame.cols,0.65*frame.rows);
     //Mat roi = frame.clone();
     //roi(RectRoi);
    cv::Mat drawing = Mat::zeros(segmentationMap.rows + 2,segmentationMap.cols + 2, CV_8UC1);
    //Function doing all the morphological operations to find the blobs
    //clock_t begin = clock();
    contours = morphologicalOps(segmentationMap,contours,drawing);
  	//clock_t end = clock();
  	//double elapsed_secs = double(end - begin) / CLOCKS_PER_SEC;
  	//cout<<"Time for morphologicalOps(without Cuda) "<<elapsed_secs<<" s"<<endl;
    /*DONT DELETE THIS CODE*/
    vector<Rect> boundRect( contours.size() );
    newDetected.resize(contours.size());
    //Function setting values to new Detected blobs
    newDetected = setValuesNew(boundRect, contours, frame, newDetected, &newCroppedImages,rng);
    detectorSIFT->detect(newCroppedImages,newKeypointsSIFT);
    detectorSIFT->compute(newCroppedImages,newKeypointsSIFT,newdescriptorSIFT);
    Mat img_matches;
    std::vector<DMatch> good_matchesSIFT;
    //std::vector<DMatch> good_matches;
  

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
      //vector<Rect> OnetoN;
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
     
 
          if(newDetected[i].getKeypointsSIFT().size() != 0 && oldDetected[j].getKeypointsSIFT().size() != 0){
            matcherSIFT.knnMatch(descriptorSIFT,tempdescriptorSIFT,matchesSIFT,2);
          }
          
          /*Find good matches*/
          for(unsigned int z = 0; z < matchesSIFT.size(); z++){
              const float ratio = 0.8; // it can be tuned
              if(matchesSIFT[z][0].distance < ratio*matchesSIFT[z][1].distance){
                good_matchesSIFT.push_back(matchesSIFT[z][0]);
              }
          }
          /*END-find good matches*/
          newDetected[i].setGoodMatchesSIFT(good_matchesSIFT);
          //good_matches = good_matchesSIFT;//1a
          /* calculating the center of the features of the good matches */
          //setCenFeature(&newDetected[i],good_matches);
          newDetected[i].setGoodMatches(good_matchesSIFT);
          //Save the combined keypoints 
          vector<KeyPoint> combinedNewKeypoints = newDetected[i].getKeypointsSIFT();
          vector<KeyPoint> combinedOldKeypoints = oldDetected[j].getKeypointsCombined();
          newDetected[i].setKeypointsCombined(combinedNewKeypoints);

           
          if(good_matchesSIFT.size() > 4 && combinedNewKeypoints.size() > 0 && combinedOldKeypoints.size() > 0){
          
            Rate = (float)good_matchesSIFT.size()/(float)max(combinedNewKeypoints.size(),combinedOldKeypoints.size());
            
            if(OnetoN && Rate >= 0.07  && Rate <= 0.9 && oldDetected[j].getOccluded()){
              //Ama kapoio einai apo 2->1 thelw na swsw ta stoixeia twn 2 new detected ektos apo id kai to color
              countOnetoN[j]++;
              
              if(countOnetoN[j] == 1 && OnetoNi1[j] == 1000){
                OnetoNi1[j] = i;
              }
              //to j einai to palio ara to 1 kai to megalo ta i einai ta kainouria ara tha einai 2
              if(countOnetoN[j] == 2 && flagTrue > 0 && OnetoNi1[j] != 1000){
                OnetoNi2[j] = i;
                OnetoNj = j;
                flagTrue--;
              }
            }
            
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
        // good_matches.clear();

        }

        //Found one to be Tracked
        if(maxRate != 0){
           //Detected transition 2 -> 1
          if((keyj1 == keepj || keyj2 == keepj) && (keyj1 != 1000 && keyj2 != 1000) && countFullIntersects == 2){
              cout<<"STOP"<<" i: "<<i<<" j: "<<keepj<<" keyj1: "<<keyj1<<" keyj2: "<<keyj2<<endl;
              occluded = 1;
              occluded_vehicles+=2;
              Occluded.resize(occluded_vehicles);
               /* if occluded set to occluded the oldDetected Vehicles */
              //when we have the transition from 2 -> 1
              Occluded[occluded_vehicles - 2] = oldDetected[keyj1];
              Occluded[occluded_vehicles - 1] = oldDetected[keyj2];
               //the detected is the merged blob

              newDetected[i].setOccludedId(Occluded[occluded_vehicles - 2].getIdentity(),Occluded[occluded_vehicles - 1].getIdentity());
              newDetected[i].setNumber(2);
              cout<<"Occluded id 1 "<<newDetected[i].getOccludedIdentity1()<<" Occluded id 2"<<newDetected[i].getOccludedIdentity2()<<endl;
              //getchar();
              flagTrue++;
          }
          //END Detected Transition 2->1

          /* Set new Detected to Tracked & set more values of new Detected*/
          ++tracked_vehicles;
          Tracked.resize(tracked_vehicles);
          setValuesNewTracked(&newDetected[i], oldDetected[keepj], occluded);
          Tracked[tracked_vehicles - 1] = newDetected[i];
          Tracked[tracked_vehicles - 1].setIndice(i); 
        }
       
       
        //Transition 1 -> 2
        if(OnetoNj != 1000 && occluded_vehicles > 0){//not occluded anymore

          
          Mat descriptorSIFT1;
  
          descriptorSIFT1 = newDetected[OnetoNi1[OnetoNj]].getDescriptorSIFT().clone();
          //Find the correlated newDetected with the occluded vehicles to transit from 1 to 2
          //cout<<"Occluded Vehicles "<<occluded_vehicles<<endl;
          int keyL = findCorrelatedOccluded(Occluded, newDetected[OnetoNi1[OnetoNj]], descriptorSIFT1);
          
          //Evala oti ama einai p.x to zeugari 0-1 kai vrw oti einai to 1 profanws to prohgoymeno einai to prwto
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
          //Vrhka poia occluded simpiptoun me ta kainouria
          //Resize occluded vector because we discard 2
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
          cout<<"STOP 2 STOP"<<endl;//<<" i: "<<i<<" j: "<<j<<" OnetoNi1 "<<OnetoNi1[j]<<" OnetoNi2: "<<OnetoNi2[j]<<endl;
          //getchar();
        }


        maxRate = 0;
    }
    
  //Drawing Rectangles to Frame 
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
    //END Drawing Rectangles to Frame

    /* Set new to old */
    oldDetected.clear();
    oldDetected.resize(newDetected.size());
    for(unsigned int i = 0;i < newDetected.size();i++){
      oldDetected[i] = newDetected[i];
    }
    newDetected.clear();

    /* Release space */
    newdescriptorSIFT.clear();
    newCroppedImages.clear();
    newKeypointsSIFT.clear();

    Tracked.resize(0);
    tracked_vehicles = 0;

    /* Show Results */
    imshow("Input video", frame);
    imshow("detected_edges", drawing);
    waitKey(1);
    
  }

  delete vibe;
  cvDestroyAllWindows();
  decoder.release();
  return EXIT_SUCCESS;
}


 vector<vector<Point>> morphologicalOps(Mat map,vector<vector<Point>> con,Mat drawing){
  cv::Mat seg,closing,detected_edges;
  vector<Vec4i> hierarchy;
  int lowThreshold = 100,morph_size = 5,morph_size2 = 1,ratio = 3, kernel_size = 5;
  double min_area = 100;
  cv::Mat element = getStructuringElement( MORPH_RECT, Size( 2*morph_size + 1, 2*morph_size+1 ), Point( morph_size, morph_size ) );
  cv::Mat element2 = getStructuringElement( MORPH_RECT, Size( 2*morph_size2 + 1, 2*morph_size2+1 ), Point( morph_size2, morph_size2 ) );
  vector<vector<Point>> contoursTemp;
  // Post-processing: 5x5 median filter to reduce noise 
    medianBlur(map, map, 5);
    cv::copyMakeBorder(map,seg,1,1,1,1,BORDER_CONSTANT,Scalar(0,0,0));//Create border in order to contour better
    
     Canny(seg, detected_edges, lowThreshold,lowThreshold*ratio,kernel_size);
    //Closing edges
    morphologyEx(detected_edges,closing,MORPH_CLOSE,element);
    dilate( closing, closing, element2 );
    erode( closing, closing, element2 );
    //Finding Contours
    findContours(closing, con, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE,Point(-1, -1) );//RETR_EXTERNAL theloume mono outer contour
    ///Trying to Discard very small noise
    for(unsigned int i = 0; i < con.size(); i++ ){
      if(!(contourArea(con[i]) < min_area)){
        contoursTemp.push_back(con[i]);
      }
    }
    con.clear();
    con = contoursTemp;
    contoursTemp.clear();
    // Dialegw meta me tetragwno to kanoniko frame xwris to border
    drawContours(drawing, con,-1,Scalar(255,255,255),CV_FILLED);
    Rect r(2, 2, seg.cols - 2, seg.rows - 2);
    drawing = drawing(r); 
    con.clear();
    //Xanapsaxnw ta contours meta thn diadikasia me to border
    findContours(drawing, con, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE,Point(0, 0) );//RETR_EXTERNAL theloume mono outer contour
    for(unsigned int i = 0; i < con.size(); i++ ){
      if(!(contourArea(con[i]) < min_area)){
        contoursTemp.push_back(con[i]);
      }
    }
    con.clear();
    con = contoursTemp;
    contoursTemp.clear();
    return con;
}



  vector<Vehicle> setValuesNew(vector<Rect> boundRect, vector<vector<Point>> contours, Mat frame, vector<Vehicle> newDetected, vector<Mat> *newCroppedImages, RNG rng){

    cv::Mat cropImage(frame.rows, frame.cols, CV_8UC3);
    cv::Mat mask = Mat::zeros(frame.rows,frame.cols, CV_8UC1);
    //THETW ID,COLOR,CROPPEDIMAGE,TL,BR,CENTER
    for (unsigned int i = 0; i < contours.size(); ++i){
      boundRect[i] = boundingRect(Mat(contours[i]));
      //Crop the selected ROI
      rectangle( mask, boundRect[i].tl(), boundRect[i].br(), Scalar(255), -1);
      frame.copyTo(cropImage,mask);
      cropImage = cropImage(boundRect[i]).clone();
      //set some useful information to the new detected blob
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
    
/*
void setCenFeature(Vehicle *newDetected, vector<DMatch> good_matches){
          Point2f sumF = Point2f(0,0);
          vector<KeyPoint> tempKeypointsSIFT = newDetected->getKeypointsSIFT();
          for(unsigned int p = 0; p < good_matches.size(); ++p){
            sumF += tempKeypointsSIFT[good_matches[p].queryIdx].pt;
          }
          if(good_matches.size() != 0){
            sumF.x = round(sumF.x/good_matches.size());
            sumF.y = round(sumF.y/good_matches.size());
            newDetected->setCenterFeature(sumF);
          }
}
*/
void setValuesNewTracked(Vehicle *newDetected, Vehicle oldDetected, bool occluded){
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
  float maxRateL = 0;
  int keyL = -1;
  for(int l = 0; l < occluded_vehicles; ++l){
             float RateL;
              Mat tempdescriptorSIFT1;
              BFMatcher matcherSIFT1;

             std::vector<std::vector< DMatch>> matchesSIFT1;
              std::vector<DMatch> good_matchesSIFT1;
      
              //std::vector<DMatch> good_matches1;
              
              tempdescriptorSIFT1 = Occluded[l].getDescriptorSIFT().clone();
         
            if(newDetected.getKeypointsSIFT().size() != 0 && Occluded[l].getKeypointsSIFT().size() != 0){
              matcherSIFT1.knnMatch(descriptorSIFT1,tempdescriptorSIFT1,matchesSIFT1,2);
            }

              for(unsigned int z = 0; z < matchesSIFT1.size(); z++){
               const float ratio = 0.8; // it can be tuned
                if(matchesSIFT1[z][0].distance < ratio*matchesSIFT1[z][1].distance){
                  good_matchesSIFT1.push_back(matchesSIFT1[z][0]);
                }
              }
         
             // good_matches1 = good_matchesSIFT1;
       
              vector<KeyPoint> tempKeypointsCombined;
              vector<KeyPoint> tempOccluded;

              tempKeypointsCombined = newDetected.getKeypointsCombined();
              tempOccluded = Occluded[l].getKeypointsCombined();
              
           
              RateL = (float)good_matchesSIFT1.size()/(float)max(tempKeypointsCombined.size(),tempOccluded.size());
              
              if(maxRateL < RateL){
                maxRateL = RateL;
                keyL = l;
              }
            
             matchesSIFT1.clear();
             good_matchesSIFT1.clear();
            // good_matches1.clear();
            

          } 
          return keyL;
}