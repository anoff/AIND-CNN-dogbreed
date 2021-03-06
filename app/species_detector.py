import cv2
import numpy as np
from keras.applications.resnet50 import ResNet50 # pylint: disable=import-error
from keras.applications.resnet50 import preprocess_input, decode_predictions # pylint: disable=import-error
from util import path_to_tensor

# returns "True" if face is detected in image stored at img_path
def face_detector(img_path):
    img = cv2.imread(img_path)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    lbp_face_cascade = cv2.CascadeClassifier('assets/lbpcascade_frontalface.xml')
    #let's detect multiscale (some images may be closer to camera than others) images
    faces = lbp_face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5)
    return len(faces) > 0

def ResNet50_predict_labels(img_path):
    # define ResNet50 model
    ResNet50_model = ResNet50(weights='imagenet')
    # returns prediction vector for image located at img_path
    img = preprocess_input(path_to_tensor(img_path))
    return np.argmax(ResNet50_model.predict(img))

### returns "True" if a dog is detected in the image stored at img_path
def dog_detector(img_path):
    prediction = ResNet50_predict_labels(img_path)
    return ((prediction <= 268) & (prediction >= 151)) 