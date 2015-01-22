#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "ofxOpenCv.h"
#include "oscillator.h"
#include "ofxiPhoneTorch.h"

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
        std::vector<int> grayScaleVerticalLineSmall;
        void setupCamera();

    
        //audio
        void setupAudio();
        void audioOut(float * input, int bufferSize, int nChannels);
        ofSoundStream stream;
        std::vector<oscillator> oscillators;
        float currentSamples;
    
        //torch
        ofxiPhoneTorch flashlight;
        void toggleFlashlight();

    
        //orientation handling
        void resetForDefault();
        void resetForUpsideDown();
        void resetForLandscapeLeft();
        void resetForLandscapeRight();
    
        void drawForDefault();
        void drawForUpsideDown();
        void drawForLandscapeLeft();
        void drawForLandscapeRight();
    
        void updateForDefault();
        void updateForUpsideDown();
        void updateForLandscapeLeft();
        void updateForLandscapeRight();
    
        bool isDefault;
        bool isUpsideDown;
        bool isLandscapeLeft;
        bool isLandscapeRight;
};


