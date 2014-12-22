#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "ofxOpenCv.h"
#include "oscillator.h"

class ofApp : public ofxiOSApp {
	
    public:
        void setup();
        void update();
        void draw();
        void exit();
	
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);

        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);
    
        //video and opencv
        int camW;
        int camH;
        ofVideoGrabber grabber;
        ofxCvColorImage	colorImg;
        ofxCvGrayscaleImage grayImage;
        unsigned char* grayImagePixels;
        std::vector<int> grayscaleVerticalLine;
    
        //audio
        void audioOut(float * input, int bufferSize, int nChannels);
        ofSoundStream stream;
        std::vector<oscillator> oscillators;

};


