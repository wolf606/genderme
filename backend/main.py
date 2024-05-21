import matplotlib as mpl
mpl.use('Agg')  # Set the backend to Agg

from flask import Flask, request, send_file
import matplotlib.pyplot as plt
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
import librosa.display
import numpy as np
import soundfile as sf
import io
import cv2
from pydub import AudioSegment
import tempfile

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!'

@app.route('/spectrogram', methods=['POST'])
def generate_spectrogram():
    try:
        # Read the audio data from the request
        audio_file = request.files['audiofile']
        read_audio = audio_file.read()
        io_audio = io.BytesIO(read_audio)

        # Save the BytesIO object to a temporary file
        with tempfile.NamedTemporaryFile(suffix=".m4a", delete=False) as temp_audio_file:
            temp_audio_file.write(io_audio.read())
            temp_audio_file_path = temp_audio_file.name

        wav_file_path = convert_m4a_to_wav(temp_audio_file_path)
        audio, sr = librosa.load(wav_file_path)

        # Generate the spectrogram image
        spectrogram_arrat = create_spectrogram(audio, sr)

        # Return the image as an array in json
        return {'spectrogram': spectrogram_arrat.tolist()}
    except Exception as e:
        print(e)
        return {
            'error': str(e)
        }, 500

def convert_m4a_to_wav(m4a_file_path):
    wav_file_path = m4a_file_path.replace('.m4a', '.wav')
    audio = AudioSegment.from_file(m4a_file_path, format="m4a")
    audio.export(wav_file_path, format="wav")
    return wav_file_path

def create_spectrogram(audio, sr):
    fig = plt.figure(figsize=(2.4, 2.4), dpi=100)
    ax = fig.add_subplot(1, 1, 1)
    fig.subplots_adjust(left=0, right=1, bottom=0, top=1)
    ax.axis('off')

    S = librosa.feature.melspectrogram(y=audio, sr=sr)
    S_dB = librosa.power_to_db(S, ref=np.max)
    librosa.display.specshow(S_dB, sr=sr)
    canvas = FigureCanvas(fig)
    canvas.draw()
    img = np.array(canvas.renderer.buffer_rgba())
    img = cv2.cvtColor(img, cv2.COLOR_RGBA2RGB)
    plt.close(fig)

    return img

if __name__ == '__main__':
    app.run(port=5000, host='0.0.0.0')