/* Copyright - Benjamin Laugraud <blaugraud@ulg.ac.be> - 2016
 * Copyright - Marc Van Droogenbroeck <m.vandroogenbroeck@ulg.ac.be> - 2016
 *
 * ViBe is covered by a patent (see http://www.telecom.ulg.ac.be/research/vibe).
 *
 * Permission to use ViBe without payment of fee is granted for nonprofit
 * educational and research purposes only.
 *
 * This work may not be copied or reproduced in whole or in part for any
 * purpose.
 *
 * Copying, reproduction, or republishing for any purpose shall require a
 * license. Please contact the authors in such cases. All the code is provided
 * without any guarantee.
 *
 * This simple example program takes a path to a video sequence as an argument.
 * When it is executed, two windows are opened: one displaying the input
 * sequence, and one displaying the segmentation maps produced by ViBe. Note
 * that this program uses the a polychromatic version of ViBe with 3 channels.
 */
 
#include <cstddef>
#include <ctime>
#include <iostream>

#ifndef    OPENCV_3
#include <opencv/cv.h>
#include <opencv/highgui.h>

#else
#include "opencv2/opencv.hpp"
#include "opencv2/features2d.hpp"
#include "opencv2/xfeatures2d.hpp"
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
  unsigned int indice;
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
  Mat descriptorSURF;
  vector<KeyPoint> KeypointsSURF;
  vector<KeyPoint> KeypointsCombined;



  //bool matched;
  //bool tracked;
public:
  Vehicle(){tracked = false;occluded = false;};
  Vehicle(const Vehicle &obj){identity = obj.identity;image = obj.image.clone();boundRect = obj.boundRect;rectColor = obj.rectColor;center = obj.center;Br = obj.Br;Tl = obj.Tl;descriptorSIFT = obj.descriptorSIFT.clone();KeypointsSIFT = obj.KeypointsSIFT;descriptorSURF = obj.descriptorSURF.clone();KeypointsSURF = obj.KeypointsSURF;KeypointsCombined = obj.KeypointsCombined;tracked = obj.tracked;occluded = obj.occluded;du = obj.du;}
  ~Vehicle(){};
  void begIdentity(){identity = ++counter_identity;}
  void setId(unsigned int id){identity = id;}
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
  void setDescriptorSURF(Mat des){descriptorSURF = des.clone();}
  void setKeypointsSURF(vector<KeyPoint> KP){KeypointsSURF = KP;}
  void setKeypointsCombined(vector<KeyPoint> Combo){KeypointsCombined = Combo;}
  void setIndice(unsigned int p){indice = p;}
  void isTracked(bool x){tracked = x;}
  void isOccluded(bool y){occluded = y;}

  unsigned int getIdentity(){return identity;}
  unsigned int getIndice(){return indice;}
  Rect getBoundRect(){return boundRect;}
  Scalar getRectColor(){return rectColor;}
  Mat getDescriptorSIFT(){return descriptorSIFT;}
  vector<KeyPoint> getKeypointsSIFT(){return KeypointsSIFT;} 
  Mat getDescriptorSURF(){return descriptorSURF;}
  vector<KeyPoint> getKeypointsSURF(){return KeypointsSURF;}
  vector<KeyPoint> getKeypointsCombined(){return KeypointsCombined;}  
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
vector<Vehicle> setValuesNew(vector<Rect> boundRect, vector<vector<Point>> contours, Mat frame, vector<Vehicle> newDetected, vector<Mat> *newCroppedImages);
void setCenFeature(Vehicle *newDetected,vector<DMatch> good_matches);
void setValuesNewTracked(Vehicle *newDetected, Vehicle oldDetected, bool occluded);

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
  int minHessian = 400;
  cv::Ptr<Feature2D> detectorSURF = xfeatures2d::SURF::create(minHessian);
  BFMatcher matcherSIFT;
  BFMatcher matcherSURF;
  std::vector<std::vector< DMatch>> matchesSIFT;
  std::vector<std::vector< DMatch>> matchesSURF;
  std::vector<std::vector< DMatch>> matches;  
  vector<Mat> newdescriptorSIFT;
  vector<Mat> newdescriptorSURF;
  vector<Mat> newCroppedImages;
  vector<vector<KeyPoint>> newKeypointsSIFT;
  vector<vector<KeyPoint>> newKeypointsSURF;


  vector<Vehicle> newDetected;//THELW SUNEXEIA NA MHDENIZETAI OPOTE VOLEUEI EDW
  vector<Vehicle> oldDetected;
  
  vector<Vehicle> Tracked(20);
  vector<Vehicle> Occluded(20);
  vector<int> occludedBlobId(20);
  vector<Point> distOccluded(20);
  
  //KF.transitionMatrix = (Mat_<float>(4, 4) << 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1);
  //vector<Mat_<float>> measurement;
  //Mat_<float> measurement;
  //measurement.setTo(Scalar(0));
  //cout<<measurement.size()<<endl;
  //getchar();

  while (decoder.read(frame)) {
    if (firstFrame) {
      /* Instantiation of ViBe. */
      vibe = new ViBe(height, width, frame.data);
      firstFrame = false;
    }

    /* Segmentation and update. */
    vibe->segmentation(frame.data, segmentationMap.data);
    vibe->update(frame.data, segmentationMap.data);
    
    cv::Mat drawing = Mat::zeros(segmentationMap.rows + 2,segmentationMap.cols + 2, CV_8UC1);
    //Function doing all the morphological operations to find the blobs
    contours = morphologicalOps(segmentationMap,contours,drawing);

    /*DONT DELETE THIS CODE*/
    vector<Rect> boundRect( contours.size() );
    newDetected.resize(contours.size());
    //Function setting values to new Detected blobs
    newDetected = setValuesNew(boundRect, contours, frame, newDetected, &newCroppedImages);
   

    ////NEW WAY OF SIFT///
    //Detecting and computing keypoints and descriptors
    detectorSIFT->detect(newCroppedImages,newKeypointsSIFT);
    detectorSIFT->compute(newCroppedImages,newKeypointsSIFT,newdescriptorSIFT);
    detectorSURF->detect(newCroppedImages,newKeypointsSURF);
    detectorSURF->compute(newCroppedImages,newKeypointsSURF,newdescriptorSURF);

   
    Mat img_matches;
    std::vector<DMatch> good_matchesSIFT;
    std::vector<DMatch> good_matchesSURF;
    std::vector<DMatch> good_matches;
   
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
      newDetected[i].setKeypointsSURF(newKeypointsSURF[i]);
      newDetected[i].setDescriptorSURF(newdescriptorSURF[i].clone());
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
          Mat tempdescriptorSURF;
          Mat descriptorSURF;
          descriptorSIFT = newDetected[i].getDescriptorSIFT().clone();
          tempdescriptorSIFT = oldDetected[j].getDescriptorSIFT().clone();
          descriptorSURF = newDetected[i].getDescriptorSURF().clone();
          tempdescriptorSURF = oldDetected[j].getDescriptorSURF().clone();
          
         
          
          if(newDetected[i].getKeypointsSIFT().size() != 0 && oldDetected[j].getKeypointsSIFT().size() != 0){
            matcherSIFT.knnMatch(descriptorSIFT,tempdescriptorSIFT,matchesSIFT,2);
          }
          if(newDetected[i].getKeypointsSURF().size() != 0 && oldDetected[j].getKeypointsSURF().size() != 0){
            matcherSURF.knnMatch(descriptorSURF,tempdescriptorSURF,matchesSURF,2);
          }
          
          /*Find good matches*/
          for(unsigned int z = 0; z < matchesSIFT.size(); z++){
              const float ratio = 0.8; // it can be tuned
              if(matchesSIFT[z][0].distance < ratio*matchesSIFT[z][1].distance){
                good_matchesSIFT.push_back(matchesSIFT[z][0]);
              }
          }

          for(unsigned int z = 0; z < matchesSURF.size(); z++){
              const float ratio = 0.8; // it can be tuned
              if(matchesSURF[z][0].distance < ratio*matchesSURF[z][1].distance){
                good_matchesSURF.push_back(matchesSURF[z][0]);
              }
          }
          
          /*END-find good matches*/

          good_matches = good_matchesSIFT;//1a
          /* calculating the center of the features of the good matches */
          setCenFeature(&newDetected[i],good_matches);

          good_matches.insert(good_matches.end(),good_matchesSURF.begin(),good_matchesSURF.end());//1b

          //Save the combined keypoints 
          vector<KeyPoint> combinedNewKeypoints = newDetected[i].getKeypointsSIFT();
          vector<KeyPoint> combinedOldKeypoints = oldDetected[j].getKeypointsCombined();
          combinedNewKeypoints.insert(combinedNewKeypoints.end(),newKeypointsSURF[i].begin(),newKeypointsSURF[i].end());
          newDetected[i].setKeypointsCombined(combinedNewKeypoints);

           
          if(good_matches.size() > 4 && combinedNewKeypoints.size() > 0 && combinedOldKeypoints.size() > 0){
          
            Rate = (float)good_matches.size()/(float)max(combinedNewKeypoints.size(),combinedOldKeypoints.size());
            
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
         matchesSURF.clear();
         good_matchesSIFT.clear();
         good_matchesSURF.clear();   
         good_matches.clear();

        }
        if(maxRate != 0){
           
          if((keyj1 == keepj || keyj2 == keepj) && (keyj1 != 1000 && keyj2 != 1000) && countFullIntersects == 2){
              cout<<"STOP"<<" i: "<<i<<" j: "<<keepj<<" keyj1: "<<keyj1<<" keyj2: "<<keyj2<<endl;
              occluded = 1;
              flagTrue++;
              imshow("first j",oldDetected[keyj1].getImage());
              imshow("second j",oldDetected[keyj2].getImage());
              waitKey(1);
              getchar();
          }

          ++tracked_vehicles;
          Tracked.resize(tracked_vehicles);
          setValuesNewTracked(&newDetected[i], oldDetected[keepj], occluded);
          Tracked[tracked_vehicles - 1] = newDetected[i];
          Tracked[tracked_vehicles - 1].setIndice(i);
          cout<<"ID of new "<<newDetected[i]<<endl;
          
        }
        
        if(occluded){
          occluded_vehicles+=2;
          Occluded.resize(occluded_vehicles);
          Occluded[occluded_vehicles - 2] = oldDetected[keyj1];
          Occluded[occluded_vehicles - 1] = oldDetected[keyj2];
          occludedBlobId.resize(occluded_vehicles/2);
          occludedBlobId[occluded_vehicles/2] = newDetected[i].getIdentity();
        }
        if(OnetoNj != 1000 && occluded_vehicles > 0){//not occluded anymore

          Mat descriptorSIFT1;
          Mat descriptorSURF1;
  
          descriptorSIFT1 = newDetected[OnetoNi1[OnetoNj]].getDescriptorSIFT().clone();
          descriptorSURF1 = newDetected[OnetoNi1[OnetoNj]].getDescriptorSURF().clone();

          float maxRateL = 0;
          int keyL = -1;
          
          for(int l = 0; l < occluded_vehicles; ++l){

              float RateL;
              Mat tempdescriptorSIFT1;
              Mat tempdescriptorSURF1;

              BFMatcher matcherSIFT1;
              BFMatcher matcherSURF1;

             std::vector<std::vector< DMatch>> matchesSIFT1;
             std::vector<std::vector< DMatch>> matchesSURF1;

              std::vector<DMatch> good_matchesSIFT1;
              std::vector<DMatch> good_matchesSURF1;

              std::vector<DMatch> good_matches1;
              
              tempdescriptorSIFT1 = Occluded[l].getDescriptorSIFT().clone();
              tempdescriptorSURF1 = Occluded[l].getDescriptorSURF().clone();
             



            if(newDetected[OnetoNi1[OnetoNj]].getKeypointsSIFT().size() != 0 && Occluded[l].getKeypointsSIFT().size() != 0){
              matcherSIFT1.knnMatch(descriptorSIFT1,tempdescriptorSIFT1,matchesSIFT1,2);
            }
            if(newDetected[OnetoNi1[OnetoNj]].getKeypointsSURF().size() != 0 && Occluded[l].getKeypointsSURF().size() != 0){
              matcherSURF1.knnMatch(descriptorSURF1,tempdescriptorSURF1,matchesSURF1,2);
            }

              for(unsigned int z = 0; z < matchesSIFT1.size(); z++){
               const float ratio = 0.8; // it can be tuned
                if(matchesSIFT1[z][0].distance < ratio*matchesSIFT1[z][1].distance){
                  good_matchesSIFT1.push_back(matchesSIFT1[z][0]);
                }
              }
              for(unsigned int z = 0; z < matchesSURF1.size(); z++){
                const float ratio = 0.8; // it can be tuned
                if(matchesSURF1[z][0].distance < ratio*matchesSURF1[z][1].distance){
                  good_matchesSURF1.push_back(matchesSURF1[z][0]);
                }
              }

              good_matches1 = good_matchesSIFT1;
              good_matches1.insert(good_matches1.end(),good_matchesSURF1.begin(),good_matchesSURF1.end());

              vector<KeyPoint> tempKeypointsCombined;
              vector<KeyPoint> tempOccluded;

              tempKeypointsCombined = newDetected[OnetoNi1[OnetoNj]].getKeypointsCombined();
              tempOccluded = Occluded[l].getKeypointsCombined();
              cout<<"New Detected"<<tempKeypointsCombined.size()<<endl;
              cout<<"New Occluded"<<tempOccluded.size()<<endl;
              cout<<"good_matches"<<good_matches1.size()<<endl;
              cout<<"occluded_vehicles"<<occluded_vehicles<<endl;
              RateL = (float)good_matches1.size()/(float)max(tempKeypointsCombined.size(),tempOccluded.size());
              cout<<"RateExtra: "<<RateL<<endl;
              if(maxRateL < RateL){
                maxRateL = RateL;
                keyL = l;
              }
             
             matchesSURF1.clear();
             matchesSIFT1.clear();
             good_matchesSIFT1.clear();
             good_matchesSURF1.clear();
             good_matches1.clear();
              
          }         
          //Evala oti ama einai p.x to zeugari 0-1 kai vrw oti einai to 1 profanws to prohgoymeno einai to prwto
          
          for(int r = 0; r < tracked_vehicles - 1; r++){
              if(Tracked[r].getIdentity() == newDetected[r].getIdentity()){
                Tracked[r] = newDetected[OnetoNi1[OnetoNj]];
                Tracked[r].setIndice(OnetoNi1[OnetoNj]);
                break;
              }
          }
          unsigned int keyL1;
          unsigned int keyL2;
          if(keyL % 2 == 1){
            newDetected[OnetoNi1[OnetoNj]].setId(Occluded[keyL].getIdentity());
            newDetected[OnetoNi1[OnetoNj]].setRectColor(Occluded[keyL].getRectColor());
            newDetected[OnetoNi1[OnetoNj]].isOccluded(false);
            newDetected[OnetoNi2[OnetoNj]].setId(Occluded[keyL - 1].getIdentity());
            newDetected[OnetoNi2[OnetoNj]].setRectColor(Occluded[keyL - 1].getRectColor());
            newDetected[OnetoNi2[OnetoNj]].isOccluded(false);
            keyL1 = keyL;
            keyL2 = keyL - 1;
          }else{
            newDetected[OnetoNi1[OnetoNj]].setId(Occluded[keyL].getIdentity());
            newDetected[OnetoNi1[OnetoNj]].setRectColor(Occluded[keyL].getRectColor());
            newDetected[OnetoNi1[OnetoNj]].isOccluded(false);
            newDetected[OnetoNi2[OnetoNj]].setId(Occluded[keyL + 1].getIdentity());
            newDetected[OnetoNi2[OnetoNj]].setRectColor(Occluded[keyL + 1].getRectColor());
            newDetected[OnetoNi2[OnetoNj]].isOccluded(false);
            keyL1 = keyL;
            keyL2 = keyL + 1;
          }
          //Gia na mphke einai to teleutaio
          Tracked[tracked_vehicles - 1] = newDetected[i];
          Tracked[tracked_vehicles - 1].setIndice(i);
          //Vrhka poia occluded simpiptoun me ta kainouria
          //newDetected

           vector<Vehicle> Occludedtemp;
           for(unsigned int i = 0; i < Occluded.size(); i++ ){
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

          //occludedBlobId.resize(occluded_vehicles/2);

          cout<<"STOP 2 STOP"<<endl;//<<" i: "<<i<<" j: "<<j<<" OnetoNi1 "<<OnetoNi1[j]<<" OnetoNi2: "<<OnetoNi2[j]<<endl;
          getchar();
        }
        //The intermediate state between start of occlusion and before separation
        if(newDetected[i].getOccluded() && newDetected[i].getTracked()){
          //prepei na vrw poia anhkoun se authn
          Mat descriptorSIFT1;
          //Mat descriptorSURF1;
          
          descriptorSIFT1 = newDetected[i].getDescriptorSIFT().clone();
          //descriptorSURF1 = newDetected[i].getDescriptorSURF().clone();


          float maxRateL1 = 0;
          float maxRateL2 = 0;
          int keyL1 = 0;
          int keyL2 = 0;
          //vector<vector<DMatch>> indexSURF;
          vector<vector<DMatch>> indexSIFT;

          for(int l = 0; l < occluded_vehicles; ++l){

              float RateL;
              Mat tempdescriptorSIFT1;
              //Mat tempdescriptorSURF1;

              BFMatcher matcherSIFT1;
              //BFMatcher matcherSURF1;

             std::vector<std::vector< DMatch>> matchesSIFT1;
             //std::vector<std::vector< DMatch>> matchesSURF1;

              std::vector<DMatch> good_matchesSIFT1;
              //std::vector<DMatch> good_matchesSURF1;

              std::vector<DMatch> good_matches1;
              
              tempdescriptorSIFT1 = Occluded[l].getDescriptorSIFT().clone();
              //tempdescriptorSURF1 = Occluded[l].getDescriptorSURF().clone();

              if(newDetected[i].getKeypointsSIFT().size() != 0 && Occluded[l].getKeypointsSIFT().size() != 0){
                matcherSIFT1.knnMatch(descriptorSIFT1,tempdescriptorSIFT1,matchesSIFT1,2);
              }
              //if(newDetected[i].getKeypointsSURF().size() != 0 && Occluded[l].getKeypointsSURF().size() != 0){
                //matcherSURF1.knnMatch(descriptorSURF1,tempdescriptorSURF1,matchesSURF1,2);
              //}

              for(unsigned int z = 0; z < matchesSIFT1.size(); z++){
               const float ratio = 0.8; // it can be tuned
                if(matchesSIFT1[z][0].distance < ratio*matchesSIFT1[z][1].distance){
                  good_matchesSIFT1.push_back(matchesSIFT1[z][0]);
                }
              }
              //for(unsigned int z = 0; z < matchesSURF1.size(); z++){
                //const float ratio = 0.8; // it can be tuned
                //if(matchesSURF1[z][0].distance < ratio*matchesSURF1[z][1].distance){
                 // good_matchesSURF1.push_back(matchesSURF1[z][0]);
                //}
              //}
              //good_matches1 = good_matchesSURF1;
              good_matches1 = good_matchesSIFT1;
              //good_matches1.insert(good_matches1.end(),good_matchesSURF1.begin(),good_matchesSURF1.end());

              vector<KeyPoint> tempKeypointsCombined;
              vector<KeyPoint> tempOccluded;

              tempKeypointsCombined = newDetected[i].getKeypointsCombined();
              tempOccluded = Occluded[l].getKeypointsCombined();
              cout<<"New Detected"<<tempKeypointsCombined.size()<<endl;
              cout<<"New Occluded"<<tempOccluded.size()<<endl;
              cout<<"good_matches Query"<<good_matches1.size()<<endl;
              cout<<"occluded_vehicles"<<occluded_vehicles<<endl;
              RateL = (float)good_matches1.size()/(float)max(tempKeypointsCombined.size(),tempOccluded.size());
              cout<<"RateExtra: "<<RateL<<endl;
              //getchar();
              if(maxRateL1 < RateL && maxRateL1 == 0){
                maxRateL1 = RateL;
                keyL1 = l;
              }else if(maxRateL1 < RateL && maxRateL1 != 0 && maxRateL2 == 0){
                maxRateL2 = maxRateL1;
                maxRateL1 = RateL;
                keyL2 = keyL1;
                keyL1 = l;
              }else if(maxRateL1 < RateL && maxRateL1 != 0 && maxRateL2 != 0){
                if(maxRateL2 < maxRateL1){
                  maxRateL2 = maxRateL1;
                  keyL2 = keyL1;
                }
                maxRateL1 = RateL;
                keyL1 = l;

              }else if(maxRateL2 < RateL){
                maxRateL2 = RateL;
                keyL2 = l;
              }
            
              //indexSURF.push_back(good_matchesSURF1);
              indexSIFT.push_back(good_matchesSIFT1);
             //for(int p = 0; p < good_matchesSURF1.size(); p++){
               //indexSURF[l].push_back(good_matchesSURF1[p].queryIdx);
               // cout<<"Surf"<<good_matchesSURF1[p].queryIdx<<endl;
             //}

             //for(int p = 0; p < good_matchesSIFT1.size(); p++){
               // indexSIFT[l].push_back(good_matchesSIFT1[p].queryIdx);
               // cout<<"Sift"<<good_matchesSIFT1[p].queryIdx<<endl;
             //}

             //matchesSURF1.clear();
             matchesSIFT1.clear();
             good_matchesSIFT1.clear();
             //good_matchesSURF1.clear();
             good_matches1.clear();
            }
            Point2f sumL1 = Point2f(0,0);
            Point2f sumL2 = Point2f(0,0);
            Point2f sumL11 = Point2f(0,0);
            Point2f sumL22 = Point2f(0,0);
            //vector<KeyPoint> tempKeySURF = newDetected[i].getKeypointsSURF();
            vector<KeyPoint> tempKeySIFT = newDetected[i].getKeypointsSIFT();
            vector<KeyPoint> tempKeySIFTOccluded1 = Occluded[keyL1].getKeypointsSIFT();
            vector<KeyPoint> tempKeySIFTOccluded2 = Occluded[keyL2].getKeypointsSIFT();
            //for(int u = 0; u < indexSURF[keyL1].size(); ++u){
              //cout<<indexSURF[keyL1][u].queryIdx<<endl;
              //cout<<tempKey[indexSURF[keyL1][u].queryIdx].pt<<endl;
              //sumL1 += tempKeySURF[indexSURF[keyL1][u].queryIdx].pt;
              //cout<<"Points"<<tempKey[indexSURF[keyL1][u].queryIdx].x<<" "<<tempKey[indexSURF[keyL1][u].queryIdx].y<<endl;
            //}
            vector<DMatch> temp1;
            vector<DMatch> temp2;
            for(unsigned int u = 0 ; u < indexSIFT[keyL1].size();++u){
              int flagz = 0;
              for(unsigned int z = 0 ; z < indexSIFT[keyL2].size();++z){
                  if(indexSIFT[keyL1][u].queryIdx == indexSIFT[keyL2][z].queryIdx){
                    flagz = 1;
                    break;
                  }
              }
              if(!flagz){
                temp1.push_back(indexSIFT[keyL1][u]);
              }
            }

            for(unsigned int u = 0 ; u < indexSIFT[keyL2].size();++u){
              int flagz = 0;
              for(unsigned int z = 0 ; z < indexSIFT[keyL1].size();++z){
                  if(indexSIFT[keyL2][u].queryIdx == indexSIFT[keyL1][z].queryIdx){
                    flagz = 1;
                    break;
                  }
              }
              if(!flagz){
                temp2.push_back(indexSIFT[keyL2][u]);
              }
            }

            vector<KeyPoint> temptemp;

            for(unsigned int u = 0; u < temp1.size(); ++u){
              //cout<<indexSIFT[keyL1][u].queryIdx<<endl;
              //cout<<tempKey[indexSIFT[keyL1][u].queryIdx].pt<<endl;
              sumL1 += tempKeySIFT[temp1[u].queryIdx].pt;
              sumL11 += tempKeySIFTOccluded1[temp1[u].trainIdx].pt;
              temptemp.push_back(tempKeySIFTOccluded1[temp1[u].trainIdx]);
              //cout<<"Points"<<tempKey[indexSURF[keyL1][u].queryIdx].x<<" "<<tempKey[indexSURF[keyL1][u].queryIdx].y<<endl;
            }

            Mat temp = newDetected[i].getImage();
            drawKeypoints(temp,temptemp,temp,Scalar::all(-1), DrawMatchesFlags::DEFAULT );
            imshow("show",temp);
            waitKey(1);
            getchar();



            sumL1.x = sumL1.x/temp1.size();
            sumL1.y = sumL1.y/temp1.size();
            sumL11.x = sumL11.x/temp1.size();
            sumL11.y = sumL11.y/temp1.size();
            Point cf = Point(0,0);
            cf.x = sumL1.x + newDetected[i].getTl().x;
            cf.y = sumL1.y + newDetected[i].getTl().y;
            Point cmf = Point(0,0);
            cmf.x = sumL11.x + Occluded[keyL1].getTl().x;
            cmf.y = sumL11.y + Occluded[keyL1].getTl().y;

            Point dist1 = Point(0,0);
            Point dist2 = Point(0,0);
            dist1.x = Occluded[keyL1].getCenter().x - Occluded[keyL1].getTl().x - Occluded[keyL1].getCenterFeature().x;
            dist1.y = Occluded[keyL1].getCenter().y - Occluded[keyL1].getTl().y - Occluded[keyL1].getCenterFeature().y;
            dist2.x = Occluded[keyL2].getCenter().x - Occluded[keyL2].getTl().x - Occluded[keyL2].getCenterFeature().x;
            dist2.y = Occluded[keyL2].getCenter().y - Occluded[keyL2].getTl().y - Occluded[keyL2].getCenterFeature().y;
            cout<<"DISTANCE X "<<dist1.x<<" DISTANCE Y "<<dist1.y<<endl; 
            cout<<"CENTER FEATURE "<<Occluded[keyL1].getCenterFeature()<<endl;
            cout<<" Center of New Features: "<<cf<<" Center of Combined: "<<newDetected[i].getCenter()<<" Center of Matched Features: "<<cmf<<" Center of One Occluded "<<Occluded[keyL1].getCenter()<<endl;
            cout<<"Point center "<<sumL1<<" Point center2: "<<sumL11<<endl;
            //for(int u = 0; u < indexSURF[keyL2].size(); ++u){
              //cout<<indexSURF[keyL1][u].queryIdx<<endl;
              //cout<<tempKeySURF[indexSURF[keyL1][u].queryIdx].pt<<"Surf Points"<<endl;
              //sumL2 += tempKeySURF[indexSURF[keyL2][u].queryIdx].pt;
              //cout<<"Points"<<tempKeySURF[indexSURF[keyL1][u].queryIdx].pt<<endl;
              //getchar();
            //}
            for(unsigned int u = 0; u < temp2.size(); ++u){
              //cout<<indexSIFT[keyL1][u].queryIdx<<endl;
              //cout<<tempKeySIFT[indexSIFT[keyL1][u].queryIdx].pt<<"SIFT points"<<endl;
              sumL2 += tempKeySIFT[temp2[u].queryIdx].pt;
              sumL22 += tempKeySIFTOccluded2[temp2[u].trainIdx].pt;
              //cout<<"Points"<<tempKey[indexSURF[keyL1][u].queryIdx].x<<" "<<tempKey[indexSURF[keyL1][u].queryIdx].y<<endl;
            }
            sumL2.x = sumL2.x/temp2.size();
            sumL2.y = sumL2.y/temp2.size();
            sumL22.x = sumL22.x/temp2.size();
            sumL22.y = sumL22.y/temp2.size();
            //cout<<"Point center"<<sumL2<<endl;
            //cout<<"Center of Rectangle: "<<Occluded[keyL1].getCenter()<<endl;
            //getchar();
            cout<<" Center of New: "<<sumL2<<" Center of Old: "<<sumL22<<endl;
            Point tl1,tl2,br1,br2;
            tl1.x = round(sumL1.x) + newDetected[i].getTl().x + dist1.x - Occluded[keyL1].getBoundRect().width/2;
            tl1.y = round(sumL1.y) + newDetected[i].getTl().y + dist1.y - Occluded[keyL1].getBoundRect().height/2;

            //tl1.x = Occluded[keyL1].getTl().x + (Occluded[keyL1].getDu().x);
            //tl1.y = Occluded[keyL1].getTl().y + (Occluded[keyL1].getDu().y);
            //Occluded[keyL1].setTl(tl1);

            //br1.x = Occluded[keyL1].getBr().x + Occluded[keyL1].getDu().x;
            //br1.y = Occluded[keyL1].getBr().y + Occluded[keyL1].getDu().y;
            //Occluded[keyL1].setDimensions(tl1,br1);

            br1.x = round(sumL1.x) + newDetected[i].getTl().x + dist1.x + Occluded[keyL1].getBoundRect().width/2;
            br1.y = round(sumL1.y) + newDetected[i].getTl().y + dist1.y + Occluded[keyL1].getBoundRect().height/2;
            cout<<"tl1 "<<tl1<<" br1"<<br1<<endl; 
           
            tl2.x = round(sumL2.x) + newDetected[i].getTl().x + dist2.x - Occluded[keyL2].getBoundRect().width/2;
            tl2.y = round(sumL2.y) + newDetected[i].getTl().y + dist2.y - Occluded[keyL2].getBoundRect().height/2;

            //tl2.x = Occluded[keyL2].getTl().x +  Occluded[keyL2].getDu().x;
            //tl2.y = Occluded[keyL2].getTl().y +  Occluded[keyL2].getDu().y;
            //Occluded[keyL2].setTl(tl2);


            //br2.x = Occluded[keyL2].getBr().x + Occluded[keyL2].getDu().x;
            //br2.y = Occluded[keyL2].getBr().y + Occluded[keyL2].getDu().y;
            //Occluded[keyL2].setDimensions(tl2,br2);



            br2.x = round(sumL2.x) + newDetected[i].getTl().x + dist2.x +Occluded[keyL2].getBoundRect().width/2 + Occluded[keyL2].getDu().x;
            br2.y = round(sumL2.y) + newDetected[i].getTl().y + dist2.y +Occluded[keyL2].getBoundRect().height/2 + Occluded[keyL2].getDu().y;
            //cout<<"TL "<<tl1<<" BR "<<br1<<" CENTER "<<sumL1<<endl;
            rectangle(frame, tl1, br1, Scalar(255,0,0) , 2 , 8 , 0);
            rectangle(frame, tl2, br2, Scalar(0,255,0) , 2 , 8 , 0); 
            //cout<<newDetected[i].getBoundRect().width<<" WIDTH"<<endl;
            //cout<<"KeyL1: "<<keyL1<<"KeyL2 "<<keyL2<<endl;
            //imshow("Blob",newDetected[i].getImage());
            //imshow("1st occluded",Occluded[keyL1].getImage());
            //imshow("2nd occluded",Occluded[keyL2].getImage());
            indexSIFT.clear();
            temp1.clear();
            temp2.clear();
            //indexSURF.clear();
        }

        maxRate = 0;
    }
    
   
  Mat drawRect = Mat::zeros( drawing.size(), CV_8UC3 ); 
 for (unsigned int i = 0; i < Tracked.size(); ++i){
      unsigned int j = Tracked[i].getIndice();
      if(boundRect.size() > 0){
        cout<<"MPHKEEEEE"<<endl;
        cout<<"Color"<<Tracked[i].getTl()<<endl;

        drawContours( drawRect, contours, j, Tracked[i].getRectColor(), 1, 8, vector<Vec4i>(), 0, Point() );
        rectangle( frame, Tracked[i].getTl(), Tracked[i].getBr(), Tracked[i].getRectColor(), 2, 8, 0 );
      }
    }
/* OCCLUSIONNNNN
for(unsigned int i = 0; i < occluded_vehicles/2; ++i){
  if(!flagNtoOne[i]){
    Occluded[i*2].setCenter(Point(newDetected[occludedBlobId[i]].getCenter().x + distOccluded[i*2].x,newDetected[occludedBlobId[i]].getCenter().y + distOccluded[i*2].y));
    Occluded[i*2 + 1].setCenter(Point(newDetected[occludedBlobId[i]].getCenter().x + distOccluded[i*2 + 1].x,newDetected[occludedBlobId[i]].getCenter().y + distOccluded[i*2 + 1].y));
    
    Point tl1 = Point(newDetected[occludedBlobId[i]].getTl().x + distOccluded[i*2].x,newDetected[occludedBlobId[i]].getTl().y + distOccluded[i*2].y);
    Point br1 = Point(newDetected[occludedBlobId[i]].getBr().x + distOccluded[i*2].x,newDetected[occludedBlobId[i]].getBr().y + distOccluded[i*2].y);
    Point tl2 = Point(newDetected[occludedBlobId[i]].getTl().x + distOccluded[i*2 + 1].x,newDetected[occludedBlobId[i]].getTl().y + distOccluded[i*2 + 1].y);
    Point br2 = Point(newDetected[occludedBlobId[i]].getBr().x + distOccluded[i*2 + 1].x,newDetected[occludedBlobId[i]].getBr().y + distOccluded[i*2 + 1].y);
       
    Occluded[i*2].setDimensions(tl1,br1);
    Occluded[i*2 + 1].setDimensions(tl2,br2);

    rectangle(frame, Occluded[i*2].getTl(),Occluded[i*2].getBr(), Occluded[i*2].getRectColor(),2,8,0);
    rectangle(frame, Occluded[i*2 + 1].getTl(),Occluded[i*2 + 1].getBr(), Occluded[i*2 + 1].getRectColor(),2,8,0);

  }
  
  //Thes na kaneis ena estimation ths thesis pou tha exei to amaxi
  //sta epomena frame me vash to kentro ekeinoy pou sxetizetai
  //prepei na krathsoume to id tou neou "enos" oxhmatos na upologiseis
  //thn apostash tou kentrou tou apo ta alla 2
  //Me vash poso metavlithei na metavaletai kai to kentro twn oxhmatwn

}
*/
//Keep the old descriptor,croppedImage and Keypoints to compare 
/*
if(oldDetected.size()!= 0 && newDetected.size() != 0 && Tracked.size() != 0){
    
    for(unsigned int i = 0 ; i < Tracked.size();i++){
      imshow("Tracked Vehicles",Tracked[i].getImage());
      cout<<"To tracked"<<endl;
      waitKey(1);
      getchar();
    }
    
    for(unsigned int i = 0; i < oldDetected.size();i++){
      imshow("Old Detected",oldDetected[i].getImage());
      cout<<"To detected"<<endl;
      waitKey(1);
      getchar();
    }
    
    for(unsigned int i = 0; i < newDetected.size();i++){
      imshow("New Detected",newDetected[i].getImage());
      cout<<"To Neo"<<endl;
      waitKey(1);
      getchar();
    }
    
  }
*/

    /* Set new to old */
    oldDetected.clear();
    oldDetected.resize(newDetected.size());
    for(unsigned int i = 0;i < newDetected.size();i++){
      oldDetected[i] = newDetected[i];
    }
    newDetected.clear();

    /* Release space */
    newdescriptorSIFT.clear();
    newdescriptorSURF.clear();
    newCroppedImages.clear();
    newKeypointsSIFT.clear();
    newKeypointsSURF.clear();
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
  cv::Mat seg,detected_edges,closing;
  vector<Vec4i> hierarchy;
  int lowThreshold = 100,morph_size = 7,morph_size2 = 3,ratio = 3, kernel_size = 5;
  double min_area = 100;
  cv::Mat element = getStructuringElement( MORPH_RECT, Size( 2*morph_size + 1, 2*morph_size+1 ), Point( morph_size, morph_size ) );
  cv::Mat element2 = getStructuringElement( MORPH_ELLIPSE, Size( 2*morph_size2 + 1, 2*morph_size2+1 ), Point( morph_size2, morph_size2 ) );
  vector<vector<Point>> contoursTemp;
  /* Post-processing: 5x5 median filter to reduce noise */
    medianBlur(map, map, 5);
    copyMakeBorder(map,seg,1,1,1,1,BORDER_CONSTANT,Scalar(0,0,0));//Create border in order to contour better
    Canny(seg, detected_edges, lowThreshold,lowThreshold*ratio,kernel_size);
    //Closing edges
    morphologyEx(detected_edges,closing,MORPH_CLOSE,element);
    dilate( closing, closing, element2 );
    erode( closing, closing, element2 );
    //Finding Contours
    findContours(closing, con, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE,Point(-1, -1) );//RETR_EXTERNAL theloume mono outer contour
    erode( drawing, drawing, element );
    ///Trying to Discard very small noise
    for(unsigned int i = 0; i < con.size(); i++ ){
      if(!(contourArea(con[i]) < min_area)){
        contoursTemp.push_back(con[i]);
      }
    }
    con.clear();
    con = contoursTemp;
    contoursTemp.clear();
    /* Dialegw meta me tetragwno to kanoniko frame xwris to border*/
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


  vector<Vehicle> setValuesNew(vector<Rect> boundRect, vector<vector<Point>> contours, Mat frame, vector<Vehicle> newDetected, vector<Mat> *newCroppedImages){
    RNG rng(12345);
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
      newDetected[i].setRectColor(Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) ));
      newDetected[i].setDimensions(boundRect[i].tl(),boundRect[i].br());
      newDetected[i].setCenter(boundRect[i].x,boundRect[i].y,boundRect[i].width,boundRect[i].height);
      newCroppedImages->push_back(cropImage.clone());
    }
    return newDetected;   
  }
    

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

void setValuesNewTracked(Vehicle *newDetected, Vehicle oldDetected, bool occluded){
        newDetected->setId(oldDetected.getIdentity());
        newDetected->setRectColor(oldDetected.getRectColor());
        newDetected->isOccluded(oldDetected.getOccluded());
        newDetected->isTracked(true);
        newDetected->setDu(newDetected->getCenter(),oldDetected.getCenter());
        if(occluded){
          newDetected->isOccluded(true);
        }
       
        
}