import requests
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/', methods=['GET'])
def index():
    import requests
    r = requests.get(url='http://192.168.56.42/status')
    res = r.json()
    temp = str(res['ext_temperature']['1']['tC'])
    return {'tC': temp}
    
if __name__ == '__main__':
    app.run(debug=True)
    