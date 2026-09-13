from PIL import Image
import numpy as np

def process(in_f, out_f):
    img = Image.open(in_f).convert('L')
    arr = np.array(img)
    out = np.zeros((arr.shape[0], arr.shape[1], 4), dtype=np.uint8)
    out[:,:,0] = 255
    out[:,:,1] = 255
    out[:,:,2] = 255
    out[:,:,3] = arr
    Image.fromarray(out).save(out_f)

process('assets/images/cloud1.jpg', 'assets/images/cloud1.png')
process('assets/images/cloud2.jpg', 'assets/images/cloud2.png')
