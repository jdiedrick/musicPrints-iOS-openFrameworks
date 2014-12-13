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
            colorImg.setFromPixels(grabber.getPixels(), camW, camH);
            grayImage = colorImg;
        }
    }

}

//--------------------------------------------------------------
void ofApp::draw(){
	
    grayImage.draw(0, 0);
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
