#include "ofApp.h"
#include <Accelerate/Accelerate.h>

#define SAMPLE_RATE 44100
#define BUFFER_SIZE 512
#define THRESHOLD 200
#define HIGH_FREQUENCY 2000
#define LOW_FREQUENCY 20
#define DIVIDING_FACTOR 25
#define INITIAL_VOLUME 0.5
#define WAVEFORM_RESOLUTION 8

//--------------------------------------------------------------
void ofApp::setup(){
    ofBackground(255, 0, 0);
    
    setupCamera();
    
    if(ofGetOrientation() == 1){
        resetForDefault();
    } else if(ofGetOrientation() == 2){
        resetForUpsideDown();
    } else if(ofGetOrientation() == 3){
        resetForLandscapeLeft();
    } else if(ofGetOrientation() == 4){
        resetForLandscapeRight();
    }
    
    setupAudio();

    
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
            
            //update depending on orientation
            if(isDefault){
                updateForDefault();
            }else if (isLandscapeLeft){
                updateForLandscapeLeft();
            }else if (isLandscapeRight){
                updateForLandscapeRight();
            } else if(isUpsideDown){
                updateForUpsideDown();
            }
    
        }
    }
}

//--------------------------------------------------------------
void ofApp::draw(){

    if(isDefault){
        drawForDefault();
    }else if(isUpsideDown){
        drawForUpsideDown();
    }else if(isLandscapeLeft){
        drawForLandscapeLeft();
    }else if(isLandscapeRight){
        drawForLandscapeRight();
    }
    
}

#pragma mark - Camera

void ofApp::setupCamera(){
    
    //setup camera
    //camW = ofGetWidth();
    //camH = ofGetHeight();
    cout << "of w: " << ofGetWindowWidth() << " of h: " << ofGetWindowHeight() << endl;

    grabber.initGrabber(ofGetWidth(), ofGetHeight());
    
    camW = grabber.getWidth();
    camH = grabber.getHeight();
    
    //setup cv images
    colorImg.allocate(camW, camH);
    grayImage.allocate(camW, camH);
    cout << "of w: " << ofGetWidth() << " of h: " << ofGetHeight() << endl;
    cout << "grabber w: " << grabber.getWidth() << " of h: " << grabber.getHeight() << endl;
}

#pragma mark - Audio

void ofApp::setupAudio(){
    
    //setup audio
    int sampleRate = SAMPLE_RATE;
    int bufferSize = BUFFER_SIZE;
    ofSoundStreamSetup(1, 0, this, sampleRate, bufferSize, 4);

}

void ofApp::audioOut(float * output, int bufferSize, int nChannels){
    
    for (int i = 0; i < bufferSize; i++){
        
        float sample = 0;
        
        int totalSize = oscillators.size(); // you change the value here as well for testing (50, 100 etc)
        
        
        for (int i=0; i<totalSize; i++) {
            sample += oscillators[i].getWavetableSample();
        }
        
        sample = sample / totalSize;
        
        output[i*nChannels    ] = sample;
       // output[i*nChannels + 1] = sample;
        
    }
}

void ofApp::printOscillators(){
    cout << "oscillators size: " << oscillators.size() << endl;
    for (int i = 0; i<oscillators.size(); i++){
        cout << "osc #" << i << ": freq: " << oscillators[i].getFrequency() << endl;
    }
}

#pragma mark - Orientation Handling

#pragma mark Orientation Change

void ofApp::deviceOrientationChanged(int newOrientation){
    
    switch (newOrientation) {
        case 1:
            resetForDefault();
            break;
        case 2:
            resetForUpsideDown();
            break;
        case 3:
            resetForLandscapeLeft();
            break;
        case 4:
            resetForLandscapeRight();
            break;
        default:
            break;
    }
    
}

#pragma mark Reset

void ofApp::resetForDefault(){
    
    //cout << "i am in default mode" << endl;
    
    isDefault = true;
    isUpsideDown = isLandscapeRight = isLandscapeLeft = false;

    oscillators.clear();
    grayscaleVerticalLine.clear();
    grayScaleVerticalLineSmall.clear();

    //setup oscillators
    int numberofOscillators = ofGetHeight()/DIVIDING_FACTOR;
    for (int i=0; i<numberofOscillators; i++){
        oscillator osc;
        osc.setup(SAMPLE_RATE);
        osc.setVolume(INITIAL_VOLUME);
        osc.setFrequency(ofMap(i, 0, numberofOscillators-1, HIGH_FREQUENCY, LOW_FREQUENCY)); //scale freq depending on # of osc
        osc.updateWaveform(WAVEFORM_RESOLUTION);
        oscillators.push_back(osc);
    }
    
    //setup our grayimage vertical line vector, throw all black (0) into it
    for (int y=0; y<grayImage.getHeight(); y++){
        grayscaleVerticalLine.push_back(0);
    }
    
    //set up our scaled down version
    for (int i=0; i<numberofOscillators; i++){
        grayScaleVerticalLineSmall.push_back(0);
    }
    
    printOscillators();
    
}

void ofApp::resetForUpsideDown(){
    
    //cout << "i am upside down help!" << endl;
    
    isUpsideDown  = true;
    isDefault = isLandscapeRight = isLandscapeLeft = false;
    
    oscillators.clear();
    grayscaleVerticalLine.clear();
    grayScaleVerticalLineSmall.clear();
    
    //setup oscillators
    int numberofOscillators = grayImage.getHeight()/DIVIDING_FACTOR;
    for (int i=0; i<numberofOscillators; i++){
        oscillator osc;
        osc.setup(SAMPLE_RATE); // set sample rate
        osc.setVolume(INITIAL_VOLUME); // set volume
        osc.setFrequency(ofMap(i, 0, numberofOscillators-1, LOW_FREQUENCY, HIGH_FREQUENCY)); //scale freq depending on # of osc
        osc.updateWaveform(WAVEFORM_RESOLUTION);
        oscillators.push_back(osc);
    }
    
    //setup our grayimage vertical line vector, throw all black (0) into it
    for (int y=0; y<grayImage.getHeight(); y++){
        grayscaleVerticalLine.push_back(0);
    }
    
    //set up our scaled down version
    for (int i=0; i<numberofOscillators; i++){
        grayScaleVerticalLineSmall.push_back(0);
    }
    
    //printOscillators();
  
}

void ofApp::resetForLandscapeLeft(){
    
    //cout << "i am in landscape mode, turned to the left (counter clockwise)" << endl;
    
    isLandscapeLeft  = true;
    isDefault = isLandscapeRight = isUpsideDown = false;

    oscillators.clear();
    grayscaleVerticalLine.clear();
    grayScaleVerticalLineSmall.clear();
    
    //setup oscillators
    int numberofOscillators = grayImage.getWidth()/DIVIDING_FACTOR;
    for (int i=0; i<numberofOscillators; i++){
        oscillator osc;
        osc.setup(SAMPLE_RATE); // set sample rate
        osc.setVolume(INITIAL_VOLUME); // set volume
        osc.setFrequency(ofMap(i, 0, numberofOscillators-1, LOW_FREQUENCY, HIGH_FREQUENCY)); //scale freq depending on # of osc
        osc.updateWaveform(WAVEFORM_RESOLUTION);
        oscillators.push_back(osc);
    }

    //setup our grayimage vertical line vector, throw all black (0) into it
    for (int y=0; y<grayImage.getWidth(); y++){
        grayscaleVerticalLine.push_back(0);
    }
    
    //set up our scaled down version
    for (int i=0; i<numberofOscillators; i++){
        grayScaleVerticalLineSmall.push_back(0);
    }
    
    //printOscillators();

}

void ofApp::resetForLandscapeRight(){
    cout << "i am in landscape mode, turned to the right (clockwise)" << endl;
    isLandscapeRight  = true;
    isDefault = isLandscapeLeft = isUpsideDown = false;

    oscillators.clear();
    grayscaleVerticalLine.clear();
    grayScaleVerticalLineSmall.clear();

    //setup oscillators
    int numberofOscillators = grayImage.getWidth()/DIVIDING_FACTOR;
    for (int i=0; i<numberofOscillators; i++){
        oscillator osc;
        osc.setup(SAMPLE_RATE); // set sample rate
        osc.setVolume(INITIAL_VOLUME); // set volume
        osc.setFrequency(ofMap(i, 0, numberofOscillators-1, HIGH_FREQUENCY, LOW_FREQUENCY)); //scale freq depending on # of osc
        osc.updateWaveform(WAVEFORM_RESOLUTION);
        oscillators.push_back(osc);
    }
    
    //setup our grayimage vertical line vector, throw all black (0) into it
    for (int y=0; y<grayImage.getWidth(); y++){
        grayscaleVerticalLine.push_back(0);
    }
    
    //set up our scaled down version
    for (int i=0; i<numberofOscillators; i++){
        grayScaleVerticalLineSmall.push_back(0);
    }
    
    //printOscillators();

}

#pragma mark Update

void ofApp::updateForDefault(){
    
    //get the center vertical pixels from the camera
    for( int y = 0; y<grayImage.getHeight(); y++){
        
        int position = grayImage.getWidth()/2 + (y * grayImage.getWidth());
        
        float invertedGrayscaleValue = 255 - grayImagePixels[position];
        
        invertedGrayscaleValue = invertedGrayscaleValue > THRESHOLD ? 255 : 0; // set a threshold, if over 200, its 255, else its 0
        grayscaleVerticalLine[y] = invertedGrayscaleValue; // store these values in an array
        
        //grayScaleVerticalLineSmall[y/DIVIDING_FACTOR] = (float)grayscaleVerticalLine[y]/255.0;
        
        if (grayscaleVerticalLine[y] == 255) {
            grayScaleVerticalLineSmall[y/DIVIDING_FACTOR] = 1;
        }else{
            grayScaleVerticalLineSmall[y/DIVIDING_FACTOR] = 0;
        }
         
        //grayScaleVerticalLineSmall[y/DIVIDING_FACTOR] = ofMap(grayscaleVerticalLine[y], 0, 255, 0.0, 1.0);

    }
    
    //change osc volumes depending on black/white value in vertical line from camrea
    for (int i = 0; i<oscillators.size(); i++) {
        oscillators[i].setVolume(grayScaleVerticalLineSmall[i]);
    }
    
}

void ofApp::updateForUpsideDown(){
    
    //get the center vertical pixels from the camera
    for( int y = 0; y<grayImage.getHeight(); y++){
        int position = grayImage.getWidth()/2 + (y * grayImage.getWidth());
        
        float invertedGrayscaleValue = 255 - grayImagePixels[position];
        invertedGrayscaleValue = invertedGrayscaleValue > THRESHOLD ? 255 : 0; // set a threshold, if over 200, its 255, else its 0
        grayscaleVerticalLine[y] = invertedGrayscaleValue; // store these values in an array
        
        if (grayscaleVerticalLine[y] == 255) {
            grayScaleVerticalLineSmall[y/DIVIDING_FACTOR] = 1;
        }else{
            grayScaleVerticalLineSmall[y/DIVIDING_FACTOR] = 0;
        }
        
    }
    
    //change osc volumes depending on black/white value in vertical line from camrea
    for (int i = 0; i<oscillators.size(); i++) {
        float new_volume = grayScaleVerticalLineSmall[i];
        oscillators[i].setVolume(new_volume);
    }
}

void ofApp::updateForLandscapeLeft(){
    
    //get the center vertical pixels from the camera
    for(int y=0; y<grayImage.getHeight(); y++){
        for (int x=0; x<grayImage.getWidth(); x++) {
            
            if (y == grayImage.getWidth()/2) {
                int position = x + (y * grayImage.getWidth());
                float invertedGrayscaleValue = 255 - grayImagePixels[position];
                invertedGrayscaleValue = invertedGrayscaleValue > THRESHOLD ? 255 : 0; // set a threshold, if over 200, its 255, else its 0
                grayscaleVerticalLine[x] = invertedGrayscaleValue; // store these values in an arra
                
                if (grayscaleVerticalLine[x] == 255) {
                    grayScaleVerticalLineSmall[x/DIVIDING_FACTOR] = 1;
                }else{
                    grayScaleVerticalLineSmall[x/DIVIDING_FACTOR] = 0;
                }
            }
            
        }
    }
    
    //change osc volumes depending on black/white value in vertical line from camrea
    for (int i = 0; i<oscillators.size(); i++) {
        float new_volume = grayScaleVerticalLineSmall[i];
        oscillators[i].setVolume(new_volume);
    }
    
}

void ofApp::updateForLandscapeRight(){
    
    //get the center vertical pixels from the camera
    for(int y=0; y<grayImage.getHeight(); y++){
        for (int x=0; x<grayImage.getWidth(); x++) {
            
            if (y == grayImage.getWidth()/2) {
                int position = x + (y * grayImage.getWidth());
                float invertedGrayscaleValue = 255 - grayImagePixels[position];
                invertedGrayscaleValue = invertedGrayscaleValue > THRESHOLD ? 255 : 0; // set a threshold, if over 200, its 255, else its 0
                grayscaleVerticalLine[x] = invertedGrayscaleValue; // store these values in an arra
                
                if (grayscaleVerticalLine[x] == 255) {
                    grayScaleVerticalLineSmall[x/DIVIDING_FACTOR] = 1;
                }else{
                    grayScaleVerticalLineSmall[x/DIVIDING_FACTOR] = 0;
                }
            }
            
            
        }
    }
    
    //change osc volumes depending on black/white value in vertical line from camrea
    for (int i = 0; i<oscillators.size(); i++) {
        float new_volume = grayScaleVerticalLineSmall[i];
        oscillators[i].setVolume(new_volume);
    }

}

#pragma mark Draw

void ofApp::drawForDefault(){

    //draw our gray image
    grayImage.draw(0, 0);
    
    //draw a line that shows the inverse colors, so we can understand what we're looking at/listeing to
    ofMesh verticalLine1;
    verticalLine1.setMode(OF_PRIMITIVE_LINE_STRIP);
    verticalLine1.enableColors();
    
    for (int i=0; i<grayscaleVerticalLine.size(); i++) {
        
        //change vertex position based on orientation
        verticalLine1.addVertex(ofVec3f(ofGetWidth()/2, i, 0));
        float invertedGrayscaleColor = (grayscaleVerticalLine[i]) / 255.0;
        verticalLine1.addColor(ofFloatColor(invertedGrayscaleColor,
                                           invertedGrayscaleColor,
                                           invertedGrayscaleColor,
                                           1.0));
        
        
    }
    
    verticalLine1.draw();
    
    //draw a line that shows the inverse colors, so we can understand what we're looking at/listeing to
    ofMesh verticalLine2;
    verticalLine2.setMode(OF_PRIMITIVE_LINE_STRIP);
    verticalLine2.enableColors();
    
    for (int i=0; i<grayscaleVerticalLine.size(); i++) {
        
        //change vertex position based on orientation
        verticalLine2.addVertex(ofVec3f((ofGetWidth()/2) + 1, i, 0));
        float invertedGrayscaleColor = (grayscaleVerticalLine[i]) / 255.0;
        verticalLine2.addColor(ofFloatColor(invertedGrayscaleColor,
                                            invertedGrayscaleColor,
                                            invertedGrayscaleColor,
                                            1.0));
        
        
    }
    
    verticalLine2.draw();
    
    
    //draw a line that shows the inverse colors, so we can understand what we're looking at/listeing to
    ofMesh verticalLine3;
    verticalLine3.setMode(OF_PRIMITIVE_LINE_STRIP);
    verticalLine3.enableColors();
    
    for (int i=0; i<grayscaleVerticalLine.size(); i++) {
        
        //change vertex position based on orientation
        verticalLine3.addVertex(ofVec3f((ofGetWidth()/2) - 1, i, 0));
        float invertedGrayscaleColor = (grayscaleVerticalLine[i]) / 255.0;
        verticalLine3.addColor(ofFloatColor(invertedGrayscaleColor,
                                            invertedGrayscaleColor,
                                            invertedGrayscaleColor,
                                            1.0));
        
        
    }
    
    verticalLine3.draw();
    
    
}

void ofApp::drawForUpsideDown(){

    //draw our gray image
    grayImage.draw(0, 0);
    
    //draw a line that shows the inverse colors, so we can understand what we're looking at/listeing to
    ofMesh verticalLine;
    verticalLine.setMode(OF_PRIMITIVE_LINE_STRIP);
    verticalLine.enableColors();
    
    for (int i=0; i<grayscaleVerticalLine.size(); i++) {
        
        //change vertex position based on orientation
        verticalLine.addVertex(ofVec3f(ofGetWidth()/2, i, 0));
        float invertedGrayscaleColor = (grayscaleVerticalLine[i]) / 255.0;
        verticalLine.addColor(ofFloatColor(invertedGrayscaleColor,
                                           invertedGrayscaleColor,
                                           invertedGrayscaleColor,
                                           1.0));
    }
    
    verticalLine.draw();
    
    //draw a line that shows the inverse colors, so we can understand what we're looking at/listeing to
    ofMesh verticalLine2;
    verticalLine2.setMode(OF_PRIMITIVE_LINE_STRIP);
    verticalLine2.enableColors();
    
    for (int i=0; i<grayscaleVerticalLine.size(); i++) {
        
        //change vertex position based on orientation
        verticalLine2.addVertex(ofVec3f((ofGetWidth()/2) + 1, i, 0));
        float invertedGrayscaleColor = (grayscaleVerticalLine[i]) / 255.0;
        verticalLine2.addColor(ofFloatColor(invertedGrayscaleColor,
                                           invertedGrayscaleColor,
                                           invertedGrayscaleColor,
                                           1.0));
    }
    
    verticalLine2.draw();
    
    //draw a line that shows the inverse colors, so we can understand what we're looking at/listeing to
    ofMesh verticalLine3;
    verticalLine3.setMode(OF_PRIMITIVE_LINE_STRIP);
    verticalLine3.enableColors();
    
    for (int i=0; i<grayscaleVerticalLine.size(); i++) {
        
        //change vertex position based on orientation
        verticalLine3.addVertex(ofVec3f((ofGetWidth()/2) - 1, i, 0));
        float invertedGrayscaleColor = (grayscaleVerticalLine[i]) / 255.0;
        verticalLine3.addColor(ofFloatColor(invertedGrayscaleColor,
                                            invertedGrayscaleColor,
                                            invertedGrayscaleColor,
                                            1.0));
    }
    
    verticalLine3.draw();
    
    
}

void ofApp::drawForLandscapeLeft(){
    
    //draw our gray image
    grayImage.draw(0, 0);
    
    //draw a line that shows the inverse colors, so we can understand what we're looking at/listeing to
    ofMesh verticalLine;
    verticalLine.setMode(OF_PRIMITIVE_LINE_STRIP);
    verticalLine.enableColors();
    
    //for (int i=grayscaleVerticalLine.size(); i>0; i--) {
    for (int i=0; i<grayscaleVerticalLine.size(); i++){

        
        //change vertex position based on orientation
        verticalLine.addVertex(ofVec3f(i, ofGetHeight()/2, 0));
        float invertedGrayscaleColor = (grayscaleVerticalLine[i]) / 255.0;
        verticalLine.addColor(ofFloatColor(invertedGrayscaleColor,
                                           invertedGrayscaleColor,
                                           invertedGrayscaleColor,
                                           1.0));
    }
    
    verticalLine.draw();
    
    //draw a line that shows the inverse colors, so we can understand what we're looking at/listeing to
    ofMesh verticalLine2;
    verticalLine2.setMode(OF_PRIMITIVE_LINE_STRIP);
    verticalLine2.enableColors();
    
    //for (int i=grayscaleVerticalLine.size(); i>0; i--) {
    for (int i=0; i<grayscaleVerticalLine.size(); i++){
        
        
        //change vertex position based on orientation
        verticalLine2.addVertex(ofVec3f(i, (ofGetHeight()/2) + 1, 0));
        float invertedGrayscaleColor = (grayscaleVerticalLine[i]) / 255.0;
        verticalLine2.addColor(ofFloatColor(invertedGrayscaleColor,
                                           invertedGrayscaleColor,
                                           invertedGrayscaleColor,
                                           1.0));
    }
    
    verticalLine2.draw();
    
    //draw a line that shows the inverse colors, so we can understand what we're looking at/listeing to
    ofMesh verticalLine3;
    verticalLine3.setMode(OF_PRIMITIVE_LINE_STRIP);
    verticalLine3.enableColors();
    
    //for (int i=grayscaleVerticalLine.size(); i>0; i--) {
    for (int i=0; i<grayscaleVerticalLine.size(); i++){
        
        
        //change vertex position based on orientation
        verticalLine3.addVertex(ofVec3f(i, (ofGetHeight()/2) - 1, 0));
        float invertedGrayscaleColor = (grayscaleVerticalLine[i]) / 255.0;
        verticalLine3.addColor(ofFloatColor(invertedGrayscaleColor,
                                            invertedGrayscaleColor,
                                            invertedGrayscaleColor,
                                            1.0));
    }
    
    verticalLine3.draw();


}

void ofApp::drawForLandscapeRight(){
    
    //draw our gray image
    grayImage.draw(0, 0);
    
    //draw a line that shows the inverse colors, so we can understand what we're looking at/listeing to
    ofMesh verticalLine;
    verticalLine.setMode(OF_PRIMITIVE_LINE_STRIP);
    verticalLine.enableColors();
    
    //for (int i=grayscaleVerticalLine.size(); i>0; i--) {
    for (int i=0; i<grayscaleVerticalLine.size(); i++){
        
        
        //change vertex position based on orientation
        
        verticalLine.addVertex(ofVec3f(i, ofGetHeight()/2, 0));
        float invertedGrayscaleColor = (grayscaleVerticalLine[i]) / 255.0;
        verticalLine.addColor(ofFloatColor(invertedGrayscaleColor,
                                           invertedGrayscaleColor,
                                           invertedGrayscaleColor,
                                           1.0));
    }
    
    verticalLine.draw();
    
    //draw a line that shows the inverse colors, so we can understand what we're looking at/listeing to
    ofMesh verticalLine2;
    verticalLine2.setMode(OF_PRIMITIVE_LINE_STRIP);
    verticalLine2.enableColors();
    
    //for (int i=grayscaleVerticalLine.size(); i>0; i--) {
    for (int i=0; i<grayscaleVerticalLine.size(); i++){
        
        
        //change vertex position based on orientation
        
        verticalLine2.addVertex(ofVec3f(i, (ofGetHeight()/2) + 1, 0));
        float invertedGrayscaleColor = (grayscaleVerticalLine[i]) / 255.0;
        verticalLine2.addColor(ofFloatColor(invertedGrayscaleColor,
                                           invertedGrayscaleColor,
                                           invertedGrayscaleColor,
                                           1.0));
    }
    
    verticalLine2.draw();
    
    //draw a line that shows the inverse colors, so we can understand what we're looking at/listeing to
    ofMesh verticalLine3;
    verticalLine3.setMode(OF_PRIMITIVE_LINE_STRIP);
    verticalLine3.enableColors();
    
    //for (int i=grayscaleVerticalLine.size(); i>0; i--) {
    for (int i=0; i<grayscaleVerticalLine.size(); i++){
        
        
        //change vertex position based on orientation
        
        verticalLine3.addVertex(ofVec3f(i, (ofGetHeight()/2) - 1, 0));
        float invertedGrayscaleColor = (grayscaleVerticalLine[i]) / 255.0;
        verticalLine3.addColor(ofFloatColor(invertedGrayscaleColor,
                                            invertedGrayscaleColor,
                                            invertedGrayscaleColor,
                                            1.0));
    }
    
    verticalLine3.draw();


}

#pragma mark - Events
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
    flashlight.state() == true ? flashlight.toggle(false) : flashlight.toggle(true);
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

