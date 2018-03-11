import cv2
from io import BytesIO
from flask import Flask, send_file, render_template
from breed_classifier import dog_breed
from species_detector import dog_detector, face_detector
import matplotlib.pyplot as plt  

# gimme images of stuff!
def lol_you_look_like_a_dog(img_path):
    is_dog = dog_detector(img_path)
    is_human = face_detector(img_path)
    #breed = dog_breed(img_path)
    breed = "test"
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
    figure = plt.figure()
    plt.imshow(img)
    plt.text(0, -10, message, fontsize=12, color=('r' if is_error else 'b'))
    plt.axis('off')
    plt.show()
    return figure


app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'hello 🐶'

@app.route('/image')
def image():
    return render_template("assets/image.html")

@app.route('/png')
def png():
    fig = lol_you_look_like_a_dog("assets/anoff.jpg")
    img = BytesIO()
    fig.savefig(img)
    img.seek(0)
    return send_file(img, mimetype='image/png')

if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0')