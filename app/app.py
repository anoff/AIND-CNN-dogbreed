import cv2
from breed_classifier import dog_breed
from species_detector import dog_detector, face_detector
import matplotlib.pyplot as plt  

# gimme images of stuff!
def lol_you_look_like_a_dog(img_path):
    is_dog = dog_detector(img_path)
    is_human = face_detector(img_path)
    breed = dog_breed(img_path)
    is_error = False
    message = ""
    if is_dog and is_human:
        message = "Something went wrong you're both human and dog!"
        is_error = True
    elif not is_dog and not is_human:
        message = "You're neither human nor dog..what are you?"
        is_error = True
    elif is_human:
        message = "Hey human 😊, you look like a {}".format(breed)
    else: # this should only match is_dog=True is_human=False
        message = "Y0 dawg 🐶, who's a good {}".format(breed)
    
    img = cv2.imread(img_path)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    a = plt.imshow(img)
    t = plt.text(0, -10, message, fontsize=12, color=('r' if is_error else 'b'))
    plt.axis('off')
    plt.show()