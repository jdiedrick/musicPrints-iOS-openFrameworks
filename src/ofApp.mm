#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    
    camW = ofGetWidth();
    camH = ofGetHeight();

    grabber.initGrabber(camW, camH);
    
    camW = grabber.getWidth();
    camH = grabber.getHeight();
    
    colorImg.allocate(camW, camH);
    grayImage.allocate(camW, camH);
    cout << "of w: " << ofGetWidth() << " of h: " << ofGetHeight() << endl;
}

//--------------------------------------------------------------
void ofApp::update(){
    
    grabber.update();
    
    if (grabber.isFrameNew()) {
        if (grabber.getPixels() != NULL) {
            
            //make a grayscale image out of our video grabber
            colorImg.setFromPixels(grabber.getPixels(), camW, camH);
            grayImage = colorImg;
            
            //collect the grayscale values from the center vertical line in the grayscale image, store in a vector
           grayImagePixels = grayImage.getPixels();
           // std::vector<int> grayscaleVerticalLine;
            
            for( int y = 0; y<grayImage.getHeight(); y++){
                int position = grayImage.getWidth()/2 + (y * grayImage.getWidth());
                
                grayscaleVerticalLine.push_back(grayImagePixels[position]);
                
            }
            
            int totalValue = 0;
            
            for (int i = 0; i<grayscaleVerticalLine.size(); i++){
               totalValue += grayscaleVerticalLine[i];
            }
            
            //cout << totalValue/grayscaleVerticalLine.size() << endl;
            
                totalValue = 0;
        
            //grayscaleVerticalLine.clear();
            
            
            
        }
    }

}

//--------------------------------------------------------------
void ofApp::draw(){
            
    grayImage.draw(0, 0);
    
    ofMesh verticalLine;
    verticalLine.setMode(OF_PRIMITIVE_LINE_STRIP);
    verticalLine.enableColors();
    
    for (int i=0; i<grayscaleVerticalLine.size(); i++) {
        verticalLine.addVertex(ofVec3f(ofGetWidth()/2, i, 0));
        
        float invertedGrayscaleColor = (255 - grayscaleVerticalLine[i]) / 255.0;
        verticalLine.addColor(ofFloatColor(invertedGrayscaleColor,
                                           invertedGrayscaleColor,
                                           invertedGrayscaleColor,
                                           1.0));
    }
    
    verticalLine.draw();
    grayscaleVerticalLine.clear();
        //after drawing the line, bake sure to clear the values

}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){

}

//--------------------------------------------------------------
void ofApp::gotFocus(){

}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){

}
