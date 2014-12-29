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
    
    //setup our grayimage vertical line vector, throw all black (0) into it
    for (int y=0; y<grayImage.getHeight(); y++){
        grayscaleVerticalLine.push_back(0);
    }
    
    //setup audio
    int sampleRate = 44100;
    int bufferSize = 512;
    ofSoundStreamSetup(1, 0, this, sampleRate, bufferSize, 2);
    
    //here is where we set the total number of oscillators, from 50 to 100 to the height of our camera gray image
    //50-100 seems to work right now, even with crazy low sampleRate/buffer size...(sample rate of 50 and buffer size of 8)
    
    int numberofOscillators = 50;//grayImage.getHeight();
    for (int i=0; i<numberofOscillators; i++){
        oscillator osc;
        osc.setup(sampleRate); // set sample rate
        osc.setVolume(0.5); // set volume
        osc.setFrequency(ofMap(i, 0, numberofOscillators-1, 2000, 80)); //scale freq depending on # of osc
        osc.updateWaveform(3);
        oscillators.push_back(osc);
    }
    
    cout << "oscillators size: " << oscillators.size() << endl;
    
    for (int i = 0; i<oscillators.size(); i++){
        cout << "osc #" << i << ": freq: " << oscillators[i].getFrequency() << endl;
    }
    
}

//--------------------------------------------------------------
void ofApp::update(){
    
    //update ghr grabber
    grabber.update();
    
    if (grabber.isFrameNew()) {
        if (grabber.getPixels() != NULL) {
            
            //make a grayscale image out of our video grabber
            colorImg.setFromPixels(grabber.getPixels(), camW, camH);
            grayImage = colorImg;
            
            //collect the grayscale values from the center vertical line in the grayscale image, store in a vector
            grayImagePixels = grayImage.getPixels();
            
            
            //get the center vertical pixels from the camera
            for( int y = 0; y<grayImage.getHeight(); y++){
                int position = grayImage.getWidth()/2 + (y * grayImage.getWidth());
                
                // grayscaleVerticalLine[y] = grayImagePixels[position];
                
                float invertedGrayscaleValue = 255 - grayImagePixels[position];
                invertedGrayscaleValue = invertedGrayscaleValue > 200 ? 255 : 0; // set a threshold, if over 200, its 255, else its 0
                grayscaleVerticalLine[y] = invertedGrayscaleValue; // store these values in an array
                
            }
            
            //change osc volumes depending on black/white value in vertical line from camrea
            for (int i = 0; i<oscillators.size(); i++) {
                float new_volume = ofMap(grayscaleVerticalLine[i], 0, 255, 0.0, 1.0);
                oscillators[i].setVolume(new_volume);
            }
    
        }
    }

}

//--------------------------------------------------------------
void ofApp::draw(){
    
    //draw our gray image
    grayImage.draw(0, 0);
    
    //draw a line that shows the inverse colors, so we can understand what we're looking at/listeing to
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

//--------------------------------------------------------------
void ofApp::audioOut(float * output, int bufferSize, int nChannels){
    
    for (int i = 0; i < bufferSize; i++){
        
        float sample = 0;
        
        int totalSize = oscillators.size(); // you change the value here as well testing (50, 100 etc)
        
        for (int i=0; i<totalSize; i++) {
            //sample += oscillators[i].getSample();
            sample += oscillators[i].getWavetableSample();
        }
        
        sample = sample / totalSize;
        
        output[i*nChannels    ] = sample;
       // output[i*nChannels + 1] = sample;
        
    }
}

