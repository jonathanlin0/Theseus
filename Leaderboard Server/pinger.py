import requests

from time import sleep


while True:
  
  try:
    URL = "https://TheseusLeaderboardServer.jonathanlin04.repl.co"
    
    r = requests.get(url = URL)

    
    if "200" not in str(r):
      print("WEBSITE ERROR")
      print(r)
    if "200" in str(r):
      print("Successful ping to https://TheseusLeaderboardServer.jonathanlin04.repl.co")

    print("")
    sleep(5)
  except:
    print("ERROR WITH BOT")
