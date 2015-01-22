#include "ofApp.h"
#include <Accelerate/Accelerate.h>

#define SAMPLE_RATE 44100
#define BUFFER_SIZE 512
#define THRESHOLD 200
#define HIGH_FREQUENCY 2000
#define LOW_FREQUENCY 80
#define DIVIDING_FACTOR 15
//this should be changed to the vertical height of the screen depending on orientation


//--------------------------------------------------------------
void ofApp::setup(){
    
    setupCamera();
    setupAudio();
    //setupFlashlight();

    if(ofGetOrientation() == 1){
    resetForDefault();
    //resetForLandscapeLeft();
    }
    
    
}

//--------------------------------------------------------------
void ofApp::update(){
    
    //update grabber
    grabber.update();
    
    if (grabber.isFrameNew()) {
        if (grabber.getPixels() != NULL) {
            
            //make a grayscale image out of our video grabber
            colorImg.setFromPixels(grabber.getPixels(), camW, camH);
            grayImage = colorImg;
            
            //collect the grayscale values from the center vertical line in the grayscale image, store in a vector
            grayImagePixels = grayImage.getPixels();
            
            if(isDefault){
            updateForDefault();
            //updateForLandscapeLeft();
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
    
    /*
    switch (ofGetOrientation()) {
        case OF_ORIENTATION_DEFAULT:
            //drawForDefault();
            
            break;
        case OF_ORIENTATION_180:
            cout << "drawing for upside down" << endl;
            //drawForUpsideDown();
            break;
        case OF_ORIENTATION_90_LEFT:
            cout << "drawing for 90 left" << endl;

            //drawForLandscapeLeft();
            break;
        case OF_ORIENTATION_90_RIGHT:
            //drawForLandscapeRight();
            cout << "drawing for 90 right" << endl;

            break;
        default:
            break;
    }
    */
    
    
    if(isDefault){
        drawForDefault();
    }else if(isUpsideDown){
        drawForUpsideDown();
    }else if(isLandscapeLeft){
        drawForLandscapeLeft();
    }else if(isLandscapeRight){
        drawForLandscapeRight();
    }
    
    //drawForDefault();
    //drawForLandscapeLeft();

}


#pragma mark - Camera

void ofApp::setupCamera(){
    
    //setup camera
    camW = ofGetWidth();
    camH = ofGetHeight();
    
    grabber.initGrabber(camW, camH);
    
    camW = grabber.getWidth();
    camH = grabber.getHeight();
    
    //setup cv images
    colorImg.allocate(camW, camH);
    grayImage.allocate(camW, camH);
    cout << "of w: " << ofGetWidth() << " of h: " << ofGetHeight() << endl;
}


#pragma mark - Audio

void ofApp::setupAudio(){
    
    //setup audio
    int sampleRate = SAMPLE_RATE;
    int bufferSize = BUFFER_SIZE;
    ofSoundStreamSetup(1, 0, this, sampleRate, bufferSize, 2);

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

#pragma mark - Orientation Handling

#pragma mark Orientation Change

//--------------------------------------------------------------
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
    cout << "i am in default mode" << endl;
    isDefault = true;
    isUpsideDown = isLandscapeRight = isLandscapeLeft = false;
    grayscaleVerticalLine.clear();
    grayScaleVerticalLineSmall.clear();
    //setup our grayimage vertical line vector, throw all black (0) into it
   
    for (int y=0; y<grayImage.getHeight(); y++){
        grayscaleVerticalLine.push_back(0);
    }
    
    //here is where we set the total number of oscillators, from 50 to 100 to the height of our camera gray image
    //50-100 seems to work right now, even with crazy low sampleRate/buffer size...(sample rate of 50 and buffer size of 8)
    
    oscillators.clear();
    int numberofOscillators = grayImage.getHeight()/DIVIDING_FACTOR;
    for (int i=0; i<numberofOscillators; i++){
        oscillator osc;
        osc.setup(SAMPLE_RATE); // set sample rate
        osc.setVolume(0.5); // set volume
        osc.setFrequency(ofMap(i, 0, numberofOscillators-1, HIGH_FREQUENCY, LOW_FREQUENCY)); //scale freq depending on # of osc
        osc.updateWaveform(3);
        oscillators.push_back(osc);
    }
    
    //set up our scaled down version
    for (int i=0; i<numberofOscillators; i++){
        grayScaleVerticalLineSmall.push_back(0);
    }

    /*
    cout << "oscillators size: " << oscillators.size() << endl;
    for (int i = 0; i<oscillators.size(); i++){
        cout << "osc #" << i << ": freq: " << oscillators[i].getFrequency() << endl;
    }
    */
    
}

void ofApp::resetForUpsideDown(){
    cout << "i am upside down help!" << endl;
    isUpsideDown  = true;
    isDefault = isLandscapeRight = isLandscapeLeft = false;
    
    grayscaleVerticalLine.clear();
    grayScaleVerticalLineSmall.clear();
    //setup our grayimage vertical line vector, throw all black (0) into it
    
    for (int y=0; y<grayImage.getHeight(); y++){
        grayscaleVerticalLine.push_back(0);
    }
    
    //here is where we set the total number of oscillators, from 50 to 100 to the height of our camera gray image
    //50-100 seems to work right now, even with crazy low sampleRate/buffer size...(sample rate of 50 and buffer size of 8)
    
    oscillators.clear();
    int numberofOscillators = grayImage.getHeight()/DIVIDING_FACTOR;
    for (int i=0; i<numberofOscillators; i++){
        oscillator osc;
        osc.setup(SAMPLE_RATE); // set sample rate
        osc.setVolume(0.5); // set volume
        osc.setFrequency(ofMap(i, 0, numberofOscillators-1, LOW_FREQUENCY, HIGH_FREQUENCY)); //scale freq depending on # of osc
        osc.updateWaveform(3);
        oscillators.push_back(osc);
    }
    
    //set up our scaled down version
    for (int i=0; i<numberofOscillators; i++){
        grayScaleVerticalLineSmall.push_back(0);
    }
    
    /*
     cout << "oscillators size: " << oscillators.size() << endl;
     for (int i = 0; i<oscillators.size(); i++){
     cout << "osc #" << i << ": freq: " << oscillators[i].getFrequency() << endl;
     }
     */
}

void ofApp::resetForLandscapeLeft(){
    cout << "i am in landscape mode, turned to the left (counter clockwise)" << endl;
    isLandscapeLeft  = true;
    isDefault = isLandscapeRight = isUpsideDown = false;
    grayscaleVerticalLine.clear();
    grayScaleVerticalLineSmall.clear();
    for (int y=0; y<grayImage.getWidth(); y++){
        grayscaleVerticalLine.push_back(0);
    }
    
    

    //here is where we set the total number of oscillators, from 50 to 100 to the height of our camera gray image
    //50-100 seems to work right now, even with crazy low sampleRate/buffer size...(sample rate of 50 and buffer size of 8)
    
    oscillators.clear();
    int numberofOscillators = grayImage.getWidth()/DIVIDING_FACTOR;
    for (int i=0; i<numberofOscillators; i++){
        oscillator osc;
        osc.setup(SAMPLE_RATE); // set sample rate
        osc.setVolume(0.5); // set volume
        osc.setFrequency(ofMap(i, 0, numberofOscillators-1, LOW_FREQUENCY, HIGH_FREQUENCY)); //scale freq depending on # of osc
        osc.updateWaveform(3);
        oscillators.push_back(osc);
    }
    //set up our scaled down version
    for (int i=0; i<numberofOscillators; i++){
        grayScaleVerticalLineSmall.push_back(0);
    }
    
    /* debugging
     cout << "oscillators size: " << oscillators.size() << endl;
     for (int i = 0; i<oscillators.size(); i++){
     cout << "osc #" << i << ": freq: " << oscillators[i].getFrequency() << endl;
     }
     */
}

void ofApp::resetForLandscapeRight(){
    cout << "i am in landscape mode, turned to the right (clockwise)" << endl;
    isLandscapeRight  = true;
    isDefault = isLandscapeLeft = isUpsideDown = false;
    
    grayscaleVerticalLine.clear();
    grayScaleVerticalLineSmall.clear();
    for (int y=0; y<grayImage.getWidth(); y++){
        grayscaleVerticalLine.push_back(0);
    }
    
    
    
    //here is where we set the total number of oscillators, from 50 to 100 to the height of our camera gray image
    //50-100 seems to work right now, even with crazy low sampleRate/buffer size...(sample rate of 50 and buffer size of 8)
    
    oscillators.clear();
    int numberofOscillators = grayImage.getWidth()/DIVIDING_FACTOR;
    for (int i=0; i<numberofOscillators; i++){
        oscillator osc;
        osc.setup(SAMPLE_RATE); // set sample rate
        osc.setVolume(0.5); // set volume
        osc.setFrequency(ofMap(i, 0, numberofOscillators-1, HIGH_FREQUENCY, LOW_FREQUENCY)); //scale freq depending on # of osc
        osc.updateWaveform(3);
        oscillators.push_back(osc);
    }
    //set up our scaled down version
    for (int i=0; i<numberofOscillators; i++){
        grayScaleVerticalLineSmall.push_back(0);
    }
    
    /* debugging
     cout << "oscillators size: " << oscillators.size() << endl;
     for (int i = 0; i<oscillators.size(); i++){
     cout << "osc #" << i << ": freq: " << oscillators[i].getFrequency() << endl;
     }
     */

}

#pragma mark Update

void ofApp::updateForDefault(){
    //get the center vertical pixels from the camera
    for( int y = 0; y<grayImage.getHeight(); y++){
        int position = grayImage.getWidth()/2 + (y * grayImage.getWidth());
        
        // grayscaleVerticalLine[y] = grayImagePixels[position];
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
        //float new_volume = ofMap(grayscaleVerticalLine[i], 0, 255, 0.0, 1.0);
        float new_volume = grayScaleVerticalLineSmall[i];
        oscillators[i].setVolume(new_volume);
    }
}

void ofApp::updateForUpsideDown(){
    //get the center vertical pixels from the camera
    for( int y = 0; y<grayImage.getHeight(); y++){
        int position = grayImage.getWidth()/2 + (y * grayImage.getWidth());
        
        // grayscaleVerticalLine[y] = grayImagePixels[position];
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
        //float new_volume = ofMap(grayscaleVerticalLine[i], 0, 255, 0.0, 1.0);
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
        //float new_volume = ofMap(grayscaleVerticalLine[i], 0, 255, 0.0, 1.0);
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
        //float new_volume = ofMap(grayscaleVerticalLine[i], 0, 255, 0.0, 1.0);
        float new_volume = grayScaleVerticalLineSmall[i];
        oscillators[i].setVolume(new_volume);
    }

}

#pragma mark Draw

void ofApp::drawForDefault(){

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
        
    
}

void ofApp::drawForUpsideDown(){
    //cout << "drawing for upside down" << endl;
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
}

void ofApp::drawForLandscapeLeft(){
   //cout << "drawing for landscape left" << endl;
    
    ofPushStyle();
   // ofRotate(-90);
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
    ofPopStyle();

}

void ofApp::drawForLandscapeRight(){
    //cout << "drawing for landscape left" << endl;
    
    ofPushStyle();
    // ofRotate(-90);
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
    ofPopStyle();

}

#pragma mark - Flashlight

void ofApp::setupFlashlight(){
    
    //turn on flashlight
    flashlight.toggle(true);
    
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

