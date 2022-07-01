import random
import json
import time
from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
app.url_map.strict_slashes = False

# default path
@app.route("/")
def home():
    return "Welcome to the external server/API for the game Theseus. This is part of our project for the FBLA Computer Game and Simulation Programming event. You can use https://TheseusLeaderboardServer.jonathanlin04.repl.co/leaderboard to return the leaderboard information. Our repository is available on Github at https://github.com/jonathanlin0/Theseus"

# this is used for testing to make sure the server is returning what it's supposed to
@app.route("/test/")
def test():
  return "test"

# returns a json of the leaderboard file
@app.route("/leaderboard/")
def leaderboard():
  f = open("data.json")
  data = json.load(f)
  f.close()
  return data

# used to log new scores
@app.route("/<username>/<start_time>/<end_time>/")
def add(username,start_time,end_time):
  f = open("data.json")
  data = json.load(f)
  f.close()

  new_data = {
    "start_time":start_time,
    "end_time":end_time,
    "time_elapsed":float(end_time) - float(start_time)
  }
  
  data["Leaderboard"][username] = new_data

  with open('data.json', 'w') as outfile:
    json.dump(data, outfile, indent=4)

  return "complete"

# deployment settings
if __name__ == "__main__":
    #app.debug = True
    #app.run(debug = True)
    #app.run(host="0.0.0.0",port= 5000)
    app.run(debug=False, host = '0.0.0.0',port= 5000)