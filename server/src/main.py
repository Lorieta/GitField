import http.client
from http.server import HTTPServer, BaseHTTPRequestHandler

class GitField(HTTPServer,BaseHTTPRequestHandler):

    def get_git_info(user:str, repo:str):
        connection = http.client.HTTPSConnection("api.github.com")
        headers = {
             "User-Agent": "GitFarm-Project-v1",
            "Accept": "application/json"
            }
        connection.request("GET", f"/repos/{user}/{repo}/stats/participation",headers= headers)
        response = connection.getresponse()
        print("Status: {} and reason: {}".format(response.status, response.reason))
        print(response.read())

        connection.close()

        



# 