import random
import json
import time
from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
app.url_map.strict_slashes = False

@app.route("/")
def home():
    return "Welcome to the external server/API for the game Theseus. This is part of our project for the FBLA Computer Game and Simulation Programming event. You can use https://TheseusLeaderboardServer.jonathanlin04.repl.co/leaderboard to return the leaderboard information. Our repository is available on Github at https://github.com/jonathanlin0/Theseus"

@app.route("/leaderboard/")
def leaderboard():
  f = open("data.json")
  data = json.load(f)
  f.close()
  return data

if __name__ == "__main__":
    #app.debug = True
    #app.run(debug = True)
    #app.run(host="0.0.0.0",port= 5000)
    app.run(debug=False, host = '0.0.0.0',port= 5000)