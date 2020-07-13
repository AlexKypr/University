
 vector<vector<Point>> morphologicalOps(Mat map,vector<vector<Point>> con,Mat drawing){
  cv::Mat seg,closing,detected_edges;
  vector<Vec4i> hierarchy;
  int lowThreshold = 100,morph_size = 5,morph_size2 = 1,ratio = 3, kernel_size = 5;
  double min_area = 100;
  cv::Mat element = getStructuringElement( MORPH_RECT, Size( 2*morph_size + 1, 2*morph_size+1 ), Point( morph_size, morph_size ) );
  cv::Mat element2 = getStructuringElement( MORPH_RECT, Size( 2*morph_size2 + 1, 2*morph_size2+1 ), Point( morph_size2, morph_size2 ) );
  vector<vector<Point>> contoursTemp;
  /* Post-processing: 5x5 median filter to reduce noise */
    medianBlur(map, map, 5);
    cv::copyMakeBorder(map,seg,1,1,1,1,BORDER_CONSTANT,Scalar(0,0,0));//Create border in order to contour better
    
    Ptr<CannyEdgeDetector> edgeDetector = createCannyEdgeDetector(lowThreshold,lowThreshold*ratio,kernel_size);
    cv::cuda::GpuMat segCuda,closingCuda,detected_edgesCuda;
    segCuda.upload(seg);
    edgeDetector->detect(segCuda, detected_edgesCuda);
    //detected_edgesCuda.download(detected_edges);
    //Closing edges
    Ptr<cuda::Filter> ExFilter = cuda::createMorphologyFilter(MORPH_CLOSE, detected_edgesCuda.type(), element);
   
   
    ExFilter->apply(detected_edgesCuda,closingCuda);
    //Ptr<Filter> createEx(MORPH_CLOSE,detected_edgesCuda)
    //morphologyEx(detected_edges,closing,MORPH_CLOSE,element);
  
    Ptr<cuda::Filter> dilateFilter = cuda::createMorphologyFilter(MORPH_DILATE, closingCuda.type(), element2);
    dilateFilter->apply(closingCuda,closingCuda);
    Ptr<cuda::Filter> erodeFilter = cuda::createMorphologyFilter(MORPH_ERODE, closingCuda.type(), element2);
   	erodeFilter->apply(closingCuda,closingCuda);
   	closingCuda.download(closing);
    //dilate( closing, closing, element2 );
    //erode( closing, closing, element2 );
    //Finding Contours
    findContours(closing, con, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE,Point(-1, -1) );//RETR_EXTERNAL theloume mono outer contour
    //erode( drawing, drawing, element2 );
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
